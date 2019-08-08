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

def inetstat_table_generate()
  table = []
  table << ['Ping 8.8.8.8? ', pingip()]
  table << ['Resolve alces-software.com? ', resolv('alces-software.com')]
  table << ['Default Gateway', gw()]
  table << ['Primary DNS Server', dns('nameserver').first]
  table << ['Search Domain', dns('search').first]
  title = "Internet Connectivity Information"
  ary = [title, table]
  return ary
end

def inetstat()
  inetstat_table = inetstat_table_generate()
  puts outputTable(inetstat_table[0], inetstat_table[1])
end

def pingip_test()
  begin
    Net::Ping::External.new("8.8.8.8").ping?
    return true
  rescue
    return false
  end
end

def pingip()
  if pingip_test()
    return "Responding"
  else
    return "Not Responding"
  end
end

def resolv(address)
  dns_resolver = Resolv::DNS.new()
  begin dns_resolver.getaddress(address) 
    return true
  rescue 
    return false
  end
end

def gw()
  begin
    gw = `/sbin/ip route show`[/default.*/][/\d+\.\d+\.\d+\.\d+/]
    return gw
  rescue
    return false
  end
end

def dns(*type)
  dns = Resolv::DNS::Config.default_config_hash
  case type[0]
  when 'nameserver'
    return dns[:nameserver]
  when 'search'
    return dns[:search]
  else
    hash = {}
    hash.merge!(nameservers: dns[:nameserver])
    hash.merge!(search: dns[:search])
    return hash
  end
end