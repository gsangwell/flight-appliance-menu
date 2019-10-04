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

$LOAD_PATH << File.expand_path(__dir__ )
#$LOAD_PATH << "/usr/local/rvm/gems/ruby-2.6.3/gems"

ENV['BUNDLE_GEMFILE'] ||= File.join(__dir__, '../Gemfile')

require 'rubygems'
require 'bundler/setup'
require 'setup'

Bundler.setup(:default)

#ENV["PATH"]='/usr/local/rvm/gems/ruby-2.6.3/bin:/usr/local/rvm/rubies/ruby-2.6.3/bin'
#ENV["GEM_HOME"]='/usr/local/rvm/gems/ruby-2.6.3'

# Set install path of program, for use in user creation
$app_root = File.expand_path(__dir__ + '/..')

setup()

def apiInetStat()
  h = {}
  h.merge!('ping-google': pingIpTest())
  h.merge!('resolve-alces-software': resolv('alces-software.com'))
  h.merge!('default-gateway': gw())
  h.merge!('dns-servers': dns('nameserver'))
  h.merge!('search-domain': dns('search'))
  h.merge!('extURL': extDNS)
  return h.to_json
end

def apiEngMode()
  engModeHandler(engmode()).to_json
end


def apiExtIp()
  h = {}
  h.merge!('external-ip': extIp().gsub("\n",""))
  return h.to_json
end

def apiAvailZone()
  h = {}
  h.merge!('availability-zone': region())
  return h.to_json
end

def apiInstanceType()
  h = {}
  h.merge!('instance-type': instanceType())
  return h.to_json
end

def apiIntIp()
  h = {}
  h.merge!('internal-ip': intIp())
  return h.to_json
end

def apiGetUserList()
  h = {}
  h.merge!(users: getUserList())
  return h.to_json
end

def apiInfoInst()
  return infoInstApiHandler()
end

def apiSetKey(inputJson)
  begin
    hash = JSON.parse(inputJson)
  rescue
    return {'status' => false}
  end
  if hash['user-name'].nil? || hash['key'].nil?
    return {'status' => false}
  else 
    uname = hash['user-name']
    key = hash['key']
  end
  if setUserSSHKey(uname, key)
    return {'user' => uname, 'status' => true}
  else
    return {'user' => uname, 'status' => false}
  end
end 

def apiCreateUser(inputJson)
  begin
    hash = JSON.parse(inputJson)
  rescue 
    return {'status' => false} 
  end
  if ! hash['user-name'].nil? && ! hash['full-name'].nil?
    uname = hash['user-name']
    fname = hash['full-name']
  else return {'status' => false}
  end  
  response = createUser(uname, fname)
  if response[2].success?
    return {'user-name' => uname, 'status' => true}
  else
    return {'user-name' => uname, 'status' => false, 'stdout' => response[0], 'stderr' => response[1]}
  end
end

def apiUserSetPasswd(inputJson)
  begin
    hash = JSON.parse(inputJson)
  rescue
    return {'status' => false} 
  end 
  if ! hash['user-name'].nil? && ! hash['passwd'].nil?
    uname = hash['user-name']
    cryptedPasswd = hash['passwd']
  else 
    return {'user-name' => uname, 'status' => false}
  end
  begin
    if setPasswd(uname, cryptedPasswd)
      return {'user-name' => uname, 'status' => true}
    else
      raise StandardError
    end
  rescue 
    return {'user-name' => uname, 'status' => false} 
  end
end

def apiUserDelete(inputJson)
  begin
    hash = JSON.parse(inputJson)
  rescue
    return {'status' => false} 
  end 
  if ! hash['user-name'].nil?
    begin
      uname = hash['user-name'] 
      if deleteUserHandler(uname)
        return {'user-name' => uname, 'status' => true} 
      else
        raise StandardError
      end
    rescue
      return {'user-name' => uname, 'status' => false}
    end
  end
end
    

 
def apiShutdown(inputJson)
  begin
    hash = JSON.parse(inputJson)
  rescue
    return {'status' => false} 
  end
  if hash['shutdown'].is_a? TrueClass
    shutdown()
    return {'status' => true}
  else
    return {'status' => false}
  end
end

 
def apiReboot(inputJson)
  begin
    hash = JSON.parse(inputJson)
  rescue
    return {'status' => false} 
  end
  if hash['reboot'].is_a? TrueClass
    reboot()
    return {'status' => true}
  else
    return {'status' => false}
  end
end

def apiVpnStatus()
  hash = {}
  begin
    vpns = getVpnList()
    hash.merge! 'vpns' => vpns
    hash.merge! 'status' => true
  rescue 
    hash = {'status' => false}
  end
  return hash
end

def apiVpnSlotsAvail()
  hash = {}
  begin
    ary = slotListAvail.keys
    hash.merge! 'slots' => ary
    hash.merge! 'status' => true
  rescue
    hash = {'status' => false}
  end
  return hash
end

def apiVpnAssign(inputJson)
  begin
    hash = JSON.parse(inputJson)
    if ! hash['vpn'].nil? && ! hash['clientname'].nil?
      clientname = hash['clientname']
      vpnslot = hash['vpn']
      if assignSlot(clientname,vpnslot)
        return {'status' => true} 
      else 
        return {'status' => false}
      end
    else 
      return {'status' => false}
    end
  rescue
    return {'status' => false} 
  end

end

def apiVpnViewClientScript(inputJson)
  begin
    hash = JSON.parse(inputJson)
    outhash = {}
    if ! hash['vpn'].nil?
      vpnslot = hash['vpn']
      script = getVPNClientScript(vpnslot)
      if ! script.nil?
        outhash.merge! vpnslot => getVPNClientScript(vpnslot)
        outhash.merge! 'status' => true
        return outhash
      else
        return {'status' => false}
      end
    else
      return {'status' => false}
    end 
  rescue
    return {'status' => false}
  end 
end

def apiVpnGeneratePassword(inputJson)
  outhash = {}
  begin
    hash = JSON.parse(inputJson)
    if ! hash['vpn'].nil?
      slot = hash['vpn']
      newPass = genClientPasswd(slot)
      if ! newPass.nil?
        outhash.merge! slot => newPass
        outhash.merge! 'status' => true
      else
        fail
      end
    else 
      fail
    end
  rescue
    return {'status' => false} 
  end
end

def apiVpnDeconfigure(inputJson)
  begin
    hash = JSON.parse(inputJson)
    if ! hash['vpn'].nil? && hash['deconfigure'] == true
      oldvpn = hash['vpn']
      if deconfigureVPNClient(oldvpn)
        return {'status' => true}
      else
        return {'status' => false}
      end
    else
      return {'status' => false}
    end
  rescue
    return {'status' => false}
  end
end 



def apiHelp()
  <<~HEREDOC

    api.rb [COMMAND] '{json-arguments}'

    - infoInst - Return Cloud Instance information
    - inetStat - Return Network Stats
    - extIp - Return External IP Address
    - intIp - Return Internal IP Address
    - availabilityZone - Return Cloud Vendor Availability Zone
    - instanceType - Return Cloud Vendor Instance Type
    - engMode - Enable Alces Engineering Mode for 1 hour
    - userCreate - Create a user - requires '{"user-name":"<System username>","full-name":"<User's full name>"}'
    - userSetKey - Set SSH key for a system user - requires '{"user-name":"<System username>","key":"<SSH Key to be used>"}'
    - userGetList - Return list of system users.
    - userSetPasswd - Set the user's password - requires '{"user-name":"<System username>","passwd":"<User's password>"}'
    - userDelete - Delete a user from the system - requires '{"user-name":"<System username>","delete":true}'
    - vpnStatus - View VPN connection status
    - vpnSlotsAvail - View VPN slots that are not yet configured
    - vpnAssign - Assign VPN slot to client - requires '{"vpn":"<available-vpn-slot>","clientname":"<clientname>"}' 
    - vpnViewClientScript - View the connection script for a client '{"vpn":"<assigned-vpn-slot>"}' 
    - vpnGeneratePassword - Generate password for client '{"vpn":"<available-vpn-slot>"}' 
    - vpnDeconfigure - Deconfigure VPN slot associated to a client '{"vpn":"<available-vpn-slot>","deconfigure":true}' 
    - shutdown - Shut down the instance - requires '{"shutdown":true}'
    - reboot - Restart the instance - requires '{"reboot":true}' 

  HEREDOC
end



begin
  case ARGV[0]
  when 'infoInst'
    puts apiInfoInst()
  when 'inetStat'
    puts apiInetStat()
  when 'extIp'
    puts apiExtIp()
  when 'intIp'
    puts apiIntIp()
  when 'availabilityZone'
    puts apiAvailZone()
  when 'instanceType'
    puts apiInstanceType()
  when 'engMode'
    puts apiEngMode()
  when 'userCreate'
    puts apiCreateUser(ARGV[1]).to_json
  when 'userSetKey'
    puts apiSetKey(ARGV[1]).to_json
  when 'userGetList'
    puts apiGetUserList()
  when 'userSetPasswd'
    puts apiUserSetPasswd(ARGV[1]).to_json
  when 'userDelete'
    puts apiUserDelete(ARGV[1]).to_json
  when 'vpnStatus'
    puts apiVpnStatus().to_json
  when 'vpnSlotsAvail'
    puts apiVpnSlotsAvail().to_json
  when 'vpnAssign'
    puts apiVpnAssign(ARGV[1]).to_json
  when 'vpnViewClientScript'
    puts apiVpnViewClientScript(ARGV[1]).to_json
  when 'vpnGeneratePasswd'
    puts apiVpnGeneratePassword(ARGV[1]).to_json
  when 'vpnDeconfigure'
    puts apiVpnDeconfigure(ARGV[1]).to_json
  when 'shutdown'
    puts apiShutdown(ARGV[1]).to_json
  when 'reboot'
    puts apiReboot(ARGV[1]).to_json
  when 'help'
    puts apiHelp()
  else
    puts "Invalid Command - use help for a list of requests"
  end

end
