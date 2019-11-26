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

def shutdown_cli()
  yn = $prompt.yes?("Are you sure you wish to shut down this instance?") do |q|
    q.default false
    q.positive "Y"
    q.negative "N"
  end
  appendLogFile('shutdown_cli()', yn.to_s)
  if yn
    shutdown()
  else 
    main()
  end
end

def reboot_cli()
  yn = $prompt.yes?("Are you sure you wish to reboot this instance?") do |q|
    q.default false
    q.positive "Y"
    q.negative "N"
  end
  appendLogFile('reboot_cli()', yn.to_s)
  if yn
    reboot()
  else 
    main()
  end
end