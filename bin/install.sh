#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble

# update
if [ "$1" != "skip" ]; then
  sudo apt-get -y update
fi

# Install dnsmasq hostapd for access point
sudo apt-get install -y dnsmasq hostapd

# Check hostapd installation
if [ -d /etc/hostapd ]; then
  echo "[Ok] hostapd"
else
  echo "[Error] hostapd not installed correctly"
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
sudo mv /etc/network/interfaces /etc/network/interfaces.orig
sudo tee /etc/network/interfaces <<EOF
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

iface eth0 inet manual

allow-hotplug wlan0
iface wlan0 inet static
    address 192.168.8.64
    netmask 255.255.255.0
    network 192.168.8.0
    broadcast 192.168.8.255

allow-hotplug wlan1
iface wlan1 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF

# Restart dhcpcd
sudo service dhcpcd restart

# Reload the configuration for wlan0
sudo ifdown wlan0; sudo ifup wlan0

# Check the wlan0 interface
if ifconfig | grep -q 192.168.8.64; then
  echo "wlan0 interface is up!"
else
  echo "Error: wlan0 interface configuration. Check the interfaces."
  exit 1
fi

# Configure hostapd
# TODO Change ssid and wpa_passphrase values to something else
sudo tee /etc/hostapd/hostapd.conf <<EOF
# This is the name of the WiFi interface we configured above
interface=wlan0

# Use the nl80211 driver with the brcmfmac driver
driver=nl80211

# This is the name of the network
ssid=BrightLink

# Use the 2.4GHz band
hw_mode=g

# Use channel 6
channel=6

# Enable 802.11n
ieee80211n=1

# Enable WMM
wmm_enabled=1

# Enable 40MHz channels with 20ns guard interval
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]

# Accept all MAC addresses
macaddr_acl=0

# Use WPA authentication
auth_algs=1

# Require clients to know the network name
ignore_broadcast_ssid=0

# Use WPA2
wpa=2

# Use a pre-shared key
wpa_key_mgmt=WPA-PSK

# The network passphrase
wpa_passphrase=raspberry

# Use AES, instead of TKIP
rsn_pairwise=CCMP
EOF

# Install web server
sudo apt-get install -y apache2

if [ ! -d /var/www/html ]; then
  echo "apache2 failed to install"
  exit 1
fi

# change the owner of html dir to pi
sudo chown pi:pi /var/www/html/

# create content directory to bind /mnt
mkdir -p /var/www/html/ext-content

# This should be done once
if [ "" == "$(grep /dev/sda1 /etc/fstab)" ]; then
  sudo tee -a /etc/fstab <<EOF
/dev/sda1 /mnt vfat defaults 0 0
/mnt /var/www/html/ext-content none bind 0 0
EOF
fi

# mount the usb device so that web page can acess to files on the usb thumb
sudo mount -a

# make sure that work directory is home directory
cd ~

# delete previously installed pages except ext-content
for afile in $(ls /var/www/html); do
  if [ "$afile" != "ext-content" ]; then
    rm -rf "/var/www/html/$afile"
  fi
done

# download the latest bubble3 repo in tar.gz and unpack the contents into bubble3-master
if [ -d bubble3-master ]; then
  rm -r bubble3-master
fi
curl -ksL https://github.com/do-i/bubble3/archive/master.tar.gz | tar xzv

if [ -d bubble3-master ]; then
  echo "bubble3-master installed"
else
  echo "unable to install bubble3"
  exit 1
fi

# build and deploy web to apache server /var/www/html
cd bubble3-master/bin
./bd.sh clean

# copy file_lister.py to /usr/local/bin/file_lister.py
sudo cp ~/bubble3-master/bin/file_lister.py /usr/local/bin/file_lister.py

# ensure the python script is executable
sudo chmod +x /usr/local/bin/file_lister.py

# install libraries for upstart
sudo apt-get -y install upstart dbus-x11

# create upstart job configuration file
sudo tee /etc/init/file_lister.conf <<EOF
description "Upstart job to kick off file_lister.py script."
author "Bubblers"
start on runlevel [2345]
exec /usr/local/bin/file_lister.py
EOF

# mount USB drive
sudo mount -a

# kick off generate script
/usr/local/bin/file_lister.py

echo "Bubble3 is installed ... [OK]"
