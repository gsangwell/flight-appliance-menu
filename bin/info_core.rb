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

def pingIpTest()
  begin
    Net::Ping::External.new("8.8.8.8").ping?
    return true
  rescue
    return false
  end
end

def extDNS
  begin
    ssl_name=`echo $(basename $(echo /opt/flight/etc/ssl/certs-hub-*) | sed 's/^certs-//g')`.chomp
    dnsName = "https://#{ssl_name}.appliance.alces.network"
  rescue
    quietError("extDNS()", "Could not get SSL name")
    return false
  end
end


def pingIp()
  if pingIpTest()
    return "Responding"
  else
    return "Not Responding"
  end
end

def resolv(address)
  dns_resolver = Resolv::DNS.new()
  begin dns_resolver.getaddress(address) 
    appendLogFile("resolv()", "Resolved #{address}")
    return true
  rescue
    quietError("resolv()", "Could not resolve #{address}") 
    return false
  end
end


def gw()
  begin
    gw = Open3.capture3("/sbin/ip route show")
    out = gw[0][/default.*/][/\d+\.\d+\.\d+\.\d+/]
    appendLogFile('gw()', out)
    return out
  rescue
    quietError('gw()', gw.to_s)
    return false
  end
end

def dns(*type)
  begin
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
  rescue
    quietError("dns(#{type})", dns.to_s)
  end
end
