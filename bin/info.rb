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

def infomenu()
  sel = $prompt.select('Choose an option') do |menu|
    menu.choice 'View Instance Information', 'infoinst'
    menu.choice 'View Internet Connectivity Status', 'inetstat'
    menu.choice 'View External IP Address', 'extip'
    menu.choice 'Return', 'ret'
  end
  case sel
  when 'infoinst'
    puts infoinst()
  when 'inetstat'
    puts inetstat()
  when 'extip'
    puts ''
    ip = extip()
    puts 'External IP Address: ' + ip
  when 'ret'
    main()
  end
end

def inetstat()
  info = []
  info << ['Ping 8.8.8.8? ', pingip()]
  info << ['Resolve alces-software.com? ', resolv()]
  info << ['Default Gateway', gw()]
  info << ['Primary DNS Server', dns('nameserver')]
  info << ['Search Domain', dns('search')]
  infotable = Terminal::Table.new :title => "Internet Connectivity Information", :rows => info
  return infotable
end

def pingip
  begin
    Net::Ping::External.new("8.8.8.8").ping?
    return "Responding"
  rescue
    return "Not Responding"
  end
end

def resolv()
  dns_resolver = Resolv::DNS.new()
  begin
    resolv = dns_resolver.getaddress("alces-software.com")
    return resolv.to_s
  rescue 
    return "ERROR - Cannot Resolve IP"
  end
end

def gw()
  gw = `/sbin/ip route show`[/default.*/][/\d+\.\d+\.\d+\.\d+/]
  return gw
end

def dns(type)
  dns = Resolv::DNS::Config.default_config_hash
  case type
  when 'nameserver'
    return dns[:nameserver].first
  when 'search'
    return dns[:search].first
  end
end