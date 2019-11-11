#!/usr/bin/env ruby
#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Appliance Menu.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Appliance Menu is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Appliance Menu. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Appliance Menu, please visit:
# https://github.com/alces-software/flight-appliance-menu
#==============================================================================

config = YAML.load(File.read(File.expand_path('../../cfg/config.yaml',__FILE__)))
$vpnSlotFilePath = config['vpn']['vpnslotfile']
$vpnSlotFileConfig = YAML.load(File.read($vpnSlotFilePath))
$etcConfigPath = config['vpn']['vpnconfigpath']
$vpnUsersFile = config['vpn']['vpnusersfile']

def reloadSlotFileConfig()
  $vpnSlotFileConfig = YAML.load(File.read($vpnSlotFilePath))
end

def vpnSlotFileWrite(slotHash)
  $vpnSlotFileConfig['slots'].merge!(slotHash)
  writeHashToYaml($vpnSlotFileConfig,$vpnSlotFilePath)
end

def slotList()
  slotList = $vpnSlotFileConfig['slots'].keys 
end

def slotListAvail()
  slotListAvail = $vpnSlotFileConfig['slots'].reject {|k,h| h['configured']}
end

def slotListUsed()
  slotListUsed = $vpnSlotFileConfig['slots'].select {|k,h| h['configured']} 
end

def assignSlot(clientName,vpnSlot)
  slotHash = $vpnSlotFileConfig ['slots'].select {|k,h| k == vpnSlot}
  if ! slotHash.empty? && slotListAvail.keys.include?(vpnSlot) 
    File.open("/etc/openvpn/ccd-cluster/#{clientName}", 'w') do |l|
      l.puts("ifconfig-push #{slotHash[vpnSlot]['clientip']} #{slotHash[vpnSlot]['serverip']}")
    end
    if ! Open3.capture3("sudo \/sbin\/useradd -M -N -s \/sbin\/nologin #{clientName} --gid vpn")[2].success?
      return nil
    else
      slotHash[vpnSlot].store('clientscript', generateTemplate(clientName))
      slotHash[vpnSlot]['clientname'] = clientName
      slotHash[vpnSlot]['configured'] = true
      slotHash[vpnSlot]['password'] = '' 
      vpnSlotFileWrite(slotHash)
      reloadSlotFileConfig()
      writeVPNUsersConf()
    end
  else
    return nil
  end
end

def writeVPNUsersConf()
  users = $vpnSlotFileConfig['slots'].select {|k,v| v['configured']}.map {|k,v| v['clientname']}
  File.open($vpnUsersFile, "w+") do |f|
    users.each {|e| f.puts(e)}
  end
end

def setPasswd(userName,cryptedPasswd)
  #chpasswdString = userName + ':' + cryptedPasswd
  chpasswdStatus = Open3.capture3("sudo /usr/sbin/usermod --password '#{cryptedPasswd}' #{userName}")
  if chpasswdStatus[2].success?
    return true
  else
    return false
  end
end

def genPasswd()
  passwdAry = []
  o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
  generatedPasswd = (0...15).map { o[rand(o.length)] }.join
  passwdAry = []
  passwdAry[0] = generatedPasswd
  passwdOut,err,status = Open3.capture3("printf '#{generatedPasswd}' | \/bin\/openssl passwd -1 -stdin")
  if status.success?
    passwdAry[1] = passwdOut[0..-2]
    return passwdAry
  else
    raise StandardError
  end
end

def genClientPasswd(vpnSlot)
  begin
    passwdAry = genPasswd()
    randomRawPass = passwdAry[0]
    cryptedPasswd = passwdAry[1]
    slotHash = $vpnSlotFileConfig ['slots'].select {|k,h| k == vpnSlot}
    if ! slotHash.empty? || ! slotHash[vpnSlot]['configured'] == true
      clientName = slotHash[vpnSlot]['clientname']
      if ! setPasswd(clientName, cryptedPasswd)
        fail
      end
      slotHash[vpnSlot]['password'] = cryptedPasswd 
      vpnSlotFileWrite(slotHash)
      reloadSlotFileConfig()
      writeVPNUsersConf()
      return randomRawPass
    end
  rescue
    return nil
  end
end

def getVpnList()
  slots = {}
  slothash = {}
  slotListUsed.each_key do |slot|
    clientname = $vpnSlotFileConfig['slots'][slot]['clientname']
    pingable = checkClientResponding($vpnSlotFileConfig['slots'][slot]['clientip'])
    slothash = {:clientname => clientname, :connstatus => pingable}
    slots.merge! slot => slothash 
  end
  return slots
end


def caCrt()
  begin
    File.read('/etc/openvpn/easyrsa/pki/ca.crt')
  rescue
    outputError('caCrt()','Could not read /etc/openvpn/easyrsa/pki/ca.crt - is OpenVPN installed and configured?')
  end
end

def generateTemplate(clientName)
  @clientName = clientName
  template = File.read(File.join($etcConfigPath, 'vpnclienttemplate.erb'))
  renderer = ERB.new(template)
  renderer.result()
end

def getVPNClientScript(vpnSlot)
  begin
    slotHash = $vpnSlotFileConfig ['slots'].select {|k,h| k == vpnSlot}
    if ! slotHash[vpnSlot]['clientscript'].nil? 
      return slotHash[vpnSlot]['clientscript']
    else 
      return nil
    end
  rescue
    return nil
  end
end

def deleteVPNClientUser(clientUser)
  deleteUser(clientUser)
end

def deconfigureVPNClient(deconfVPN)
  begin
    slotHash = $vpnSlotFileConfig ['slots'].select {|k,h| k == deconfVPN} 
    oldUser = slotHash[deconfVPN]['clientname'] 
    slotHash[deconfVPN]['configured'] = false
    slotHash[deconfVPN]['clientname'] = nil
    slotHash[deconfVPN]['password'] = nil
    slotHash[deconfVPN]['clientscript'] = nil
    deleteVPNClientUser(oldUser)
    vpnSlotFileWrite(slotHash)
    reloadSlotFileConfig()
    writeVPNUsersConf()
    return true
  rescue
    return nil
  end
end

def checkClientResponding(vpnSlotClientIP)
  if Net::Ping::External.new(vpnSlotClientIP, nil, 1).ping? 
    return true
  else
    return false
  end
end