#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cd /root
wget https://idea-01.insufficient-light.com/data/thought-chain.tar.gz
tar -zxvf thought-chain.tar.gz