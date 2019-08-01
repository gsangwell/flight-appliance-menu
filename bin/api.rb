#!/opt/appliance/ruby-2.6.3/bin/ruby
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

$LOAD_PATH << File.expand_path(__dir__ )
#$LOAD_PATH << "/usr/local/rvm/gems/ruby-2.6.3/gems"

ENV['BUNDLE_GEMFILE'] ||= File.join(__dir__, '../Gemfile')

require 'rubygems'
require 'bundler/setup'
require 'setup'

Bundler.setup(:default)

#ENV["PATH"]='/usr/local/rvm/gems/ruby-2.6.3/bin:/usr/local/rvm/rubies/ruby-2.6.3/bin'
#ENV["GEM_HOME"]='/usr/local/rvm/gems/ruby-2.6.3'

setup()

begin
  case ARGV[0]
  when 'infoinst'
    puts infoinst()
  when 'inetstat'
    puts inetstat()
  when 'extip'
    puts extip()
  when 'intip'
    puts intip()
  when 'region'
    puts region()
  when 'instanceType'
    puts instanceType()
  when 'engmode'
    engmode()
  when 'newuser'
    createuser(ARGV[1],ARGV[2])
  when 'userkey'
    sshkey(ARGV[1],keyfromfile(ARGV[2]))
  when 'viewusers'
    puts viewusers()
  else
    puts "Invalid Command"
  end

  
rescue => exception
  
else
  
end