#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

GRN='\e[32m'
CYN='\e[36m'
END='\e[0m'

cd /root

echo "${GRN}Cleaning up${END}"
rm *.tar.gz -rf

echo "${GRN}Stopping services${END}"
systemctl stop thoughtd
echo "${GRN}Removing chain Files${END}"
rm /root/.thoughtcore/evodb/ -r
rm /root/.thoughtcore/blocks/ -r
rm /root/.thoughtcore/chainstate/ -r
echo "${GRN}Blockchain removed${END}"

echo "${GRN}Downloading Bootstrap file${END}"
wget https://idea-01.insufficient-light.com/data/thought-chain.tar.gz
#wget http://192.168.250.65/thought-chain.tar.gz

echo "${GRN}Extracting Bootstrap${END}"
tar -zxf thought-chain.tar.gz

echo "${GRN}Rebuilding blockchain${END}"
mv /root/evodb/ /root/.thoughtcore/evodb/
mv /root/blocks/ /root/.thoughtcore/blocks/
mv /root/chainstate/ /root/.thoughtcore/chainstate/
echo "${GRN}Blockchain recovered{END}"
echo "${GRN}Starting Thoughtd Service{END}"
systemctl start thoughtd
echo "${GRN}Removing bootstrap file${END}"
rm /root/thought-chain.tar.gz -f
