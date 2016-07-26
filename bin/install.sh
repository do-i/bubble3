#!/bin/bash

# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble

# update
if [ "$1" != "skip" ]; then
  sudo apt-get -y update
fi

# Install software
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
  sudo tee -a /etc/fstab << EOF
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
sudo tee /etc/init/file_lister.conf << EOF
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
