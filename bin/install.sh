#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble
#
# Usage: export BRANCH=<github release tag version or branch> && bash install.sh
#
if [ "${BRANCH}" == "" ]; then
  echo "export BRANCH variable"
  exit 1
fi

# If BRANCH is a tag with prefix v, remove it.
if [[ "${BRANCH}" =~ ^v[0-9].[0-9].[0-9] ]]; then
  export BUBBLE_DIR=/home/pi/bubble3-${BRANCH:1}
  echo "trimming v"
else
  export BUBBLE_DIR=/home/pi/bubble3-${BRANCH}
  echo "no trimming"
fi

echo "BRANCH : ${BRANCH}"
echo "BUBBLE_DIR : ${BUBBLE_DIR}"

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
