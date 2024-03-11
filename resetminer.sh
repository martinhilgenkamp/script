#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

set +x
function black(){
    echo -e "\x1B[30m $1 \x1B[0m"
    if [ ! -z "${2}" ]; then
    echo -e "\x1B[30m $($2) \x1B[0m"
    fi
}
function red(){
    echo -e "\x1B[31m $1 \x1B[0m"
    if [ ! -z "${2}" ]; then
    echo -e "\x1B[31m $($2) \x1B[0m"
    fi
}
function green(){
    echo -e "\x1B[32m $1 \x1B[0m"
    if [ ! -z "${2}" ]; then
    echo -e "\x1B[32m $($2) \x1B[0m"
    fi
}
function yellow(){
    echo -e "\x1B[33m $1 \x1B[0m"
    if [ ! -z "${2}" ]; then
    echo -e "\x1B[33m $($2) \x1B[0m"
    fi
}
function blue(){
    echo -e "\x1B[34m $1 \x1B[0m"
    if [ ! -z "${2}" ]; then
    echo -e "\x1B[34m $($2) \x1B[0m"
    fi
}
function purple(){
    echo -e "\x1B[35m $1 \x1B[0m \c"
    if [ ! -z "${2}" ]; then
    echo -e "\x1B[35m $($2) \x1B[0m"
    fi
}
function cyan(){
    echo -e "\x1B[36m $1 \x1B[0m"
    if [ ! -z "${2}" ]; then
    echo -e "\x1B[36m $($2) \x1B[0m"
    fi
}
function white(){

    echo -e "\x1B[37m $1 \x1B[0m"
    if [ ! -z "${2}" ]; then
    echo -e "\x1B[33m $($2) \x1B[0m"
    fi
}
cd /root
# Check if the process "thoughtd" is running
if pgrep -x "thoughtd" > /dev/null; then
    # If the process is running, kill it
    green "Adding Nodes"
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
else
    # If the process is not running, print a message
    yellow "Process 'thoughtd' is not running."
fi


sleep 10

red "Stopping services"
systemctl stop thoughtd
yellow "Removing chain Files and old archives"
rm /root/*.tar.gz -rf
rm /root/.thoughtcore/evodb/ -r
rm /root/.thoughtcore/blocks/ -r
rm /root/.thoughtcore/chainstate/ -r

green "Blockchain removed"
yellow "Removing Journal logs"
rm /var/log/journal/* -r
green "Logs removed"

yellow "Cleaning APT resources"
# Check if snapd is installed
if command -v snap &>/dev/null; then
    yellow "Snapd is installed. Removing snapd..."
    
    # Remove snapd
    sudo apt-get purge -y snapd

    # Clean up dependencies
    sudo apt-get autoremove -y

    red "Snapd removed successfully."
else
    green "Snapd is not installed on this system."
fi
apt-get clean -y
apt-get autoremove --purge -y
green "APT files cleaned"

green "Downloading Bootstrap file"

wget https://idea-01.insufficient-light.com/data/thought-chain.tar.gz
#wget http://192.168.250.167/thought-chain.tar.gz

green "Extracting Bootstrap"
tar -zxf thought-chain.tar.gz

green "Rebuilding blockchain"
mv /root/evodb/ /root/.thoughtcore/evodb/
mv /root/blocks/ /root/.thoughtcore/blocks/
mv /root/chainstate/ /root/.thoughtcore/chainstate/
green "Blockchain recovered"


green "Starting Thoughtd Service"
systemctl start thoughtd
red "Removing bootstrap file"
rm /root/thought-chain.tar.gz -f
green "--------------------------"
green "success"
sleep 40
if pgrep -x "thoughtd" > /dev/null; then
    # If the process is running, kill it
    green "Thought is running again"
else
    # If the process is not running, print a message
    yellow "Process 'thoughtd' is not running rebooting system."
    reboot now
fi
