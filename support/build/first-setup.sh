#!/bin/bash

echo -e "\nAlces Hub - Setup:"
echo -e "-------------------"

# Config
echo -n "Enter your appliance name: "; read APPL_NAME
echo -n "Enter your Alces Support Username: "; read VPN_USERNAME
echo -n "Enter your Alces Support Password: "; read -s VPN_PASSWORD
echo "$VPN_PASSWORD" | sed 's/./*/g'

# Configure appliance
sudo sed -i "s/appliance_name:/appliance_name: ${APPL_NAME}/g" /opt/appliance/cfg/config.yaml
host_name="${APPL_NAME}.appliance.alces.network"
sudo hostnamectl set-hostname "$host_name"
sudo bash -c 'cat >> /etc/hosts' << EOF
127.0.0.1     ${APPL_NAME}
EOF

# Configure vpn
sudo bash -c 'cat > /etc/openvpn/client/auth.alces-support' << EOF
${VPN_USERNAME}
${VPN_PASSWORD}
EOF
sudo chmod 600 /etc/openvpn/client/auth.alces-support

# Test vpn
echo -n "Testing support VPN.. "
sudo systemctl start openvpn-client@alces-support
sleep 15

if  ping -c 1 10.178.0.1 > /dev/null ; then
    echo "success!"
else
    echo "failure!"
fi

# Turn off support VPN
sudo systemctl stop openvpn-client@alces-support

# Start GUI services if installed
if [ -f  "/opt/appliance-gui/.env" ] ; then
    sudo systemctl enable flight-terminal
    sudo systemctl enable appliance-gui
    sudo systemctl enable nginx
    sudo systemctl start flight-terminal
    sudo systemctl start appliance-gui
    sudo systemctl start nginx
fi

echo -e "Appliance setup complete!"

# Switch shell back
sudo usermod operator1 --shell /opt/appliance/bin/flightusershell.rb

# Remove additional sudo rule
sudo rm -rf /etc/sudoers.d/operator1
