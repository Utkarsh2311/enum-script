#!/bin/bash

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
fi