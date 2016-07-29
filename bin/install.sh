#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble
PI_HOME=/home/pi
BRANCH="master"

# TODO parametalize the branch
if [ "$1" != "" ]; then
  BRANCH="$1"
fi
BUBBLE_DIR=${PI_HOME}/bubble3-${BRANCH}

# download the latest bubble3 repo in tar.gz and unpack the contents into bubble3-master
if [ -d ${BUBBLE_DIR} ]; then
  rm -r ${BUBBLE_DIR}
fi

curl -skL https://github.com/do-i/bubble3/archive/${BRANCH}.tar.gz | tar xzv

if [ -d ${BUBBLE_DIR} ]; then
  echo "[Ok] Download and unpack bubble"
else
  echo "[Error] unable to install bubble3"
  exit 1
fi

bash ${BUBBLE_DIR}/bin/network_setup.bash ${BUBBLE_DIR} \
&& bash ${BUBBLE_DIR}/bin/webapp_setup.bash ${BUBBLE_DIR}

echo "[Ok] End of install script. Check for any errors."
