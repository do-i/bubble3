#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble

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
  echo "[Error] wlan0 interface configuration. Check the interfaces."
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

# Update hostapd
sudo mv /etc/default/hostapd /etc/default/hostapd.orig
sudo tee /etc/default/hostapd <<EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF

# Configure dnsmasq
# TODO reconsider DNS server IP Address
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo tee /etc/dnsmasq.conf <<EOF
interface=wlan0
listen-address=192.168.8.64
bind-interfaces
server=8.8.8.8       # Forward DNS requests to Google DNS
domain-needed
bogus-priv
dhcp-range=192.168.8.70,192.168.8.86,12h
EOF

# Set up IPV4 Forwarding so that device connected to pi via wlan0 can use eth0
sudo mv /etc/sysctl.conf /etc/sysctl.conf.orig
sudo tee /etc/sysctl.conf <<EOF
net.ipv4.ip_forward=1
EOF

# Activate IP Forwarding
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

# Allow wifi clients to access to internet via eth0
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

# Save iptables in file so the config is applied every time we reboot the Pi
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

sudo mv /etc/rc.local /etc/rc.local.orig
sudo tee /etc/rc.local <<EOF
#!/bin/sh -e
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi
iptables-restore < /etc/iptables.ipv4.nat
exit 0
EOF

# Restart Services
sudo service hostapd start
sudo service dnsmasq start

# Install web server
sudo apt-get install -y apache2

if [ ! -d /var/www/html ]; then
  echo "[Error] apache2 failed to install"
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
  echo "[Error] unable to install bubble3"
  exit 1
fi

# build and deploy web to apache server /var/www/html
cd bubble3-master/bin
./bd.sh clean

# copy file_lister.py to /usr/local/bin/file_lister.py
if [ -f ~/bubble3-master/bin/file_lister.py ]; then
  sudo cp ~/bubble3-master/bin/file_lister.py /usr/local/bin/file_lister.py
else
  echo "[Error] file_lister.py does not exit."
  exit 1
fi

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

echo "[Ok] End of install script. Check for any errors."
