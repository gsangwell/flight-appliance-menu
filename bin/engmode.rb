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

def engmode()
   user = `whoami`
   puts '' 
   puts '=========='
   puts "Alces Engineering Mode is now enabled for 1 hour."
   puts '=========='
   puts ''
   enable = `sudo /sbin/usermod engineer --shell /bin/bash`
   
   script = <<~SCRIPT
   #!/bin/bash
   sudo /sbin/usermod engineer --shell /sbin/nologin
   rm /tmp/disable.sh
   SCRIPT
   f = File.open("/tmp/disable.sh", 'w')
   f.puts script
   f.close
   system('sudo at now + 1 hour -f /tmp/disable.sh')
end

