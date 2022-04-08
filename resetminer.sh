#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cd /root
wget https://idea-01.insufficient-light.com/data/thought-chain.tar.gz
tar -zxvf thought-chain.tar.gz

systemctl stop thoughtd
rm /root/.thoughtcore/evodb/ -r
rm /root/.thoughtcore/blocks/ -r
rm /root/.thoughtcore/chainstate/ -r

mv /root/evodb/ /root/.thoughtcore/evodb/ -r
mv /root/blocks/ /root/.thoughtcore/blocks/ -r
mv /root/chainstate/ /root/.thoughtcore/chainstate/ -r

systemctl start thoughtd
journalctl -30 -u thoughtd