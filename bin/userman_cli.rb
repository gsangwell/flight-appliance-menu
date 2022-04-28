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
  when 'sshkey'
    userSelectPrompt("Add SSH Key - Choose a user: ", :addKey)
  when 'upasswd'
    userSelectPrompt("Change Password - Choose a user: ", :changePasswd)
  when 'deluser'
    userSelectPrompt("Delete - Choose a user: ", :delUser)
  when 'getout'
    main()
  end
end

def usermenu()
  sel = $prompt.select('What would you like to do?') do |menu|
    menu.choice 'View System Users', 'viewusers'
    menu.choice 'Create System User', 'newuser'
    menu.choice 'Add SSH Keys for Users', 'sshkey'
    menu.choice 'Change Password for User', 'upasswd'
    menu.choice 'Delete System Users', 'deluser'
    menu.choice 'Return', 'getout'
  end
  return sel
end

def viewusers()
  if users = getUserList()
    return outputTable("Users", users.zip)
  else
    return false
  end
end

def addKey(user)

  key = getKey()

  if key.nil?
    $prompt.warn("Canceled.")
    return false
  end

  if addUserSSHKey(user, key)
    $prompt.ok("Added SSH key for user #{user}")
    return true
  end
  
  $prompt.error("Error adding SSH key for user #{user}")
  return false
end

def changePasswd(user)
  password = checkPasswd()
  crypt_pass = password.crypt('$6$' + SecureRandom.random_number(36 ** 8).to_s(36))

  if setPasswd(user, crypt_pass)
    $prompt.ok("Set password for user #{user}")
  else
    $prompt.error("Error setting password for user #{user}")
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
    $prompt.error("Passwords do not match - try again")
    rawPasswds = promptPasswd() 
  end
  return rawPasswds[0] 
end

def newUser()
  user = getUser()

  if getUserList().include?(user[0])
    $prompt.error("Error - user #{user[0]} already exists")
    return false
  end

  if createUser(user[0],user[1])
    $prompt.ok("User #{user[0]} created.")
  else
    $prompt.error("Failed to create #{user[0]}")
    return false
  end

  setpass = $prompt.yes?("Set password for user?") do |q|
    q.default false
  end

  if setpass
    changePasswd(user[0])
  end

  addkey = $prompt.yes?("Add SSH key for user?") do |q|
    q.default false
  end

  if addkey
    addKey(user[0])
  end
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

def getKey()
  key = $prompt.ask("Paste user's public SSH key: ")
  if !key.nil?
    return key.chomp
  else
    return nil
  end
end

def delUser(user)
  yn = $prompt.yes?("Are you sure you wish to delete user #{user}?") do |q|
    q.default false
  end

  if yn
    if deleteUser(user)
      $prompt.ok("Deleted user #{user}")
    else
      $prompt.error("Error deleting user #{user}")
    end
  end
end

def userSelectPrompt(prompt_msg="Select user: ", callback)
  choices = getUserList()
  choices << {name: "Cancel", value: "cancel"}
  user = $prompt.select("#{prompt_msg}", choices)
  return if user == "cancel"
  method(callback.to_sym).call(user)
end
