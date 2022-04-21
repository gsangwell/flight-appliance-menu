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
    userlistraw = Open3.capture3("sudo lid -g operators")
    if userlistraw[2].success?
      userlist = userlistraw[0].split
      userlist.each_with_index do |e,i|
        userlist[i] = e.gsub(/\(.*\)/, '')
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
  newUser = Open3.capture3("sudo \/sbin\/useradd #{uname} -G operators --comment \"#{fname}\" --shell #{$app_root}/bin/flightusershell.rb")
  if newUser[2].success?
    appendLogFile("createUser(#{uname},#{fname})",newUser.to_s)
    return true
  else
    quietError("createUser(#{uname},#{fname})",newUser.to_s)
    return false
  end
end

#Currently unused - used for reading keys from files.
#def readKeyFromFile(file)
#  key = []
#  key << File.read(File.expand_path(file))
#  return key.first
#end

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
    appendLogFile("setUserSSHKey(#{uname}, key)",'')
    return true 
  rescue
    quietError("setUserSSHKey(#{uname}, key)",'')
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
      appendLogFile("deleteUserHandler(#{user})",deleteUserStatus.to_s)
      return true
    else
      quietError("deleteUserHandler(#{user})",deleteUserStatus.to_s)
      return false
    end
  rescue 
    quietError("deleteUserHandler(#{user})",deleteUserStatus.to_s)
    raise StandardError
  end
end

def setPasswd(user, password)
  begin
    status = Open3.capture3("echo '#{user}:#{password}' | \/sbin\/chpasswd -e")

    if status[2].success?
      appendLogFile("setPasswd(#{user}, #{password})", status.to_s)
      return true
    else
      quietError("setPasswd(#{user}, #{password})", status.to_s)
      return false
    end
  end
end
