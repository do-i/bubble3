#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble
# Usage: export BUBBLE_DIR=<bubble directory> && bash network-setup.bash

if [ "${BUBBLE_DIR}" == "" ]; then
  echo "Set BUBBLE_DIR variable"
  exit 1
fi

# Install hostapd and dnsmasq for access point
sudo apt-get install -y hostapd dnsmasq

# Check hostapd installation
if [ -d /etc/hostapd ]; then
  echo "[INFO] Installed hostapd"
else
  echo "[Error] hostapd is not installed correctly"
  exit 1
fi

# Check dnsmasq installation
if [ -f /etc/dnsmasq.conf ]; then
  echo "[INFO] Installed dnsmasq"
else
  echo "[Error] dnsmasq is not installed correctly"
  exit 1
fi

# Disable DHCP
if grep -q "denyinterfaces uap0" /etc/dhcpcd.conf
then
  echo "[Skip] Disabled DHCP on uap0 interfaces"
else
  echo "denyinterfaces uap0" | sudo tee -a /etc/dhcpcd.conf
fi

# Static IP Address configuration
echo "[INFO] Configure /etc/network/interfaces"
sudo mv /etc/network/interfaces /etc/network/interfaces.old
sudo cp ${BUBBLE_DIR}/bin/config/interfaces /etc/network/interfaces

# Configure hostapd
echo "[INFO] Configure /etc/hostapd/hostapd.conf"
source ${BUBBLE_DIR}/bin/override.bash && copy_hostapd_conf

# Update hostapd
echo "[INFO] Configure /etc/default/hostapd"
sudo mv /etc/default/hostapd /etc/default/hostapd.old
sudo cp ${BUBBLE_DIR}/bin/config/hostapd /etc/default/hostapd

# Custom script to set the interface to AP mode, start hostapd and set some iptables
echo "[INFO] Configure /usr/local/bin/hostapdstart"
sudo cp ${BUBBLE_DIR}/bin/config/hostapdstart /usr/local/bin/hostapdstart
sudo chmod 755 /usr/local/bin/hostapdstart

# Configure dnsmasq
# TODO reconsider DNS server IP Address 8.8.8.8
echo "[INFO] Configure dnsmasq.conf"
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old
sudo cp ${BUBBLE_DIR}/bin/config/dnsmasq.conf /etc/dnsmasq.conf

# Edit rc.local to start hostapdstart at boot
echo "[INFO] Configure /etc/rc.local"
sudo mv /etc/rc.local /etc/rc.local.orig
sudo cp ${BUBBLE_DIR}/bin/config/rc.local /etc/rc.local

# Start dnsmasq service
echo "[INFO] Start dnsmasq service"
sudo service dnsmasq start

echo "============================="
echo "End of Network Configurations"
echo "============================="
