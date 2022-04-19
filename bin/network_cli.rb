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
    menu.choice 'List Interfaces', 'list'
    menu.choice 'Show Interface', 'show'
    menu.choice 'Return', 'ret'
  end
  case sel
  when 'list'
    puts networkInterfaces()
  when 'show'
    showMenu()
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

def showMenu()
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
    showInterface(sel)
  end  
end

def showInterface(name)
  interface = getInterfaceDetails(name)

  table = []
  table << ['Name:', interface['name']]
  table << ['Status:', interface['status']]
  table << ['Hardware Address:', interface['mac']]
  table << ['IPV4 Addresses:', interface['ipv4'].join(", ")]

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

def editInterface(interface)
  interface = getInterfaceDetails(interface)

  sel = $prompt.select('Choose an option') do |menu|
    menu.choice 'Disable', 'disable' if interface['status'] == "up"
    menu.choice 'Enable', 'enable' if interface['status'] != "up"
    menu.choice 'Return', 'ret'
  end
  case sel
  when 'disable'
    disableInterface(interface)
  when 'enable'
    enableInterface(interface)
  when 'ret'
    editMenu()
  end
end

def disableInterface(interface)
  puts "Disabled #{interface}"
end

def enableInterface(interface)
  puts "Enabled #{interface}"
end
