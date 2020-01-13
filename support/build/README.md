# How to build on Metal

Prerequisites:
  - A blank physical machine.
  - Internet connectivity to that machine.
  - Blank RHEL installation with configured networking

All packages required for installation will be installed by the provided scripts.

## Stage 1 - Base Installation

1. Boot into OS and ensure there is Network Connectivity on the physical machine.
2. Download the `alceshub.bash` script from GitHub from the release you'd like to use. Releases are [located here](https://github.com/alces-software/flight-appliance-menu/releases)
3. If using a development release, set `DEV=1` in the script or by setting the variable before executable. This will use the Alces Flight Development repository, otherwise the production Repository will be used.
4. Run the script `bash alceshub.bash`.
5. Wait for the process to complete - this will take some time depending on hardware, usually ~20 minutes.

A good quick test to ensure that the base installation has succeeded is to invoke the API by calling:

 ```
[root@appliance ~]# /opt/flight/bin/ruby /opt/flight/opt/appliance/bin/api.rb extIp
{"external-ip":"203.80.69.243"}
 ```
This should return a JSON string showing the external IP address of the machine. 

## Stage 2 - Personalization 

Once the instance has the correct IP configuration for it's intended destination, the machine needs to be personalized to generate keys and certificates required for VPNs. 

1. Navigate to the 