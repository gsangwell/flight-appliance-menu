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

$spinner = TTY::Spinner.new(interval: 20)

def outputTable(title, tableData, *headerData)
  table = Terminal::Table.new :title => title, :rows => tableData, :headings => headerData
  return table
end

#def checkUserGroup(user)
#  response = Open3.capture3('groups #{user}')
#  if response[2].success? 
#    groups = response[0].slice(response[0].index(":")..1)
#    return groups
#  else
#    return false
#  end
#end

def flsh()
  pid = spawn('/opt/flight/bin/flight shell')
  begin
    Process.wait pid
  rescue Interrupt
    Process.kill('INT', pid)
    retry
  end
end

def writeHashToYaml(hash,filepath)
  File.open(filepath,"w") do |f|
    f.write hash.to_yaml
  end
end

