#/usr/bin/env ruby
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

def platform()
  return "Amazon AWS"
end

def extIp()
  begin 
    extIp = Net::HTTP.get('ifconfig.co', '/ip')
    appendLogFile('extIp()',extIp)
    return extIp.to_str
  rescue
    quietError('extIP()', 'Command Failed')
  end
end

def intIp()
  begin
    intIp = IPSocket.getaddress(Socket.gethostname)
    return intIp.to_str
    appendLogFile('intIp()',intIp)
  rescue
    quietError('intIP()', 'Command Failed')
  end
end

def hostname()
  begin 
    hostname = Socket.gethostname
    return hostname.to_str
    appendLogFile('hostname()',hostname) 
  rescue
    quietError('hostname()', 'Command Failed')
  end 
end

def identity(data)
  begin 
    document = JSON.load(Net::HTTP.get('169.254.169.254', 'latest/dynamic/instance-identity/document'))
    return document[data]
    appendLogFile('identity(data)', document[data])
  rescue
    quietError('identity(data)', 'Command Failed')
  end
end

def region()
  return identity('region')
end

def instanceType()
  return identity('instanceType')
end


def infoInstApiHandler()
  h = {}
  h.merge!('platform': platform())
  h.merge!('availability-zone': identity('availabilityZone'))
  h.merge!('instance-type': identity('instanceType'))
  h.merge!('external-ip': extIp().gsub("\n",""))
  h.merge!('internal-ip': intIp())
  h.merge!('hostname': hostname())
  return h
end