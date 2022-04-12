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

def support_cli()
  sel = $prompt.select('Choose an option') do |menu|
    menu.choice 'View Support Status', 'supportstatus' if getSupportStatus()
    menu.choice 'Enable Remote Support', 'enablesupport' if !getSupportStatus()
    menu.choice 'Disable Remote Support', 'disablesupport' if getSupportStatus()
    menu.choice 'Return', 'ret'
  end
  case sel
  when 'supportstatus'
    puts supportStatus()
  when 'enablesupport'
    supportEnable()
  when 'disablesupport'
    supportDisable()
  when 'ret'
    main()
  end
end

def supportStatus()
  table = []
  table << ['Remote Support Enabled', getSupportStatus()]
  table << ['Enabled Since', getSupportEnabledSince()]
  table << ['Ping Support Hub', pingRemoteSupport()]
  title = "Remote Support Information"
  puts outputTable(title, table)
end

def supportEnable()
  enableRemoteSupport()

  if getSupportStatus()
    puts "+------------------------------+"
    puts "|    Remote Support Enabled    |"
    puts "+------------------------------+"
  else
    puts "==========\nError enabling Alces Remote Support.\n=========="
  end
end

def supportDisable()
  disableRemoteSupport()

  if !getSupportStatus()
    puts "+-------------------------------+"
    puts "|    Remote Support Disabled    |"
    puts "+-------------------------------+"
  else
    puts "==========\nError disabling Alces Remote Support.\n=========="
  end
end
