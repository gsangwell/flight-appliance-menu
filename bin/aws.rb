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
  infoinst_table = infoinst_table_generate()
  puts outputTable(infoinst_table[0], infoinst_table[1])
end

def infoinst_table_generate()
  table = []
  table << ['Platform', "Amazon AWS"]
  table << ['Availability Zone', identity('availabilityZone')]
  table << ['Instance Type', identity('instanceType')]
  table << ['External IP Address', extip()]
  table << ['Internal IP Address', intip()]
  table << ['Hostname', hostname()]
  title = "Instance Information"
  ary = [title, table]
  return ary
end