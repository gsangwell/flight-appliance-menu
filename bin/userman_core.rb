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

def getUserList()
  begin
    userlistraw = Open3.capture3("sudo lid -g operators -n")
    if userlistraw[2].success?
      userlist = []
      userlistraw[0].split.each do |u|
        next if u == "alces-operator"
        userlist << u
      end
      return userlist 
    else
      raise StandardError
    end
  rescue
    quietError('getUserList()', "Command failed with: #{userlistraw}")
    return false
  end
end

def createUser(uname,fname)
  if runPlaybook("add_operator.yaml", {"username":uname, "name":fname})
    appendLogFile("createUser(#{uname},#{fname})",'')
    return true
  else
    quietError("createUser(#{uname},#{fname})",'')
    return false
  end
end

def deleteUser(uname)
  if runPlaybook("remove_operator.yaml", {"username":uname})
    appendLogFile("deleteUser(#{uname})",'')
    return true
  else
    quietError("deleteUser(#{uname})",'')
    return false
  end
end

#Currently unused - used for reading keys from files.
#def readKeyFromFile(file)
#  key = []
#  key << File.read(File.expand_path(file))
#  return key.first
#end

def addUserSSHKey(uname, key)
  if runPlaybook("add_key.yaml", {"username":uname, "pubkey":key})
    appendLogFile("addUserSSHKey(#{uname}, #{key})",'')
    return true
  else
    quietError("addUserSSHKey(#{uname}, #{key})",'')
    return false
  end
end

def deleteUser(user)
  if runPlaybook("remove_operator.yaml", {"username":user})
    appendLogFile("deleteUser(#{user})", '')
    return true
  else
    quietError("deleteUser(#{user})", '')
    return false
  end
end

def setPasswd(user, password)
  password = password.gsub('$', '\$')
  if runPlaybook("change_password.yaml", {"username":user, "password":password})
    appendLogFile("setPasswd(#{user}, #{password})", '')
    return true
  else
    quietError("setPasswd(#{user}, #{password})", '')
    return false
  end
end
