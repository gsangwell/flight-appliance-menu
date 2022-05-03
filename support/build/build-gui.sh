#!/bin/bash

FLIGHT_GUI_BRANCH=master

########### Flight Terminal ##################

yum -y install postgresql-server postgresql-devel

curl -sL https://rpm.nodesource.com/setup_8.x | bash -
yum -y install nodejs-8.12.0

curl -sL https://dl.yarnpkg.com/rpm/yarn.repo -o /etc/yum.repos.d/yarn.repo
yum -y install yarn

git clone https://github.com/alces-software/flight-terminal-service /opt/flight-terminal-service

cat << EOF > /opt/flight-terminal-service/.env
INTERFACE=127.0.0.1
CMD_EXE="/bin/sudo"
CMD_ARGS_FILE="cmd.args.json"
INTEGRATION=no-auth-localhost
EOF

cat << EOF > /opt/flight-terminal-service/cmd.args.json
{
  "args": [
    "TERM=linux",
    "/opt/appliance/bin/flightterminalshell.sh"
  ]
}
EOF

cd /opt/flight-terminal-service
yarn

cat << EOF > /usr/lib/systemd/system/flight-terminal.service
[Unit]
Description=Flight terminal service
Requires=network.target
[Service]
Type=simple
User=root
WorkingDirectory=/opt/flight-terminal-service
ExecStart=/usr/bin/bash -lc 'yarn run start'
TimeoutSec=30
RestartSec=15
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /usr/lib/systemd/system/flight-terminal.service

########### Appliance GUI ##################

yum -y -e0 install pam-devel
git clone https://github.com/gsangwell/flighthub-gui.git -b $FLIGHT_GUI_BRANCH /opt/appliance-gui
cd /opt/appliance-gui
cp /opt/appliance-gui/.env.example /opt/appliance-gui/.env
touch /opt/appliance/cluster.md

# Configure
sed -i "s/APPLIANCE_INFORMATION_FILE_PATH=examples\/appliance_information_example/APPLIANCE_INFORMATION_FILE_PATH=\/opt\/appliance-gui\/cluster.md/g" .env
sed -i "s/^#SECRET_KEY_BASE=.*/SECRET_KEY_BASE=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 25)/g" .env
sed -i "s/^#RAILS_SERVE_STATIC_FILES/RAILS_SERVE_STATIC_FILES/g" .env

bundle install

cat << EOF > /usr/lib/systemd/system/appliance-gui.service
[Unit]
Description=Alces Flight Appliance GUI
Requires=network.target postgresql.service
[Service]
Type=simple
User=root
WorkingDirectory=/opt/appliance-gui
ExecStart=/usr/bin/bash -lc 'bundle exec bin/rails server -e production --port 3000'
TimeoutSec=30
RestartSec=15
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /usr/lib/systemd/system/appliance-gui.service

postgresql-setup initdb
sed -i 's/peer$/trust/g;s/ident$/trust/g' /var/lib/pgsql/data/pg_hba.conf
systemctl enable postgresql
systemctl restart postgresql

RAILS_ENV=production bin/rails db:create
RAILS_ENV=production bin/rails db:schema:load
RAILS_ENV=production bin/rails data:migrate
RAILS_ENV=production bin/rails db:seed
rake assets:precompile

########### Nginx ##################
yum -y install nginx
rm -rf /etc/nginx/*

cat << 'EOF' > /etc/nginx/nginx.conf
user nobody;
worker_processes 1;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;
events {
    worker_connections 1024;
}
http {
    #include /etc/nginx/mime.types;
    default_type application/octet-stream;
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;
    sendfile on;
    #tcp_nopush on;
    keepalive_timeout 65;
    gzip on;
    include /etc/nginx/http.d/*.conf;
}
EOF

mkdir /etc/nginx/http.d

cat << EOF > /etc/nginx/http.d/http.conf
server {
  listen 80 default;
  include /etc/nginx/server-http.d/*.conf;
}
EOF

cat << EOF > /etc/nginx/http.d/https.conf
server {
  listen 443 ssl default;
  include /etc/nginx/server-https.d/*.conf;
}
EOF

mkdir /etc/nginx/server-http{,s}.d

cat << EOF > /etc/nginx/server-https.d/ssl-config.conf
client_max_body_size 0;
# add Strict-Transport-Security to prevent man in the middle attacks
add_header Strict-Transport-Security "max-age=31536000";
ssl_certificate /etc/ssl/nginx/fullchain.pem;
ssl_certificate_key /etc/ssl/nginx/key.pem;
ssl_session_cache shared:SSL:1m;
ssl_session_timeout 5m;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_prefer_server_ciphers on;
EOF

mkdir /etc/ssl/nginx

cat << 'EOF' > /etc/nginx/server-https.d/appliance-gui.conf
location / {
     proxy_pass http://127.0.0.1:3000;
     proxy_redirect off;
     proxy_set_header X-Real-IP  $remote_addr;
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_set_header Host $http_host;
     proxy_set_header X-NginX-Proxy true;
     proxy_set_header X-Forwarded-Proto $scheme;
     proxy_temp_path /tmp/proxy_temp;
}
EOF

cat << 'EOF' > /etc/nginx/server-https.d/flight-terminal.conf
location /terminal-service {
     proxy_pass http://127.0.0.1:25288;
     proxy_redirect off;
     proxy_set_header X-Real-IP  $remote_addr;
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_set_header Host $http_host;
     proxy_set_header X-NginX-Proxy true;
}
EOF

cat << 'EOF' > /etc/nginx/server-http.d/redirect-http-to-https.conf
return 307 https://$host$request_uri;
EOF
