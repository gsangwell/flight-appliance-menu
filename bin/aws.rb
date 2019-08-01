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

def aws()
  puts "yeah aws"
end

def extip()
  extip = Net::HTTP.get('ifconfig.co', '/ip')
  return extip.to_str
end

def intip()
  intip = IPSocket.getaddress(Socket.gethostname)
  return intip.to_str
end

def hostname()
  hostname = Socket.gethostname
  return hostname.to_str
end

def identity(data)
  document = JSON.load(Net::HTTP.get('169.254.169.254', 'latest/dynamic/instance-identity/document'))
  return document[data]
end

def region()
  return identity('region')
end

def instanceType()
  return identity('instanceType')
end

def infoinst()
  info = []
  info << ['Platform', "Amazon AWS"]
  info << ['Region', region()]
  info << ['Instance Type', identity('instanceType')]
  info << ['External IP Address', extip()]
  info << ['Internal IP Address', intip()]
  info << ['Hostname', hostname()]
  infotable = Terminal::Table.new :title => "Instance Information", :rows => info
  return infotable
end