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

green "Cleaning up"
rm *.tar.gz -rf
sleep 10
green "Adding Nodes{END}"
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


red "Stopping services"
systemctl stop thoughtd
green "Removing chain Files"
rm /root/.thoughtcore/evodb/ -r
rm /root/.thoughtcore/blocks/ -r
rm /root/.thoughtcore/chainstate/ -r
green "Blockchain removed"

green "Downloading Bootstrap file"

wget http://192.168.250.167/thought-chain.tar.gz

green "Extracting Bootstrap"
tar -zxf thought-chain.tar.gz

green "Rebuilding blockchain"
mv /root/evodb/ /root/.thoughtcore/evodb/
mv /root/blocks/ /root/.thoughtcore/blocks/
mv /root/chainstate/ /root/.thoughtcore/chainstate/
green "Blockchain recovered{END}"


green "Starting Thoughtd Service{END}"
systemctl start thoughtd
red "Removing bootstrap file"
rm /root/thought-chain.tar.gz -f
green "--------------------------"
green "success"
