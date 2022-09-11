#!/bin/bash

sec=$(find /usr/share -type d -name "seclists" 2>/dev/null)
if [ "$EUID" -ne 0 ]
then
    echo Please run as root/sudo
    exit 1
else
    echo "Installing nmap"
    sudo apt install nmap -y
    echo "Installing rustscan"
    wget https://github.com/RustScan/RustScan/releases/download/1.10.0/rustscan_1.10.0_amd64.deb
    sudo dpkg -i rustscan_1.10.0_amd64.deb 
    echo "Installing feroxbuster"
    sudo snap install feroxbuster -y
    sudo rm rustscan_1.10.0_amd64.deb
    if [ ! -d "$sec" ]
    then
        cd /usr/share
        wget -c https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip
        unzip SecList.zip
        rm -f SecList.zip
        mv SecLists-master seclists
    else
        echo "Seclist already present"
    fi
fi