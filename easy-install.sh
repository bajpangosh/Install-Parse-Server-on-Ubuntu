echo 'Wellcome to Parse Server and Dashboard on Ubuntu install script';
sleep 2;
cd ~
echo 'installing python-software-properties';
sleep 2;
apt-get install -y build-essential git python-software-properties

echo 'installing Node Js';
sleep 2;

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install -y nodejs
apt-get install -y build-essential

echo 'installing Mongo DB';
sleep 2;

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
apt-get update
apt-get install -y mongodb-org
service mongod start

echo 'Installing Parse Server Dashboard and PM2';
sleep 2;

npm install -g parse-server mongodb-runner parse-dashboard pm2@latest --no-optional --no-shrinkwrap
git clone https://github.com/ParsePlatform/parse-server-example.git
cd parse-server-example

echo
echo 'Downloading Parse Server Dashboard Configrtion Files';
sleep 2;

sudo curl https://raw.githubusercontent.com/bajpangosh/Install-Parse-Server-on-Ubuntu/master/parse-dashboard-config.json > parse-dashboard-config.json
sudo curl https://raw.githubusercontent.com/bajpangosh/Install-Parse-Server-on-Ubuntu/master/dashboard-running.json > dashboard-running.json
npm -g install
echo
echo 'Adding APP_ID and MASTER_KEY';
sleep 2;
sudo sed -i "s/appId: process.env.APP_ID || .*/appId: process.env.APP_ID || 'KLOUDBOY123',/" /root/parse-server-example/index.js
sudo sed -i "s/masterKey: process.env.MASTER_KEY || .*/masterKey: process.env.MASTER_KEY || 'KLOUDBOY456',/" /root/parse-server-example/index.js
echo 'Happy Ending';
echo
pm2 start index.js && pm2 startup
pm2 start dashboard-running.json && pm2 startup
pm2 status
