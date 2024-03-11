#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Exit the script if any command fails
set -e

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

directory="/root/.thoughtcore/evodb/"
if [ -d "$directory" ]; then
    rm -r "$directory"
    echo "Directory $directory removed."
else
    echo "Directory $directory does not exist. No removal needed."
fi
directory="/root/.thoughtcore/blocks/"
if [ -d "$directory" ]; then
    rm -r "$directory"
    echo "Directory $directory removed."
else
    echo "Directory $directory does not exist. No removal needed."
fi
directory="/root/.thoughtcore/chainstate/"
if [ -d "$directory" ]; then
    rm -r "$directory"
    echo "Directory $directory removed."
else
    echo "Directory $directory does not exist. No removal needed."
fi

green "Blockchain removed"
yellow "Setting Journal logs to 3 days"
journalctl --vacuum-time=3d
green "Logs limit set"

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
##############################################################################################

# Check if the IP address is in the 192.168.222.0 subnet
if [[ $ip_address == 192.168.222.* ]]; then
    # Use url1
    url1="http://192.168.222.35/thought-chain.tar.gz"
elif [[ $ip_address == 192.168.250.* ]]; then
    # Use url in the 250 (proxy need to be setup)
    url1="http://192.168.222.35/thought-chain.tar.gz"
else
    #unknown network url1 is also the fallback
    url1="https://idea-01.insufficient-light.com/data/thought-chain.tar.gz"
fi 

# Fallback to internet source
url2="https://idea-01.insufficient-light.com/data/thought-chain.tar.gz"

local_temp_path="/root/thought-chain.temp.tar.gz"
local_final_path="/root/thought-chain.tar.gz"

# Try the first location, and if it fails, try the second one
wget --connect-timeout=5 --waitretry=1 -O "$local_temp_path" "$url1" || wget --connect-timeout=5 --waitretry=1 -O "$local_temp_path" "$url2"

# Check if the download was successful
if [ -e "$local_temp_path" ]; then
    # Move the temporary file to the final location
    mv "$local_temp_path" "$local_final_path"
    echo "Download successful. File moved to: $local_final_path"
else
    echo "Download failed. No file available."
fi
##############################################################################3#################
green "Extracting Bootstrap"
tar -zxf thought-chain.tar.gz

# Check the exit status of the tar command
if [ $? -ne 0 ]; then
  red "Error: Tar command failed. Disk Full??"
  exit 1
fi

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
sleep 40
if pgrep -x "thoughtd" > /dev/null; then
    # If the process is running, kill it
    green "Thought is running again"
    green "--------------------------"
    green "Starting Miners"
    systemctl start miner1
    systemctl start miner
else
    # If the process is not running, print a message
    yellow "Process 'thoughtd' is not running rebooting system."
    reboot now
fi
