#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

FILE=/root/miner.conf
if [ -f "$FILE" ]; then
    echo "$FILE exists."
    read -t 5 -p "Miner Config Exist on the system, oude instellingen gebruiken? [y/n]" yn
    case $yn in
                [yY][eE][sS]|[yY])
                echo "Oude miner.conf word hergebruikt"
                ;;
            [nN][oO]|[nN])
                        read -p "Waar moet de money heen ?" COINBASE
                        ######################################
                        touch /root/miner.conf
                        echo "host = localhost
port = 10617
user = martin
password = martin
coinbase-addr = $COINBASE" > /root/miner.conf
                        #
                        ;;
        *)
                echo "Oude miner.conf word hergebruikt"
                ;;
        esac
else
    echo "$FILE does not exist."
    read -p "Waar moet de money heen ?" COINBASE
                        ######################################
                        touch /root/miner.conf
                        echo "host = localhost
port = 10617
user = martin
password = martin
coinbase-addr = $COINBASE" > /root/miner.conf
                        #
fi
#########################################
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
DEBIAN_FRONTEND=noninteractive apt-get install openjdk-21-jdk -y
DEBIAN_FRONTEND=noninteractive apt-get purge cockpit -y
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt autoremove -y 
DEBIAN_FRONTEND=noninteractive apt clean -y 
DEBIAN_FRONTEND=noninteractive apt autoclean -y
sudo update-java-alternatives --set /usr/lib/jvm/java-1.21.0-openjdk-amd64
#
#
rm /root/thoughtcore-0.18.1 -r
rm /root/snap -r
rm /root/thoughtcore-0.18.1-x86_64-pc-linux-gnu.tar.gz -r
rm /root/thoughtcore-0.18.2-x86_64-pc-linux-gnu.tar.gz
rm /root/thoughtcore-0.18.3-x86_64-pc-linux-gnu.tar.gz
#
sleep 1
wget --no-check-certificate --content-disposition https://github.com/thoughtnetwork/thought-wallet/raw/master/linux/thought-0.18.3/thoughtcore-0.18.3-x86_64-pc-linux-gnu.tar.gz
#
sleep 2
tar -zxvf thoughtcore-0.18.3-x86_64-pc-linux-gnu.tar.gz
#
/root/thoughtcore/bin/thoughtd -daemon
sleep 20
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
#################################
#Installatie
#Begin uit de root.
mkdir services 
#Services maken
#####################################################################################
test -f /etc/systemd/system/thoughtd.service && rm /etc/systemd/system/thoughtd.service
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
test -f /etc/systemd/system/miner.service && rm /etc/systemd/system/miner.service
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
########################################################################################
test -f /etc/systemd/system/miner1.service && rm /etc/systemd/system/miner1.service
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
test -f /root/services/thoughtd-service && rm /root/services/thoughtd-service
touch /root/services/thoughtd-service
echo "#!/bin/bash
/root/thoughtcore/bin/thoughtd" > /root/services/thoughtd-service
#########################################################################################
test -f /root/services/miner-service && rm /root/services/miner-service
touch /root/services/miner-service
echo "#!/bin/bash
sudo /usr/bin/java -jar /root/miner.jar --config /root/miner.conf" > /root/services/miner-service
#########################################################################################
test -f /usr/bin/getinfo && rm /usr/bin/getinfo
touch /usr/bin/getinfo
echo "#!/bin/bash
sudo /root/thoughtcore/bin/thought-cli getinfo" > /usr/bin/getinfo
##########################################################################################
test -f /usr/bin/resetminer && rm /usr/bin/resetminer
touch /usr/bin/resetminer
echo "#!/bin/bash
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
#######################################################################################
#Allow Root login
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config


sleep 15


/root/thoughtcore/bin/thought-cli addnode idea-01.insufficient-light.com add
/root/thoughtcore/bin/thought-cli addnode idea-02.insufficient-light.com add
/root/thoughtcore/bin/thought-cli addnode idea-03.insufficient-light.com add
/root/thoughtcore/bin/thought-cli addnode idea-04.insufficient-light.com add
/root/thoughtcore/bin/thought-cli addnode idea-05.insufficient-light.com add
/root/thoughtcore/bin/thought-cli addnode idea-06.insufficient-light.com add
/root/thoughtcore/bin/thought-cli addnode idea-07.insufficient-light.com add
/root/thoughtcore/bin/thought-cli addnode idea-08.insufficient-light.com add
/root/thoughtcore/bin/thought-cli addnode idea-09.insufficient-light.com add
/root/thoughtcore/bin/thought-cli addnode idea-10.insufficient-light.com add



read -t 5 -p "Reset Miner? [y/n]" yn
    case $yn in
        [yY][eE][sS]|[yY])
		    /root/script/resetminer.sh
        ;;
        [nN][oO]|[nN])
            echo "Miner update complete, laten de mine goden met u zijn!"
			systemctl start thoughtd
			systemctl start miner
			systemctl start miner1
		;;
        *)
			echo "" 
	    /bin/sleep 25
     	    echo "Niet begrepen vaar eigen wind wel."
	    /root/script/resetminer.sh
        ;;
    esac
