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

def usermanager()
  case usermenu()
  when 'viewusers'
    puts viewusers()
  when 'newuser'
    newuser()
  when 'getout'
    main()
  end
end

def usermenu()
  sel = $prompt.select('What would you like to do?') do |menu|
    menu.choice 'View System Users', 'viewusers'
    menu.choice 'Create System User', 'newuser'
    menu.choice 'Update Keys for Users', 'sshkey'
    menu.choice 'Return', 'getout'
  end
  return sel
end

def viewusers()
  users = `sudo lid -g operators`.split
  userstable = Terminal::Table.new :title => "Users", :rows => users.zip
  return userstable
end

def getuser()
  fname = $prompt.ask("New User's Full Name:", required: true)
  uname = $prompt.ask("Username: ", required: true)
  user = [] 
  user << uname
  user << fname
  return user
end

def newuser()
  user = getuser()
  createuser(user[0],user[1])
  sshkey(user[0],getkey())
end

def createuser(uname,fname)
  system("sudo \/sbin\/useradd #{uname} -G operators --comment \"#{fname}\" --shell /opt/appliance/bin/cli.rb")
end

def getkey()
  key = $prompt.multiline("User's public SSH key", help: "(Paste user's public key here and press CTRL+D to end)")
  return key
end

def keyfromfile(file)
  key = []
  key << File.read(File.expand_path(file))
  return key
end

def sshkey(uname, key)
  FileUtils.mkdir_p "/home/#{uname}/.ssh"
  f = File.open("/home/#{uname}/.ssh/authorized_keys", 'w')
  f.write(key.first)
  f.chmod(0600)
  f.close
  FileUtils.chown(uname, uname, "/home/#{uname}/.ssh")
  FileUtils.chmod(0700, "/home/#{uname}/.ssh") 
  FileUtils.chown(uname, uname, "/home/#{uname}/.ssh/authorized_keys")
end
