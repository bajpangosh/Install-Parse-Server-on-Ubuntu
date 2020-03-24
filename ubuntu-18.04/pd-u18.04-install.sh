#!/bin/bash
# GET ALL USER INPUT
echo "Domain Name (eg. example.com)?"
read DOMAIN
echo "App name (eg. kloudboy)?"
read APP_NAME
tput setaf 2; echo 'Wellcome to Parse Server and Dashboard on Ubuntu 18.04 install bash script';
sleep 2;
tput sgr0
cd ~
tput setaf 2; echo 'installing Node Js and Nginx Server';
sleep 2;
tput sgr0
apt-get update
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs pwgen nginx

tput setaf 2; echo "Sit back and relax :) ......"
sleep 2;
tput sgr0
cd /etc/nginx/sites-available/
sudo wget -O "app.$DOMAIN" https://goo.gl/2H3uGq
sudo sed -i -e "s/app.example.com/app.$DOMAIN/" "app.$DOMAIN"

sudo wget -O "dash.$DOMAIN" https://goo.gl/VZhPLP
sudo sed -i -e "s/dash.example.com/dash.$DOMAIN/" "dash.$DOMAIN"

sudo ln -s /etc/nginx/sites-available/"app.$DOMAIN" /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/"dash.$DOMAIN" /etc/nginx/sites-enabled/

tput setaf 2; echo "Setting up Cloudflare FULL SSL"
sleep 2;
tput sgr0
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
cd /etc/nginx/
sudo mv nginx.conf nginx.conf.backup
sudo wget -O nginx.conf https://goo.gl/7UBeQS
sudo systemctl reload nginx

tput setaf 2; echo 'installing Mongo DB';
sleep 2;
tput sgr0
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
apt-get update
apt-get install -y mongodb-org
service mongod start
cd ~
tput setaf 2; echo 'Installing Parse Server Dashboard and PM2';
sleep 2;
tput sgr0
git clone https://github.com/ParsePlatform/parse-server-example.git $APP_NAME
cd $APP_NAME
npm install -g parse-server mongodb-runner parse-dashboard pm2@latest --no-optional --no-shrinkwrap
echo
tput setaf 2; echo 'Downloading Parse Server Dashboard Configrtion Files';
sleep 2;

sudo curl https://raw.githubusercontent.com/bajpangosh/Install-Parse-Server-on-Ubuntu/master/ubuntu-18.04/parse-dashboard-config.json > parse-dashboard-config.json
sudo curl https://raw.githubusercontent.com/bajpangosh/Install-Parse-Server-on-Ubuntu/master/ubuntu-18.04/dashboard-running.json > dashboard-running.json
npm -g install
echo
tput setaf 2; echo 'Adding APP_ID and MASTER_KEY';
sleep 2;
tput sgr0
APP_ID=`pwgen -s 24 1`
sudo sed -i "s/appId: process.env.APP_ID || .*/appId: process.env.APP_ID || '$APP_ID',/" /root/$APP_NAME/index.js
sudo sed -i -e "s/APP_ID/$APP_ID/" "/root/$APP_NAME/parse-dashboard-config.json"
sudo sed -i -e "s/APP_NAME/$APP_NAME/" "/root/$APP_NAME/parse-dashboard-config.json"
sudo sed -i -e "s/DOMAIN/$DOMAIN/" "/root/$APP_NAME/parse-dashboard-config.json"
sudo sed -i -e "s/APP_NAME/$APP_NAME/" "/root/$APP_NAME/dashboard-running.json"
sudo sed -i -e "s/localhost:1337/app.$DOMAIN/" "/root/$APP_NAME/index.js"
sudo sed -i -e "s/http/https/" "/root/$APP_NAME/index.js"
MASTER_KEY=`pwgen -s 26 1`
sudo sed -i "s/masterKey: process.env.MASTER_KEY || .*/masterKey: process.env.MASTER_KEY || '$MASTER_KEY',/" /root/$APP_NAME/index.js
sudo sed -i -e "s/MASTER_KEY/$MASTER_KEY/" "/root/$APP_NAME/parse-dashboard-config.json"

PASS=`pwgen -s 9 1`
sudo sed -i -e "s/PASS/$PASS/" "/root/$APP_NAME/parse-dashboard-config.json"
tput setaf 2; echo 'Enable pm2';
echo
tput sgr0
pm2 start index.js && pm2 startup
pm2 start dashboard-running.json && pm2 startup
echo
echo
tput setaf 2; echo "Here is your Credentials"
echo "--------------------------------"
echo "APP_ID:   $APP_ID"
echo
echo "MASTER_KEY:   $MASTER_KEY"
echo
echo "App:        https://app.$DOMAIN"
echo "Dashboard:  https://dash.$DOMAIN"
echo
echo "Username:   admin"
echo "Password:   $PASS"
echo "--------------------------------"
tput sgr0
echo
echo
tput setaf 3;  echo "Installation & configuration succesfully finished."
echo
echo "Twitter @TeamKloudboy"
echo "E-mail: support@kloudboy.com"
echo "Bye! Your boy KLOUDBOY!"
tput sgr0
