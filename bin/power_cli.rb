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

def power_cli()
  sel = $prompt.select('Choose an option') do |menu|
    menu.choice 'Shutdown Alces Hub', 'shutdown'
    menu.choice 'Reboot Alces Hub', 'reboot'
    menu.choice 'Return', 'ret'
  end
  case sel
  when 'shutdown'
    shutdown_cli()
  when 'reboot'
    reboot_cli()
  when 'ret'
    main()
  end
end

def shutdown_cli()
  yn = $prompt.yes?("Are you sure you wish to shut down this instance?") do |q|
    q.default false
  end
  appendLogFile('shutdown_cli()', yn.to_s)
  if yn
    if shutdown()
      $prompt.ok("Shutdown requested.")
    else
      $prompt.error("Error requesting shutdown.")
    end
  else
    main()
  end
end

def reboot_cli()
  yn = $prompt.yes?("Are you sure you wish to reboot this instance?") do |q|
    q.default false
  end
  appendLogFile('reboot_cli()', yn.to_s)
  if yn
    if reboot()
      $prompt.ok("Reboot requested.")
    else
      $prompt.error("Error requesting reboot.")
    end
  else
    main()
  end
end
