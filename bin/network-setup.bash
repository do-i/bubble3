#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble
PI_HOME=/home/pi
cd ${PI_HOME}

# skip package update if "skip" argument is specified.
if [ "$1" != "skip" ]; then
  sudo apt-get -y update
fi

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
if grep -q "denyinterfaces wlan0" /etc/dhcpcd.conf
then
  echo "[Skip] Disabled DHCP on wlan0 interfaces"
else
  echo "denyinterfaces wlan0" | sudo tee -a /etc/dhcpcd.conf
fi

# Static IP Address configuration
sudo mv /etc/network/interfaces /etc/network/interfaces.old
sudo cp ${PI_HOME}/bubble3-master/bin/config/interfaces /etc/network/interfaces

# Restart dhcpcd
sudo service dhcpcd restart

# Reload the configuration for wlan0
sudo ifdown wlan0; sudo ifup wlan0

# Check the wlan0 interface
if ifconfig | grep -q 192.168.8.64; then
  echo "wlan0 interface is up!"
else
  echo "[Error] wlan0 interface configuration. Check the interfaces."
  exit 1
fi

# Configure hostapd
# TODO Change ssid and wpa_passphrase values to something else
sudo cp ${PI_HOME}/bubble3-master/bin/config/hostapd.conf /etc/hostapd/hostapd.conf

# Update hostapd
sudo mv /etc/default/hostapd /etc/default/hostapd.old
sudo cp ${PI_HOME}/bubble3-master/bin/config/hostapd /etc/default/hostapd

# Configure dnsmasq
# TODO reconsider DNS server IP Address
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old
sudo cp ${PI_HOME}/bubble3-master/bin/config/dnsmasq.conf /etc/dnsmasq.conf

# Set up IPV4 Forwarding so that device connected to pi via wlan0 can use eth0
sudo mv /etc/sysctl.conf /etc/sysctl.conf.old
sudo cp ${PI_HOME}/bubble3-master/bin/config/sysctl.conf /etc/sysctl.conf

# Activate IP Forwarding
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

# Allow wifi clients to access to internet via eth0
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

# Save iptables in file so the config is applied every time we reboot the Pi
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

sudo mv /etc/rc.local /etc/rc.local.orig
sudo cp ${PI_HOME}/bubble3-master/bin/config/rc.local /etc/rc.local

# Restart Services
sudo service hostapd start
sudo service dnsmasq start
