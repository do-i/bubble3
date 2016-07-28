#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble
PI_HOME=/home/pi
cd ${PI_HOME}

# download the latest bubble3 repo in tar.gz and unpack the contents into bubble3-master
if [ -d ${PI_HOME}/bubble3-master ]; then
  rm -r ${PI_HOME}/bubble3-master
fi

curl -skL https://github.com/do-i/bubble3/archive/master.tar.gz | tar xzv

if [ -d ${PI_HOME}/bubble3-master ]; then
  echo "bubble3-master installed"
else
  echo "[Error] unable to install bubble3"
  exit 1
fi

bash ${PI_HOMEPI_HOME}/bubble3-master/bin/network_setup.bash \
&& bash ${PI_HOMEPI_HOME}/bubble3-master/bin/webapp_setup.bash

echo "[Ok] End of install script. Check for any errors."
