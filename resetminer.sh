#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cd /root
echo "Downloading Bootstrap"
wget http://192.168.250.65/thought-chain.tar.gz
echo "Extracting Bootstrap"
tar -zxf thought-chain.tar.gz
echo "Stopping services"
systemctl stop thoughtd
echo "Removing Files"
rm /root/.thoughtcore/evodb/ -r
rm /root/.thoughtcore/blocks/ -r
rm /root/.thoughtcore/chainstate/ -r

echo "Old files removed"
echo "Rebuilding blockchain"
mv /root/evodb/ /root/.thoughtcore/evodb/
mv /root/blocks/ /root/.thoughtcore/blocks/
mv /root/chainstate/ /root/.thoughtcore/chainstate/
echo "Blockchain recovered"
echo "Starting Thoughtd Service"
systemctl start thoughtd
echo "Thoughtd Service Started"
echo "Removing bootstrap file"
rm /root/thought-chain.tar.gz -f
