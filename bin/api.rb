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
#set global var to know whether CLI or API was invoked.
$INVOKE_SRC = 'api'

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
  return h
end

def apiEngMode()
  engModeHandler(engmode())
end

def apiExtIp()
  h = {}
  h.merge!('external-ip': extIp().gsub("\n",""))
  return h
end

def apiAvailZone()
  h = {}
  h.merge!('availability-zone': region())
  return h
end

def apiInstanceType()
  h = {}
  h.merge!('instance-type': instanceType())
  return h
end

def apiIntIp()
  h = {}
  h.merge!('internal-ip': intIp())
  return h
end

def apiGetUserList()
  if users = getUserList()
    h = {}
    h.merge!(users: getUserList())
    return h
  else
    return {'status' => false} 
  end 
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
  if response
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

def apiSupportStatus()
  h = {}
  h.merge!('status': getSupportStatus())
  return h
end

def apiSupportEnabledSince()
  h = {}
  h.merge!('enabled-since': getSupportEnabledSince())
  return h
end

def apiSupportEnable()
  if enableRemoteSupport()
    return {'status' => true}
  else
    return {'status' => false}
  end
end

def apiSupportDisable()
  if disableRemoteSupport()
    return {'status' => true}
  else
    return {'status' => false}
  end
end

def apiSupportPing()
  if getSupportStatus()
    return {'status' => pingRemoteSupport()}
  else
    return {'status' => false}
  end
end

def apiNetworkInterfaceList()
  return {'interfaces' => getNetworkInterfaces()}
end

def apiNetworkInterfaceDetails(inputJson)
  begin
    hash = JSON.parse(inputJson)
  rescue
    return {'status' => false}
  end
  if ! hash['interface'].nil?
    begin
      return {'interface' => getInterfaceDetails(hash['interface'])}
    rescue
      return {'interface' => hash['interface'], 'invalid' => true}
    end
  else
    return {'status' => false}
  end
end

def apiNetworkAllInterfaceDetails()
  return {'interfaces' => getAllInterfaceDetails()}
end

def apiFirewallZoneList()
  return {'zones' => getFirewallZones()}
end

def apiFirewallZoneDetails(name)
  begin
    hash = JSON.parse(inputJson)
  rescue
    return {'status' => false}
  end
  if ! hash['zone'].nil?
    begin
      return {'zone' => getFirewallZoneDetails(hash['zone'])}
    rescue
      return {'zone' => hash['zone'], 'invalid' => true}
    end
  else
    return {'status' => false}
  end
end

def apiFirewallAllZoneDetails()
  return {'zones' => getAllFirewallZoneDetails()}
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
    - userCreate - Create a user - requires '{"user-name":"<System username>","full-name":"<User's full name>"}'
    - userSetKey - Set SSH key for a system user - requires '{"user-name":"<System username>","key":"<SSH Key to be used>"}'
    - userGetList - Return list of system users.
    - userSetPasswd - Set the user's password - requires '{"user-name":"<System username>","passwd":"<User's password>"}'
    - userDelete - Delete a user from the system - requires '{"user-name":"<System username>","delete":true}'
    - supportStatus - Return the status of the Alces Support VPN.
    - supportEnabledSince - Return how long the Alces Support VPN has been connected.
    - supportEnable - Enable the Alces Support VPN.
    - supportDisable - Disable the Alces Support VPN.
    - supportPing - Check connectivity to the Alces Support hub.
    - networkInterfaceList - Return a list of network interfaces.
    - networkInterfaceDetails - Return the details of a specific network interface - requires '{"interface": "<dev>"}'
    - networkAllInterfaceDetails - Return the details of all network interfaces.
    - shutdown - Shut down the instance - requires '{"shutdown":true}'
    - reboot - Restart the instance - requires '{"reboot":true}' 

  HEREDOC
end

begin
  appendLogFile('API Call - ARGV:', ARGV.to_s)
  case ARGV[0]
  when 'infoInst'
    response = apiInfoInst()
  when 'inetStat'
    response = apiInetStat()
  when 'extIp'
    response = apiExtIp()
  when 'intIp'
    response = apiIntIp()
  when 'availabilityZone'
    response = apiAvailZone()
  when 'instanceType'
    response = apiInstanceType()
  when 'userCreate'
    response = apiCreateUser(ARGV[1])
  when 'userSetKey'
    response = apiSetKey(ARGV[1])
  when 'userGetList'
    response = apiGetUserList()
  when 'userSetPasswd'
    response = apiUserSetPasswd(ARGV[1])
  when 'userDelete'
    response = apiUserDelete(ARGV[1])
  when 'supportStatus'
    response = apiSupportStatus()
  when 'supportEnabledSince'
    response = apiSupportEnabledSince()
  when 'supportEnable'
    response = apiSupportEnable()
  when 'supportDisable'
    response = apiSupportDisable()
  when 'supportPing'
    response = apiSupportPing()
  when 'networkInterfaceList'
    response = apiNetworkInterfaceList() 
  when 'networkInterfaceDetails'
    response = apiNetworkInterfaceDetails(ARGV[1])
  when 'networkAllInterfaceDetails'
    response = apiNetworkAllInterfaceDetails()
  when 'firewallZoneList'
    response = apiFirewallZoneList()
  when 'firewallZoneDetails'
    response = apiFirewallZoneDetails(ARGV[1])
  when 'firewallAllZoneDetails'
    response = apiFirewallAllZoneDetails()
  when 'shutdown'
    response = apiShutdown(ARGV[1])
  when 'reboot'
    response = apiReboot(ARGV[1])
  when 'help'
    response = apiHelp()
  else
    response = "Invalid Command - use help for a list of requests"
    quietError('Invalid API Call', 'No suitable function found')
  end  
  if response['status'] == false
    quietError('API Response', response.to_json)
  else
    appendLogFile('API Response:', response.to_json)
  end
  ## After all that, print it to screen.
  puts response.to_json
end
