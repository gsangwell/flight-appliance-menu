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
  return "Microsoft Azure"
end

def extIp()
  extIp = Net::HTTP.get('ifconfig.co', '/ip')
  return extIp.to_str
end

def intIp()
  intIp = IPSocket.getaddress(Socket.gethostname)
  return intIp.to_str
end

def hostname()
  hostname = Socket.gethostname
  return hostname.to_str
end

def identity()
  uri = URI('http://169.254.169.254/metadata/instance?api-version=2019-03-11')
  req = Net::HTTP::Get.new(uri)
  req['Metadata'] = true
  response = Net::HTTP.start(uri.hostname, uri.port) {|http|
    http.request(req)
  }
  document = JSON.load(response.body)
  return document
end

def region()
  return identity['compute']['location']
end

def instanceType()
  return identity['compute']['vmSize']
end

def infoInstApiHandler()
  h = {}
  h.merge!('platform': platform())
  h.merge!('region': region())
  h.merge!('instance-type': instanceType())
  h.merge!('external-ip': extIp().gsub("\n",""))
  h.merge!('internal-ip': intIp())
  h.merge!('hostname': hostname())
  return h.to_json
end