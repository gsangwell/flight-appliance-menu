#!/bin/bash -ex

FLIGHT_APPLIANCE_MENU_BRANCH=dev/fixes

######## Base Packages ###########
yum -y install patch autoconf automake bison bzip2 gcc-c++ libffi-devel libtool \
patch readline-devel ruby sqlite-devel zlib-devel glibc-headers glibc-devel openssl-devel make unzip wget git uuid
yum -y install epel-release
yum -y install openvpn easy-rsa bind-utils ansible python-netaddr

######## Ansible collections ###########
ansible-galaxy collection install community.crypto
ansible-galaxy install linux-system-roles.network

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

############ Engineer sudo rule ############
cat << EOF > /etc/sudoers.d/engineer
engineer    ALL=(ALL)       NOPASSWD: ALL
EOF

############ Operator sudo rule to allow system commands ############
cat << EOF > /etc/sudoers.d/10-alces-appliance
Cmnd_Alias OPS = /sbin/dmidecode,/sbin/lid,/bin/systemctl start openvpn-client@alces-support,/bin/systemctl stop openvpn-client@alces-support,/usr/bin/firewall-cmd --list-interfaces *,/usr/bin/firewall-cmd --query-masquerade *,/usr/bin/firewall-cmd --list-services *,/usr/bin/firewall-cmd --list-ports *,/bin/ansible-playbook /opt/appliance/support/ansible/*
%operators      ALL = NOPASSWD: OPS
EOF

######## Firewall ##############
yum install -y firewalld
systemctl enable firewalld
systemctl start firewalld

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

######## Grub spash screen ##############
cat << 'EOF' > /etc/default/grub
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_DISABLE_RECOVERY="true"
GRUB_BACKGROUND="/boot/grub2/alces.png"
GRUB_TIMEOUT=0
GRUB_CMDLINE_LINUX_DEFAULT="rhgb quiet"
EOF

cp /opt/appliance/support/build/alces.png /boot/grub2/alces.png 
grub2-mkconfig -o /boot/grub2/grub.cfg

######## Plymouth boot screen ##############
yum install -y plymouth plymouth-theme-spinner

cp -R /usr/share/plymouth/themes/spinner /usr/share/plymouth/themes/alces
rm -rf /usr/share/plymouth/themes/alces/spinner.plymouth
cp /opt/appliance/support/build/logo.png /usr/share/plymouth/themes/alces/watermark.png

cat << EOF > /usr/share/plymouth/themes/alces/alces.plymouth
[Plymouth Theme]
Name=Alces
Description=Alces boot screen
ModuleName=two-step

[two-step]
ImageDir=/usr/share/plymouth/themes/alces
HorizontalAlignment=.5
VerticalAlignment=.9
WatermarkHorizontalAlignment=.5
WatermarkVerticalAlignment=.5
Transition=none
TransitionDuration=0.0
BackgroundStartColor=0x000000
BackgroundEndColor=0x000000
EOF

plymouth-set-default-theme alces
dracut -f
