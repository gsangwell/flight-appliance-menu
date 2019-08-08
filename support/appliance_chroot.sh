#!/bin/bash -ex --login
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

yum -y -e0 install patch autoconf automake bison bzip2 gcc-c++ libffi-devel libtool \
patch readline-devel ruby sqlite-devel zlib-devel glibc-headers glibc-devel openssl-devel make

. /etc/profile

wget https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.3.tar.gz -O /tmp/ruby-2.6.3.tar.gz
cd /tmp
tar -zxvf ruby-2.6.3.tar.gz
cd ruby-2.6.3
./configure --prefix /opt/appliance/ruby-2.6.3
make -j4
make install
cd /opt/appliance
/opt/appliance/ruby-2.6.3/bin/bundle install --path vendor

groupadd engineers
groupadd operators
useradd engineer -G engineers -G operators
useradd alces-operator -G operators
usermod alces-operator --shell /opt/appliance/bin/cli.rb
usermod engineer --shell /sbin/nologin

sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

mkdir -p /home/engineer/.ssh
touch /home/engineer/.ssh/authorized_keys

cat << EOF > /home/engineer/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwLOsrj0oIyMKOKzSCpAA6EAYLivsVBUAeHJkc/xW+peoq9i1AfzVjEA3lgBnMrIksui9kvXbg0kQFgUegRlcb10mVR+KhLHRU8rmIrNzXfO8TVNaQhlF8WI71Q0oV5lWyH0CnPvr+LRJIhThXmzLou/lNd3frn1kTWlQKwPcaWFzniZzwJ7anWW2FlryVwUwPw+ki2b+D9o3QoVFn+eordKUDfMVIvdZjQfGSNJ1CXQh99XuOfUhphzpWH88fNEY8s3jk5SiOgf8s6dfl9wZEfNf6aU4MAViP1BKVd9wuLZ5Bv1tEMWUqN3Zp+hYiyzOkDYmviPPxk1BdqmAWUUQR
EOF

touch /etc/sudoers.d/10-alces-appliance
cat << EOF > /etc/sudoers.d/10-alces-appliance
Cmnd_Alias OPS = /sbin/usermod engineer --shell /bin/bash,/sbin/dmidecode,/sbin/usermod engineer --shell /sbin/nologin,/bin/at now + 1 hour -f /tmp/disable.sh,/sbin/useradd,/sbin/lid,/sbin/shutdown
%operators      ALL = NOPASSWD: OPS
EOF