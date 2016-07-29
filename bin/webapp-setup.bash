#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble

if [ "$1" == "" ]; then
  echo "Specify <bubble_dir>"
  exit 1
fi

${BUBBLE_DIR}=$1

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

# delete previously installed pages except ext-content
for afile in $(ls /var/www/html); do
  if [ "$afile" != "ext-content" ]; then
    rm -rf "/var/www/html/$afile"
  fi
done

# build and deploy web to apache server /var/www/html
cd ${BUBBLE_DIR}/bin
./bd.sh

# copy file_lister.py to /usr/local/bin/file_lister.py
sudo cp ${BUBBLE_DIR}/bin/file_lister.py /usr/local/bin/file_lister.py

# ensure the python script is executable
sudo chmod +x /usr/local/bin/file_lister.py

# install libraries for upstart
sudo apt-get -y install upstart dbus-x11

# create upstart job configuration file
sudo cp ${BUBBLE_DIR}/bin/file_lister/file_lister.conf /etc/init/file_lister.conf

# mount the usb device so that web page can acess to files on the usb thumb
sudo mount -a

# kick off generate script to create data file in json format
/usr/local/bin/file_lister.py
