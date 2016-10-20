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

# Update package list
sudo apt-get -y update

# Install dnsmasq hostapd for access point
sudo apt-get install -y dnsmasq hostapd

# Check dnsmasq installation
if [ -f /etc/dnsmasq.conf ]; then
  echo "[Ok] dnsmasq"
else
  echo "[Error] dnsmasq is not installed correctly"
  exit 1
fi

# Check hostapd installation
if [ -d /etc/hostapd ]; then
  echo "[Ok] hostapd"
else
  echo "[Error] hostapd is not installed correctly"
  exit 1
fi

# Disable DHCP
if grep -q "denyinterfaces wlan1" /etc/dhcpcd.conf
then
  echo "[Skip] Disabled DHCP on wlan1 interfaces"
else
  echo "denyinterfaces wlan1" | sudo tee -a /etc/dhcpcd.conf
  echo "denyinterfaces wlan0" | sudo tee -a /etc/dhcpcd.conf
fi

# Static IP Address configuration
sudo mv /etc/network/interfaces /etc/network/interfaces.old
sudo cp ${BUBBLE_DIR}/bin/config/interfaces /etc/network/interfaces

# Restart dhcpcd
sudo service dhcpcd restart

# Reload the configuration for wlan1
sudo ifdown wlan1; sudo ifup wlan1

# Check the wlan1 interface
if ifconfig | grep -q 2.4.8.16; then
  echo "wlan1 interface is up!"
else
  echo "[Error] wlan1 interface configuration. Check the interfaces."
  exit 1
fi

# Configure hostapd
source ${BUBBLE_DIR}/bin/override.bash && copy_hostapd_conf

# Update hostapd
sudo mv /etc/default/hostapd /etc/default/hostapd.old
sudo cp ${BUBBLE_DIR}/bin/config/hostapd /etc/default/hostapd

# Configure dnsmasq
# TODO reconsider DNS server IP Address
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old
sudo cp ${BUBBLE_DIR}/bin/config/dnsmasq.conf /etc/dnsmasq.conf

# Set up IPV4 Forwarding so that device connected to pi via wlan1 can use eth0
sudo mv /etc/sysctl.conf /etc/sysctl.conf.old
sudo cp ${BUBBLE_DIR}/bin/config/sysctl.conf /etc/sysctl.conf

# Activate IP Forwarding
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

# Allow wifi clients to access to internet via eth0
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan1 -o eth0 -j ACCEPT

# Save iptables in file so the config is applied every time we reboot the Pi
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

sudo mv /etc/rc.local /etc/rc.local.orig
sudo cp ${BUBBLE_DIR}/bin/config/rc.local /etc/rc.local

# Restart Services
sudo service hostapd start
sudo service dnsmasq start
