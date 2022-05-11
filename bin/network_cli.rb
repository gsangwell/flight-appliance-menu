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

def network_cli()
  sel = $prompt.select('Choose an option') do |menu|
    menu.choice 'List Networks', 'list'
    menu.choice 'Show Network', 'show'
    menu.choice 'Configure Network', 'config' if metalPlatform
    menu.choice 'Return', 'ret'
  end
  case sel
  when 'list'
    puts networkInterfaces()
  when 'show'
    networkSelectMenu(:showNetwork)
  when 'config'
    networkSelectMenu(:configureNetwork)
  when 'ret'
    main()
  end
end

def networkInterfaces()
  table = []
  getNetworkInterfaces().each do |interface|
    table << ["#{interface}"]
  end
  puts outputTable("Network Interfaces", table)
end

def networkSelectMenu(callback)
  sel = $prompt.select('Choose an option') do |menu|
    getNetworkInterfaces().each do |interface|
      menu.choice "#{interface}", "#{interface}"
    end
    menu.choice 'Return', 'ret'
  end

  case sel
  when 'ret'
    network_cli()
  else
    method(callback.to_sym).call(sel)
  end
end

def showNetwork(name)
  interface = getInterfaceDetails(name)

  table = []
  table << ['Name:', interface['name']]
  table << ['Interface:', interface['interface']]
  table << ['Status:', interface['status']]
  table << ['Hardware Address:', interface['mac']]
  table << ['IPV4 Addresses:', interface['ipv4'].join(", ")]
  table << ['Firewall Zone:', interface['firewall_zone']]
  puts outputTable("Interface Details", table)
end

def editMenu()
  sel = $prompt.select('Choose an option') do |menu|
    getNetworkInterfaces().each do |interface|
      menu.choice "#{interface}", "#{interface}"
    end
    menu.choice 'Return', 'ret'
  end

  case sel
  when 'ret'
    network_cli()
  else
    editInterface(sel)
  end  
end

def configureNetwork(network)
  table = []
  table << ['Network:', network]

  config = {}

  config['ipv4'] = $prompt.ask("IPV4 Address:", required: true) do |q|
    q.validate(/^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/, "Invalid IPV4 Address")
  end

  config['netmask'] = $prompt.ask("Netmask:", required: true) do |q|
    q.validate(/^((128|192|224|240|248|252|254)\.0\.0\.0)|(255\.(((0|128|192|224|240|248|252|254)\.0\.0)|(255\.(((0|128|192|224|240|248|252|254)\.0)|255\.(0|128|192|224|240|248|252|254)))))$/, "Invalid Netmask")
  end

  yn = $prompt.yes?("Set a default gateway?") do |q|
    q.default false
  end

  if yn
    config['gateway'] = $prompt.ask("Default Gateway:", required: true) do |q|
      q.validate(/^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/, "Invalid Gateway")
    end
  else
    config['gateway'] = ""
  end

  yn = $prompt.yes?("Set a DNS server?") do |q|
    q.default false
  end

  if yn
    config['dns'] = $prompt.ask("DNS Server:", required: true) do |q|
      q.validate(/^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/, "Invalid IPV4 Address")
    end
  else
    config['dns'] = ""
  end

  table << ['IPV4:', config['ipv4']]
  table << ['Netmask:', config['netmask']]
  table << ['Default Gateway:', config['gateway'] == "" ? 'None' : config['gateway']]
  table << ['DNS:', config['dns'] == "" ? 'None' : config['dns']]

  puts outputTable("New Network Settings", table)

  yn = $prompt.yes?("Are you sure you wish to reconfigure this network?") do |q|
    q.default false
  end

  if yn
    if configureInterface(network, config)
      $prompt.ok("Reconfigured #{network} - please restart the appliance.")
    else
      $prompt.error("Error reconfiguring #{network} network.")
    end
  else
    $prompt.warn("Cancelled.")
  end  
end
