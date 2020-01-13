#!/bin/bash -ex
# Copyright (C) 2019-present Alces Flight Ltd.

# To be run on metal instances that do not have a cloud provider 
# metadata service and do not run cloud-init.
# Requires flight-appliance-menu-0.0.4-dev1 or later.

echo "Checking Network Connectivity..."
wget -q --spider http://google.com
if [ $? -eq 0 ]; then
    echo "Internet Connectivity Available - continuing"
else
    echo "No Internet Connectivity - check your Network Settings"
    exit 1
fi

/opt/flight/bin/ruby /opt/flight/opt/appliance/bin/api.rb extIp

chmod +x /var/lib/firstrun/scripts/*
./var/lib/firstrun/scripts/appliancegui.bash
./var/lib/firstrun/scripts/ssl-certs.bash
./var/lib/firstrun/scripts/vpn.bash

cat << EOF > /opt/flight/opt/appliance/bin/clilaunch
#!/bin/bash
chvt 3
export PATH=/usr/bin/:$PATH ; setsid sh -c '/opt/flight/bin/ruby /opt/flight/opt/appliance/bin/cli.rb $@ <> /dev/tty3 >&0 2>&1'
EOF