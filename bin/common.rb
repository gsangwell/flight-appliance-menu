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

$logFileLocation = File.open('/var/log/alces/flightappmenu',"a")
$logFileLocation.sync = true
$logger = Logger.new($logFileLocation)
$logger_stderr = Logger.new(STDERR)


#def checkUserGroup(user)
#  response = Open3.capture3('groups #{user}')
#  if response[2].success? 
#    groups = response[0].slice(response[0].index(":")..1)
#    return groups
#  else
#    return false
#  end
#end

def loginsh
  exec('/bin/bash -l')
end

def shell(cmd)
  pid = spawn(cmd)
  begin
    Process::wait pid
  rescue
    Process::kill('INT', pid)
    retry
  end
end

def writeHashToYaml(hash,filepath)
  begin 
    File.open(filepath,"w") do |f|
      f.write hash.to_yaml
    end
    appendLogFile("writeHashToYaml(hash,#{filepath})", hash.to_s)
  rescue
    quietError("writeHashToYaml(hash,#{filepath})",'Command Failed')
  end
end

def appendLogFile(source,action)
  user = `whoami`
  out = "User: " + user.strip + " - " + source + " " + action
  $logger.info(out)
end

def quietError(source,action)
  user = `whoami`
  out = "User: " + user.strip + " - " + source + " " + action 
  $logger.error(out)
end

def outputError(source,action)
  user = `whoami`
  out = "User: " + user.strip + " - " + source + " " + action
  $logger.error(out)
  $logger_stderr.error(out)
end

def runPlaybook(playbook, vars)
  extra_vars = ""

  vars.each do |var, value|
    extra_vars += " -e \"#{var}=\'#{value}\'\""
  end

  play = Open3.capture3("sudo /bin/ansible-playbook /opt/appliance/support/ansible/#{playbook} #{extra_vars}")

  if play[2].success?
    appendLogFile("runPlaybook(#{playbook}, #{extra_vars})",play.to_s)
    return true
  else
    quietError("runPlaybook(#{playbook}, #{extra_vars})",play.to_s) 
    return false
  end
end
