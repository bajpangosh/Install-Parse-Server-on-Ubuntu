#!/bin/bash
# GET ALL USER INPUT
echo "Domain Name (eg. example.com)?"
read DOMAIN
echo "App name (eg. kloudboy)?"
read APP_NAME
echo 'Wellcome to Parse Server and Dashboard on Ubuntu install script';
sleep 2;
cd ~
echo 'installing Node Js';
sleep 2;
apt-get update
apt-get install -y nodejs npm build-essential pwgen libkrb5-dev

echo 'installing Mongo DB';
sleep 2;
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
apt-get update
apt-get install -y mongodb-org
service mongod start

echo 'Installing Parse Server Dashboard and PM2';
sleep 2;

git clone https://github.com/ParsePlatform/parse-server-example.git $APP_NAME
cd $APP_NAME
npm install -g parse-server mongodb-runner parse-dashboard pm2@latest --no-optional --no-shrinkwrap
npm install express --save
npm install parse-server --save

echo
echo 'Downloading Parse Server Dashboard Configrtion Files';
sleep 2;

sudo curl https://git.kloudboy.com/parse-dashboard-config > parse-dashboard-config.json
sudo curl https://git.kloudboy.com/dashboard-running > dashboard-running.json
npm -g install
echo
echo 'Adding APP_ID and MASTER_KEY';
sleep 2;
APP_ID=`pwgen -s 24 1`
sudo sed -i "s/appId: process.env.APP_ID || .*/appId: process.env.APP_ID || '$APP_ID',/" /root/$APP_NAME/index.js
sudo sed -i -e "s/APP_ID/$APP_ID/" "/root/$APP_NAME/parse-dashboard-config.json"

MASTER_KEY=`pwgen -s 26 1`
sudo sed -i "s/masterKey: process.env.MASTER_KEY || .*/masterKey: process.env.MASTER_KEY || '$MASTER_KEY',/" /root/$APP_NAME/index.js
sudo sed -i -e "s/MASTER_KEY/$MASTER_KEY/" "/root/$APP_NAME/parse-dashboard-config.json"
echo 'Happy Ending';
echo
pm2 start index.js && pm2 startup
pm2 start dashboard-running.json && pm2 startup
pm2 status
