# How to build on Metal

Prerequisites:
  - A blank physical machine.
  - Internet connectivity to that machine.
  - Blank RHEL installation with configured networking

All packages required for installation will be installed by the provided scripts.

## Stage 1 - Base Installation

1. Boot into OS and ensure there is Network Connectivity on the physical machine.
2. Download and run the `build-menu.sh` and ` build-gui.sh` scripts.
3. Create your appliance configuration `/opt/appliance/cfg/config.yaml` from the provided example config `/opt/appliance/cfg/example.yaml`
4. Configure the appliance using Ansible: `ansible-playbook /opt/appliance/support/ansible/configure_appliance.yaml`

A good quick test to ensure that the base installation has succeeded is to invoke the API by calling:

 ```
[root@appliance ~]# /opt/flight/bin/ruby /opt/flight/opt/appliance/bin/api.rb extIp
{"external-ip":"203.80.69.243"}
 ```
This should return a JSON string showing the external IP address of the machine. 

## Stage 2 - User Configuration

Once the appliance has been installed, the user can access the GUI on the IP address specified in your config.yaml file. This will walk the end-user through a setup wizard for creating a user, reconfiguring the primary (first) network and setting up SSL.
