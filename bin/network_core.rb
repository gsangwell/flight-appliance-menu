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

def getNetworkInterfaces()
  #output = `/sbin/ip addr`
  #interfaces = []

  #output.each_line.with_index do |line,i|
  #  if line.match(/^[0-9]+:/)
  #    name = line.match(/^[0-9]+: ([a-zA-Z0-9]*):/)[1]
  #    next if ['lo', 'tun0'].include?(name)
  #    interfaces << name
  #  end
  #end

  #return interfaces

  interfaces = []

  $config['networks'].each do |network, config|
    interfaces << network
  end

  return interfaces
end

def getInterfaceDetails(name)

  int = $config['networks'][name]['interface']

  output = `/sbin/ip addr show dev #{int}`

  interface = {}
  interface['name'] = name
  interface['interface'] = int
  interface['ipv4'] = []

  output.each_line do |line|
    if line.match(/    inet [0-9.\/]* [a-zA-Z]/)
      interface['ipv4'] << line.match(/    inet ([0-9.\/]*) [a-zA-Z]/)[1]
    end
  end

  interface['status'] = `cat /sys/class/net/#{int}/operstate`.chomp
  interface['mac'] = `cat /sys/class/net/#{int}/address`.chomp
  interface['firewall_zone'] = `firewall-cmd --get-zone-of-interface #{int} 2>&1`.chomp


  return interface
end

def getAllInterfaceDetails()
  interfaces = []
  getNetworkInterfaces().each do |name|
    interface = getInterfaceDetails(name)
    interfaces << interface
  end
  return interfaces
end

def configureInterface(name, settings)
  vars = {}
  vars['name'] = name
  vars['interface'] = $config['networks'][name]['interface']
  vars['ip'] = settings['ipv4']
  vars['netmask'] = settings['netmask']
  vars['gateway'] = settings['gateway']
  vars['zone'] = $config['networks'][name]['zone']
  vars['dns'] = settings['dns']

  if runPlaybook("modify_network.yaml", vars)
    appendLogFile("modifyNetwork(#{name},#{settings})",'')
    return true
  else
    quietError("modifyNetwork(#{name},#{settings})",'')
    return false
  end
end
