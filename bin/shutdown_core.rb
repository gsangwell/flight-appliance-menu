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
#

def shutdown()
  appendLogFile('shutdown()','Shutdown requested')
  rbt = Open3.capture3('sudo shutdown -h 1')
  if rbt[2].success?
    appendLogFile('shutdown()',"status #{sht}")
  else
    outputError('shutdown()', "Failed with response #{sht.to_s}")
  end
end

def reboot()
  appendLogFile('reboot()','Reboot requested')
  rbt = Open3.capture3('sudo shutdown -r 1')
  if rbt[2].success?
    appendLogFile('reboot()',"status #{rbt}")
  else
    outputError('reboot()', "Failed with response #{rbt.to_s}")
  end
end