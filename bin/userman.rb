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
    newUser()
  when 'upasswd'
    promptUserPasswd()
  when 'getout'
    main()
  end
end

def usermenu()
  sel = $prompt.select('What would you like to do?') do |menu|
    menu.choice 'View System Users', 'viewusers'
    menu.choice 'Create System User', 'newuser'
    menu.choice 'Update Keys for Users', 'sshkey'
    menu.choice 'Change Password for User', 'upasswd'
    menu.choice 'Return', 'getout'
  end
  return sel
end

def promptUserPasswd()
  user = $prompt.select("Change Password - Choose a user: ", getUserList())
  password = checkPasswd()
  status = Open3.capture3("echo '#{password}' | sudo \/bin\/passwd #{user} --stdin")
  if status[2].success?
    puts "Success"
  else
    puts status
    puts "Fail"
  end
end

def promptPasswd()
  rawPasswd1 = $prompt.mask("Enter a password: ")
  rawPasswd2 = $prompt.mask("Confirm the password: ")
  rawPasswds = [rawPasswd1,rawPasswd2]
end

def checkPasswd()
  rawPasswds = promptPasswd()
  while rawPasswds[0] != rawPasswds[1]
    puts "Passwords do not match - try again"
    rawPasswds = promptPasswd() 
  end
  return rawPasswds[0] 
end

def getUserList()
  userlist = `sudo lid -g operators`.split
  userlist.each_with_index do |e,i|
    userlist[i] = e.gsub(/\(.*\)/, '')
  end
  return userlist 
end

def viewusers()
  users = getUserList()
  return outputTable("Users", users.zip)
end

def getUser()
  begin
    fname = $prompt.ask("New User's Full Name:", required: true)
    uname = $prompt.ask("Username: ", required: true)
  rescue
    main()
  end
  user = [] 
  user << uname
  user << fname
  return user
end

def newUser()
  user = getUser()
  createUser(user[0],user[1])
  setUserSSHKey(user[0],getKey())
end

def createUser(uname,fname)
  Open3.capture3("sudo \/sbin\/useradd #{uname} -G operators --comment \"#{fname}\" --shell /opt/appliance/bin/cli.rb")
end

def getKey()
  key = $prompt.multiline("User's public SSH key", help: "(Paste user's public key here and press CTRL+D to end)")
  return key
end

#Currently unused - used for reading keys from files.
def readKeyFromFile(file)
  key = []
  key << File.read(File.expand_path(file))
  return key.first
end

def setUserSSHKey(uname, key)
  begin
    FileUtils.mkdir_p "/home/#{uname}/.ssh"
    f = File.open("/home/#{uname}/.ssh/authorized_keys", 'w')
    f.write(key)
    f.chmod(0600)
    f.close
    FileUtils.chown(uname, uname, "/home/#{uname}/.ssh")
    FileUtils.chmod(0700, "/home/#{uname}/.ssh") 
    FileUtils.chown(uname, uname, "/home/#{uname}/.ssh/authorized_keys")
    return true 
  rescue
    return false
  end
end

def deleteUser(user)
  Open3.capture3("\/sbin\/userdel -f #{user}")
end

def deleteUserHandler(user)
  begin
    deleteUserStatus = deleteUser(user)
    if deleteUserStatus[2].success?
      return true
    else
      return false
    end
  rescue 
    raise StandardError
  end
end