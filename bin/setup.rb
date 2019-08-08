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

require 'tty'
require 'tty-prompt'
require 'artii'
require 'net/http'
require 'net/ping'
require 'resolv'
require 'terminal-table'
require 'yaml'
require 'json'
require 'open3'

require 'common'
require 'userman'
require 'engmode'
require 'info'
require 'shutdown'
require 'cluster'
require 'fileutils'

def setup()
  bios = `sudo /usr/sbin/dmidecode -s bios-version | /bin/tr "[:upper:]" "[:lower:]" | /bin/grep "amazon"`
  if bios.include? "amazon"
    provider = 'aws'
  else
    provider = 'other'
  end

  if provider == 'aws'
    require 'aws.rb'
  else 
    puts "Unsupported cloud service"
  end
end

