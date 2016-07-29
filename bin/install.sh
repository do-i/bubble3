#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble
#
# Usage: export BRANCH=<github branch name> && bash install.sh
#
if [ "${BRANCH}" == "" ]; then
  echo "export BRANCH variable"
  exit 1
fi
export BUBBLE_DIR=/home/pi/bubble3-${BRANCH}

# Remove previously install bubble if they exists
if [ -d ${BUBBLE_DIR} ]; then
  rm -r ${BUBBLE_DIR}
fi

# Download the latest bubble3 on the specified branch in tar.gz and unpack the contents into bubble3-master
curl -skL https://github.com/do-i/bubble3/archive/${BRANCH}.tar.gz | tar xzv

# Check the download and untar was good
if [ -d ${BUBBLE_DIR} ]; then
  echo "[Ok] Download and unpack bubble"
else
  echo "[Error] unable to install bubble3"
  exit 1
fi

# Run network setup and webapp setup scripts
bash ${BUBBLE_DIR}/bin/network-setup.bash  \
&& bash ${BUBBLE_DIR}/bin/webapp-setup.bash

echo "[Ok] End of install script. Check for any errors."
