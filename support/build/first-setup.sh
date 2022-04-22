#!/bin/bash

echo -e "\nAlces Hub - Setup:"
echo -e "-------------------"

# Check selinux disabled & ssh password enabled
selin=$(sudo getenforce)
sshpass=$(ssh -n -o Batchmode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null DOES_NOT_EXIST@localhost 2>&1 | grep -c password)

if [[ "$selin" != "Disabled" ]] ; then
    echo -e "Please disable Selinux, reboot and re-run this setup."
    exit 1
fi

if [ $sshpass -eq 0 ] ; then
    echo -e "Please enable SSH password logins and re-run this setup."
    exit 1
fi

# Config
echo -n "Enter appliance hostname: "; read APPL_NAME
echo -n "Enter Alces Support Username: "; read VPN_USERNAME
echo -n "Enter Alces Support Password: "; read -s VPN_PASSWORD
echo "$VPN_PASSWORD" | sed 's/./*/g'

# Configure appliance
sudo sed -i "s/appliance_name:/appliance_name: ${APPL_NAME}/g" /opt/appliance/cfg/config.yaml
sudo hostnamectl set-hostname "$APPL_NAME"

sudo bash -c 'cat >> /etc/hosts' << EOF
127.0.0.1    ${APPL_NAME}
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
echo -e "Now configure /opt/appliance/cfg/config.yaml"
