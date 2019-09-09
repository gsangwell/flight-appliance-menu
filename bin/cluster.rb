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

def clientMenu()  
  sel = $prompt.select('Choose an option') do |menu|
    menu.choice 'View VPN Status', 'viewClients'
    menu.choice 'Assign VPN', 'assignSlot'
    menu.choice 'Modify VPN', 'editClientAssignment'
    menu.choice 'View Assigned VPN Client Script', 'printVPNClientScript'
    menu.choice 'Deconfigure VPN', 'deconfigureClient'
    menu.choice 'Return', 'getout'
  end
  return sel
end


def client()
  case clientMenu()
  when 'viewClients'
    viewVPNs()
  when 'printVPNClientScript'
    printVPNClientScript()
  when 'assignSlot'
    assignSlot()
  when 'editClientAssignment'
    editClientAssignment()
  when 'deconfigureClient'
    promptDeconfigureVPNClientAssignment()
  when 'getout'
    main()
  end
end

def reloadSlotFileConfig()
  $vpnSlotFileConfig = YAML.load(File.read($vpnSlotFilePath))
end

def promptSelectUsedSlot()
  vpnSlot = $prompt.select("Choose a VPN Slot: ", slotListUsed.keys.to_a)
  return vpnSlot
end 

def promptAssignSlot()
  vpnSlot = $prompt.select("Choose a VPN Slot to assign: ", slotListAvail.keys.to_a)
  clientName = $prompt.ask("Client Name: ", required: true)
  assignedVPNSlot = [clientName,vpnSlot]
  return assignedVPNSlot
end

def promptSelectSlot()
  vpnSlot = $prompt.select("Choose a VPN Slot to Modify: ", slotListUsed.keys.to_a)
  return vpnSlot
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

def assignSlot()
  clientName,vpnSlot = promptAssignSlot()
  slotHash = $vpnSlotFileConfig ['slots'].select {|k,h| k == vpnSlot} 
  File.open("/etc/openvpn/ccd-cluster/#{clientName}", 'w') do |l|
    l.puts("ifconfig-push #{slotHash[vpnSlot]['clientip']} #{slotHash[vpnSlot]['serverip']}")
  end
  userCreateStatus = Open3.capture3("\/sbin\/useradd -M -N -s \/sbin\/nologin #{clientName}")
  rawPasswd = checkPasswd()
  cryptedPasswd = genPasswd(rawPasswd)
  setPasswd(clientName,cryptedPasswd)
  slotHash[vpnSlot].store('clientscript', generateTemplate(clientName))
  slotHash[vpnSlot]['clientname'] = clientName
  slotHash[vpnSlot]['configured'] = true
  slotHash[vpnSlot]['password'] = cryptedPasswd
  vpnSlotFileWrite(slotHash)
  reloadSlotFileConfig()
end

def setPasswd(userName,cryptedPasswd)
  #chpasswdString = userName + ':' + cryptedPasswd
  chpasswdStatus = Open3.capture3("usermod --password '#{cryptedPasswd}' #{userName}")
  if chpasswdStatus[2].success?
    return true
  else
    return false
  end
end

def genPasswd(rawPasswd)
  if rawPasswd
    passwdOut,err,status = Open3.capture3("printf '#{rawPasswd}' | \/bin\/openssl passwd -1 -stdin")
    if status.success?
      return passwdOut[0..-2]
    else
      raise StandardError
    end
  else
    raise StandardError
  end
end

def promptPasswd()
  rawPasswd1 = $prompt.mask("Enter a password: ")
  rawPasswd2 = $prompt.mask("Confirm the password: ")
  rawPasswds = [rawPasswd1,rawPasswd2]
end

def checkPasswd()
  rawPasswds = promptPasswd()
  while rawPasswds[0] != rawPasswds[1]
    puts "Passwords do not match - try again"
    rawPasswds = promptPasswd() 
  end
  return rawPasswds[0] 
end

def viewVPNs()
  $spinner.run do |spinner|
    table = []
    title = "Configured VPNs"
    slotListUsed.each_key do |slot|
      table << [slot, $vpnSlotFileConfig['slots'][slot]['clientname'], checkClientResponding($vpnSlotFileConfig['slots'][slot]['clientip'])]
    end
    header = ['VPN Slot', 'Client Name', 'Connectivity Status']
    #table = Terminal::Table.new :title => title, :rows => tableData
    #return table
    puts outputTable(title, table, header)
  end
end

def caCrt()
  File.read('/etc/openvpn/easyrsa/pki/ca.crt')
end

def generateTemplate(clientName)
  @clientName = clientName
  template = File.read(File.join($etcConfigPath, 'vpnclienttemplate.erb'))
  renderer = ERB.new(template)
  renderer.result()
end

def printVPNClientScript()
  vpnSlot = promptSelectUsedSlot()
  slotHash = $vpnSlotFileConfig ['slots'].select {|k,h| k == vpnSlot} 
  puts slotHash[vpnSlot]['clientscript']
end

def deleteVPNClientUser(clientUser)
  deleteUser(clientUser)
end

def deconfigureVPNClient(deconfVPN)
  slotHash = $vpnSlotFileConfig ['slots'].select {|k,h| k == deconfVPN} 
  oldUser = slotHash[deconfVPN]['clientname'] 
  slotHash[deconfVPN]['configured'] = false
  slotHash[deconfVPN]['clientname'] = nil
  slotHash[deconfVPN]['password'] = nil
  slotHash[deconfVPN]['clientscript'] = nil
  deleteVPNClientUser(oldUser)
  vpnSlotFileWrite(slotHash)
  reloadSlotFileConfig()
end

def promptDeconfigureVPNClientAssignment()
  deconfVPN = $prompt.select("Choose a VPN Slot to Deconfigure: ", slotListUsed.keys.to_a)
  deconfigureVPNClient(deconfVPN)
end

def editClientAssignment()
  vpnSlot = promptSelectSlot()
  slotHash = $vpnSlotFileConfig ['slots'].select {|k,h| k == vpnSlot} 
  oldName = slotHash[vpnSlot]['clientname']
  newName = $prompt.ask("Client Name: ", required: true)
  if $vpnSlotFileConfig['slots'].each
    puts "Already a Client with that name"
    return false
  else
    deleteVPNClientUserStatus = deleteVPNClientUser(oldName)
    if ! deleteVPNClientUserStatus[2].success? 
      puts deleteVPNClientUserStatus[1] + ' ' + deleteVPNClientUserStatus[0] 
    end
    if File.exist?("/etc/openvpn/ccd-cluster/#{oldName}") 
      File.delete("/etc/openvpn/ccd-cluster/#{oldName}") 
    end
    File.open("/etc/openvpn/ccd-cluster/#{newName}", 'w') do |l|
      l.puts("ifconfig-push #{slotHash[vpnSlot]['clientip']} #{slotHash[vpnSlot]['serverip']}")
    end
    slotHash[vpnSlot]['clientname'] = newName
    vpnSlotFileWrite(slotHash)
    reloadSlotFileConfig()
  end 
end

def checkClientResponding(vpnSlotClientIP)
  if Net::Ping::External.new(vpnSlotClientIP, nil, 1).ping? 
    return true
  else
    return false
  end
end


 

#probs unused - snippets only...


def clientConfigPrintScript()
  clPack = $prompt.select("Choose a Cluster Pack", clusterPacksList.each.to_a)
  scriptPath = $clustersConfig['clusters'][clusterPack]['configpath']
  script = File.read(scriptPath)
  puts script
end

def createNewCluster(assignedVPNSlot)
  createClusterScript = File.expand_path('../support/vpn/newcluster.bash',__dir__)
  newClusterScriptStatus = Open3.capture3("#{createClusterScript} #{clusterParams[1]}")
  if newClusterScriptStatus[2].success?
    puts "New Cluster VPN Configured - Cluster Script available at #{newClusterScriptStatus[0]}"
    clusterConfigNewCluster(clusterParams[0],newClusterScriptStatus[0],clusterParams[1])
  else
    puts "Script failed to run - output from script was: '#{newClusterScriptStatus[1]}'"
  end
end