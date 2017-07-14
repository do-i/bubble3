#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble
# Usage: export BUBBLE_DIR=<bubble directory> && bash webapp-setup.bash

# Install imagemagick
sudo apt-get install -y imagemagick

# check mogrify is installed
if which convert; then
  echo 'imagemagick is installed'
else
  echo 'imagemagick installation failed.'
  exit 1
fi

if [ "${BUBBLE_DIR}" == "" ]; then
  echo "Set BUBBLE_DIR variable"
  exit 1
fi

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

# copy file_lister.py to ~/file_lister.py
sudo cp ${BUBBLE_DIR}/bin/file_lister.py /home/pi/file_lister.py
sudo cp ${BUBBLE_DIR}/bin/file_lister_v2.py /home/pi/file_lister_v2.py

# ensure the python script is executable
sudo chmod +x /home/pi/file_lister.py

# create systemd service file (aka Unit File)
sudo cp ${BUBBLE_DIR}/bin/config/media-discovery.service /lib/systemd/system

# copy thumbs-gen.bash to ~/thumbs-gen.bash
sudo cp ${BUBBLE_DIR}/bin/thumbs-gen.bash /home/pi/thumbs-gen.bash

# ensure the python script is executable
sudo chmod +x /home/pi/thumbs-gen.bash

# create systemd service file for thumbnail generation
sudo cp ${BUBBLE_DIR}/bin/config/thumbs-gen.service /lib/systemd/system

# copy usb-motion.bash to ~/usb-motion.bash
sudo cp ${BUBBLE_DIR}/bin/usb-motion.bash /home/pi/usb-motion.bash

# ensure script is executable
sudo chmod +x /home/pi/usb-motion.bash

# copy 88-local.rules to /etc/udev/rules.d
sudo cp ${BUBBLE_DIR}/bin/config/88-local.rules /etc/udev/rules.d

# activate udev rules
sudo udevadm control --reload-rules

# mount the usb device so that web page can acess to files on the usb thumb
sudo mount -a

# enable the systemd services
sudo systemctl daemon-reload
sudo systemctl enable media-discovery.service
sudo systemctl enable media-discovery2.service
sudo systemctl enable thumbs-gen.service

# kick off generate script to create data file in json format
/home/pi/file_lister.py
/home/pi/file_lister_v2.py

# kick off thumbnail generation script
/home/pi/thumbs-gen.bash
