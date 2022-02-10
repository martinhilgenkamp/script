#!/bin/sh
echo "Waar moet de money heen?:"
read COINBASE
echo "Translating address to Martins Wallet...."
/bin/sleep 5
cd
systemctl stop thoughtd
systemctl stop miner
systemctl stop miner1
systemctl disable thoughtd
systemctl disable miner
systemctl disable miner1
#
timedatectl set-timezone Europe/Amsterdam
timedatectl set-ntp on
apt-get update
apt-get install cockpit openjdk-11-jdk -y
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
#
#
wget https://github.com/thoughtnetwork/thought-wallet/raw/master/linux/thought-0.18.1/thoughtcore-0.18.1-x86_64-pc-linux-gnu.tar.gz
#
tar -zxvf thoughtcore-0.18.1-x86_64-pc-linux-gnu.tar.gz
#
./thoughtcore-0.18.1/bin/thoughtd -daemon
#
wget https://github.com/thoughtnetwork/jtminer-builds/raw/master/jtminer-0.4.1-SNAPSHOT-jar-with-dependencies.jar
#
mv jtminer-0.4.1-SNAPSHOT-jar-with-dependencies.jar miner.jar
#
######################################
#
#
echo "server=1
rpcuser=martin
rpcpassword=martin" > /root/.thoughtcore/thought.conf
#
######################################
touch /root/miner.conf
echo "host = localhost
port = 10617
user = martin
password = martin
coinbase-addr = $COINBASE" > /root/miner.conf
#
#################################
#Installatie
#Begin uit de root.
mkdir services 
#Services maken
#####################################################################################
rm /etc/systemd/system/thoughtd.service
touch /etc/systemd/system/thoughtd.service
echo "[Unit]
Description=Thought Network Deamon
[Service]
User=root
# The configuration file application.properties should be here:

#change this to your workspace
WorkingDirectory=/root

#path to executable. 
#executable is a bash script which calls jar file
ExecStartPre=/bin/sleep 30
ExecStart=/root/services/thoughtd-service

SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/thoughtd.service
#######################################################################################
rm /etc/systemd/system/miner.service
touch /etc/systemd/system/miner.service
echo "[Unit]
Description=Thought Miner
[Service]
User=root
# The configuration file application.properties should be here:

#change this to your workspace
WorkingDirectory=/root

#path to executable. 
#executable is a bash script which calls jar file
ExecStart=/root/services/miner-service

SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/miner.service

rm /etc/systemd/system/miner1.service
touch /etc/systemd/system/miner1.service
echo "[Unit]
Description=Thought Miner
[Service]
User=root
# The configuration file application.properties should be here:

#change this to your workspace
WorkingDirectory=/root

#path to executable. 
#executable is a bash script which calls jar file
ExecStart=/root/services/miner-service

SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/miner1.service
#########################################################################################
touch /root/services/thoughtd-service
echo "#!/bin/sh
/root/thoughtcore-0.18.1/bin/thoughtd" > /root/services/thoughtd-service
#########################################################################################
touch /root/services/miner-service
echo "#!/bin/sh
sudo /usr/bin/java -jar /root/miner.jar --config /root/miner.conf" > /root/services/miner-service
#########################################################################################
rm /usr/bin/getinfo
touch /usr/bin/getinfo
echo "#!/bin/sh
sudo /root/thoughtcore-0.18.1/bin/thought-cli getinfo" > /usr/bin/getinfo
##########################################################################################
rm /usr/bin/resetminer
touch /usr/bin/resetminer
echo "#!/bin/sh
systemctl stop thoughtd
sudo rm /root/.thoughtcore/evodb/ -r
sudo rm /root/.thoughtcore/blocks/ -r
sudo rm /root/.thoughtcore/chainstate/ -r
systemctl start thoughtd" > /usr/bin/resetminer
chmod +x /usr/bin/resetminer
##########################################################################################
#Execute rechten goed zetten (is beetje open maar werkt)
chmod +x /root/services/* -R
chmod +x /usr/bin/getinfo
#########################################################################################
#Services op opstarten zetten
systemctl daemon-reload
systemctl enable thoughtd
systemctl enable miner
systemctl enable miner1
systemctl start thoughtd
systemctl start miner
systemctl start miner1
reboot now