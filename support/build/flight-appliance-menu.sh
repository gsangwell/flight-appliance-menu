#!/bin/bash -ex

FLIGHT_APPLIANCE_MENU_BRANCH=dev/fixes

######## Base Packages ###########
yum -y install patch autoconf automake bison bzip2 gcc-c++ libffi-devel libtool \
patch readline-devel ruby sqlite-devel zlib-devel glibc-headers glibc-devel openssl-devel make unzip wget git
yum -y install epel-release
yum -y install openvpn easy-rsa bind-utils

######### Install RVM ##########
if ! gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB ; then
    curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
    curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
fi

curl -sSL https://get.rvm.io | bash -s stable --ruby
source /etc/profile.d/rvm.sh
rvm install "ruby-2.7.1"
rvm --default use 2.7.1

######### Install flight runway & related tools #########
wget https://repo.openflighthpc.org/openflight.repo -O /etc/yum.repos.d/openflight.repo
yum -y makecache
yum -y install flight-runway

######## Users and groups for appliance ############
groupadd engineers
groupadd operators

########  Engineer user - for alces use ############
useradd engineer -G engineers -G operators
usermod -L engineer
usermod engineer --shell /sbin/nologin
mkdir -p /home/engineer/.ssh
cat << EOF > /home/engineer/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDj1OjrNkAv3Jroy7EggSv9dSEuzCKvS8l6oGN5b9OdIcL0kaIJzEk4P49M5zqPpQFlpjR+JYOsKBwnRVSx2ruu6CX3uYgb1O56H6MPvPNSJkt/XMGVs9PduiR/3s6cfKj3JsSFK/ECWLXL/AvR7anbdhAMsM4nFnYmveaI/giWlBPfldPgGoTQxH2Xc4DasuhOxC5RruWcMpr7WMWGzVeJbQepbUF2WO/JHFQ29lMBWJP+TDKIaPeYQp90kKQzp2VrOVUQptO+K5a1txiORzwFdaR/TmdL4dnlE42lf5OyRSnRTWKuvpI51B97cLZoczDe1jkHTJiYbjJFhfr+rjpe/rGrKooNH002lNcIolXe2rfgSZ08OiL1df8rFAZ4kCrxo7ycdsRqTHWHJu4ggWpKXzieqEtxaMgMl8yPYvRXkq6LLNyLbaB9yOcv2Q/qQ1TmzZ7L6z9BWwg18m5MbWqOYjlr7FA4apWvZpMaSPN80YTM1cdHI0npLrsleeTPAE= clusterclub
EOF
chmod 600 /home/engineer/.ssh/authorized_keys

############ Alces operator - default user account ############
useradd alces-operator -G operators
usermod alces-operator --shell /opt/appliance/bin/cli.rb
usermod -L alces-operator

############ Operator sudo rule to allow system commands ############
cat << EOF > /etc/sudoers.d/10-alces-appliance
Cmnd_Alias OPS = /sbin/usermod engineer --shell /bin/bash,/sbin/dmidecode,/sbin/usermod engineer --shell /sbin/nologin,/sbin/useradd,/sbin/lid,/sbin/shutdown,/bin/passwd,/bin/systemctl start openvpn@alces-support,/bin/systemctl stop openvpn@alces-support
%operators      ALL = NOPASSWD: OPS
EOF

######## OpenVPN setup for Alces support ######
cat << EOF > /etc/openvpn/alces-support.conf
client
dev tun0
proto tcp
remote gateway.alces-flight.com 2005
resolv-retry infinite
nobind
persist-key
persist-tun
<ca>
-----BEGIN CERTIFICATE-----
MIIE3TCCA8WgAwIBAgIJALkwLvje8YdBMA0GCSqGSIb3DQEBCwUAMIGgMQswCQYD
VQQGEwJVSzEUMBIGA1UECAwLT3hmb3Jkc2hpcmUxDzANBgNVBAcMBk94Zm9yZDEZ
MBcGA1UECgwQQWxjZXMgRmxpZ2h0IEx0ZDEXMBUGA1UECwwOSW5mcmFzdHJ1Y3R1
cmUxETAPBgNVBAMMCENoYW5nZU1lMSMwIQYJKoZIhvcNAQkBFhRzc2xAYWxjZXMt
ZmxpZ2h0LmNvbTAeFw0yMDAyMDYxNjU1NTRaFw0zMDAyMDMxNjU1NTRaMIGgMQsw
CQYDVQQGEwJVSzEUMBIGA1UECAwLT3hmb3Jkc2hpcmUxDzANBgNVBAcMBk94Zm9y
ZDEZMBcGA1UECgwQQWxjZXMgRmxpZ2h0IEx0ZDEXMBUGA1UECwwOSW5mcmFzdHJ1
Y3R1cmUxETAPBgNVBAMMCENoYW5nZU1lMSMwIQYJKoZIhvcNAQkBFhRzc2xAYWxj
ZXMtZmxpZ2h0LmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMSm
kQhLgB2qWQ3sL1Q2GwLvdmylR0u8zaUc+vLE966c2Pyd6DcZw30v/KjvguF9otXj
Z835LShSnPTeOZiy3t2L/p0colJML2pECFkjneKl3Tk0Xyns897vnBQTwgU0+qI8
brgeoq4CTokBw6uskLXQ9WBA+eMk5hYe4uh+ga5x716N4HH13Bqp9qCj5IEcPV2C
Jfl3hTQxqKMYAlfrsGyxZ+KEG8QEkA7d9kXmqyrGBzM25ANY/b9LQG2U7geLnhSa
ZDysaOiodksoWaKgi8fqoWUmBcQUCHc6cDsOVx4cBEncmy4JOtYeWz6RkczItIkT
8PqkTT2pXUEOxF/UfI0CAwEAAaOCARYwggESMB0GA1UdDgQWBBStiZw19XmYwnFv
dR06Pe6sJiPqhDCB1QYDVR0jBIHNMIHKgBStiZw19XmYwnFvdR06Pe6sJiPqhKGB
pqSBozCBoDELMAkGA1UEBhMCVUsxFDASBgNVBAgMC094Zm9yZHNoaXJlMQ8wDQYD
VQQHDAZPeGZvcmQxGTAXBgNVBAoMEEFsY2VzIEZsaWdodCBMdGQxFzAVBgNVBAsM
DkluZnJhc3RydWN0dXJlMREwDwYDVQQDDAhDaGFuZ2VNZTEjMCEGCSqGSIb3DQEJ
ARYUc3NsQGFsY2VzLWZsaWdodC5jb22CCQC5MC743vGHQTAMBgNVHRMEBTADAQH/
MAsGA1UdDwQEAwIBBjANBgkqhkiG9w0BAQsFAAOCAQEAHuEL/hOZVN4Rkt/Tkxp2
/miWerlRbSBTKbFt0TA1MX+ecGerQ5Zpcdx5kYswJzvYfRDVSy/u2Wkw+euYNUpl
ojEu/iF1Vo3RR3fyj3BuVBrCfaNdTyBj9X3OXs6cOD/zpOos+yXVojnFr1lTtjn0
zQo7RpNVvKnatPKirh6nNI0sPEEX1dR6+P5Tb+mt9BL5pIA9y/qU5ibC4AGsJFVq
A++V1PiI35cxNI1VPasWcNR6WQnSxfwZXry7M2bosQe1PwPFb2c4JL2xjc5GryI/
5uGoC1ghA/g030xNc8LNWmeXM8FPyzPweiRseJ+Sdi9Vjx9NekN3QFBitO2Xf5cZ
bQ==
-----END CERTIFICATE-----
</ca>
auth-user-pass auth.alces-support
ns-cert-type server
comp-lzo
verb 3
EOF

# Ask for Alces support username and password
echo -n "Enter your Alces Support Username: "; read VPN_USERNAME
echo -n "Enter your Alces Support Password: "; read VPN_PASSWORD
cat << EOF > /etc/openvpn/auth.alces-support
${VPN_USERNAME}
${VPN_PASSWORD}
EOF
chmod 600 /etc/openvpn/auth.alces-support

# Test VPN
systemctl start openvpn@alces-support
sleep 15

if  ping -c 1 10.178.0.1 ; then
    echo "Alces Support VPN setup complete!"
else
    echo "Alces Support VPN setup incomplete!"
fi

# Turn off support VPN
systemctl stop openvpn@alces-support

######## Firewall ##############
yum install -y firewalld
systemctl enable firewalld
firewall-offline-cmd --set-default-zone=external
firewall-offline-cmd --add-port 80/tcp --zone external
firewall-offline-cmd --add-port 443/tcp --zone external
firewall-offline-cmd --new-zone alces-support
firewall-offline-cmd --zone alces-support --add-interface tun0
firewall-offline-cmd --zone alces-support --set-target ACCEPT
systemctl start firewalld
firewall-cmd --reload

######## Install menu system ##############
git clone https://github.com/gsangwell/flight-appliance-menu.git -b $FLIGHT_APPLIANCE_MENU_BRANCH /opt/appliance
cd /opt/appliance
bundle install --path vendor

mkdir -p /var/log/alces/
touch /var/log/alces/flightappmenu
chown root:operators /var/log/alces
chown root:operators /var/log/alces/flightappmenu
chmod 775 /var/log/alces
chmod 664 /var/log/alces/flightappmenu
