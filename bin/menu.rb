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

trap('INT') { puts "Quitting..."; exit }

ascprint = Artii::Base.new :font => 'slant'
welcome = ascprint.asciify('Alces Appliance')
puts welcome


$prompt = TTY::Prompt.new

def mainmenu()
  sel = $prompt.select('What would you like to do?') do |menu|
    menu.choice 'View System Information', 'info'
    menu.choice 'User Management', 'uman'
    menu.choice 'Enable Alces Engineering Mode', 'engmode'
    menu.choice 'View and Configure Clusters', 'cluster'
    menu.choice 'Shutdown Alces Appliance', 'shutdown'
    menu.choice 'Quit Alces Engineering Menu', 'getout'
  end
  return sel
end

def getout()
  exit
end

def main()
  setup()
  loop do
    puts "\n"
    case mainmenu()
    when 'info'
      infomenu()
    when 'uman'
      usermanager()
    when 'engmode'
      engmode()
    when 'shutdown'
      shutdown()
    when 'getout'
      getout()
    when 'cluster'
      cluster()
    else
      puts 'invalid'
    end
  end
end
