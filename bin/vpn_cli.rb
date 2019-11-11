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

def clientMenu()  
  sel = $prompt.select('Choose an option') do |menu|
    menu.choice 'View VPN Status', 'viewClients'
    menu.choice 'Assign VPN', 'promptAssignSlot'
    menu.choice 'Modify VPN', 'editClientAssignment'
    menu.choice 'View Assigned VPN Client Script', 'printVPNClientScript'
    menu.choice 'Generate Password for Client', 'promptGenClientPasswd'
    menu.choice 'Deconfigure VPN', 'deconfigureClient'
    menu.choice 'Return', 'getout'
  end
  return sel
end

def client()
  case clientMenu()
  when 'viewClients'
    viewVPNs()
  when 'printVPNClientScript'
    printVPNClientScript()
  when 'promptAssignSlot'
    promptAssignSlot()
  when 'editClientAssignment'
    editClientAssignment()
  when 'deconfigureClient'
    promptDeconfigureVPNClientAssignment()
  when 'promptGenClientPasswd'
    promptGenClientPasswd()
  when 'getout'
    main()
  end
end

def promptSelectUsedSlot()
  begin
    vpnSlot = $prompt.select("Choose a VPN Slot: ", slotListUsed.keys.to_a)
  rescue
    return nil
  end
  return vpnSlot
end 

def promptSelectClient()
  vpn = []
  slotListUsed.select do |k,v|
    vpn << k + ' ' + v['clientname']
  end
  choices = []
  vpn.each_with_index do |e,i|
     choices << {:name => e, :value => i}
  end
  vpnSlot = $prompt.enum_select("Choose a VPN Slot: ", vpn)  
end

def promptAssignSlot()
  vpnSlot = $prompt.select("Choose a VPN Slot to assign: ", slotListAvail.keys.to_a)
  clientName = $prompt.ask("Client Name: ", required: true)
  generateTemplate(vpnSlot)
  assignedVPNSlot = [clientName,vpnSlot]
  begin
    if assignSlot(clientName,vpnSlot)
      puts "Successfully Assigned Slot"
      return true
    else
      puts "Could not assign slot."
      client()
    end
  rescue
    outputError('promptAssignSlot()','Could not assign slot')
    client()
  end
end

def promptSelectSlot()
  begin
    vpnSlot = $prompt.select("Choose a VPN Slot to Modify: ", slotListUsed.keys.to_a)
    return vpnSlot
  rescue
    return nil
  end
end 

def promptGenClientPasswd()
  slot = promptSelectUsedSlot()
  if ! slot.nil?
    yn = $prompt.yes?("Are you sure you want to re-generate the password for #{slot}?") do |q|
      q.default false
      q.positive "Y"
      q.negative "N"
    end 
    if yn
      clientName = $vpnSlotFileConfig['slots'][slot]['clientname']
      begin
        rawPass = genClientPasswd(slot)
      rescue
        puts "Could not set Password."
      end
      if ! rawPass.nil?
        puts ""
        puts "One time password for #{slot} - #{clientName}: "
        puts ""
        puts "#{rawPass}"
      else
        puts "Could not set Password."
      end
    end
  end
end

def viewVPNs()
  $spinner.run do |spinner|
    table = []
    title = "Configured VPNs"
    slotListUsed.each_key do |slot|
      table << [slot, $vpnSlotFileConfig['slots'][slot]['clientname'], checkClientResponding($vpnSlotFileConfig['slots'][slot]['clientip'])]
    end
    header = ['VPN Slot', 'Client Name', 'Connectivity Status']
    #table = Terminal::Table.new :title => title, :rows => tableData
    #return table
    puts outputTable(title, table, header)
  end
end

def printVPNClientScript()
  vpnSlot = promptSelectUsedSlot()
  if ! vpnSlot.nil?
    script = getVPNClientScript(vpnSlot)
    if ! script.nil?
      puts script
    else
      puts "No VPNs assigned"
    end
  else
    puts "No VPNs assigned"
  end
end

def promptDeconfigureVPNClientAssignment()
  if slotListUsed.keys.empty?
    puts "No configured clusters"
    clientMenu()
  else
    deconfVPN = $prompt.select("Choose a VPN Slot to Deconfigure: ", slotListUsed.keys.to_a)
    if ! deconfigureVPNClient(deconfVPN)
      puts "Deconfigure Failed."
    else
      puts "Successfully Deconfigured #{deconfVPN}"
    end
  end
end

def editClientAssignment()
  vpnSlot = promptSelectSlot()
  if ! vpnSlot.nil?
    slotHash = $vpnSlotFileConfig ['slots'].select {|k,h| k == vpnSlot} 
    oldName = slotHash[vpnSlot]['clientname']
    newName = $prompt.ask("Client Name: ", required: true)
    if $vpnSlotFileConfig['slots'].each
      puts "Already a Client with that name"
      return false
    else
      deleteVPNClientUserStatus = deleteVPNClientUser(oldName)
      if ! deleteVPNClientUserStatus[2].success? 
        puts deleteVPNClientUserStatus[1] + ' ' + deleteVPNClientUserStatus[0] 
      end
      if File.exist?("/etc/openvpn/ccd-cluster/#{oldName}") 
        File.delete("/etc/openvpn/ccd-cluster/#{oldName}") 
      end
      File.open("/etc/openvpn/ccd-cluster/#{newName}", 'w') do |l|
        l.puts("ifconfig-push #{slotHash[vpnSlot]['clientip']} #{slotHash[vpnSlot]['serverip']}")
      end
      slotHash[vpnSlot]['clientname'] = newName
      vpnSlotFileWrite(slotHash)
      reloadSlotFileConfig()
      writeVPNUsersConf()
    end 
  else
    puts "No configured VPNs"
  end
end