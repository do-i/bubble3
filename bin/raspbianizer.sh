#!/bin/bash
# Copyright (c) 2016 Joji Doi
# This bash script automates manual installation of raspbian OS
# Require sdcard to be unmounted and no partition should be allocated
OS=$(uname)
DEVICE_NAME="${1}"
RASPBIAN="2017-01-11-raspbian-jessie-lite"
RASPBIAN_URL="http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-01-10/2017-01-11-raspbian-jessie-lite.zip"
WORK_DIR=$(pwd)

## check if the ${DEVICE_NAME} exists
if [ "${DEVICE_NAME}" == "" ]; then
  echo "Usage: bash ${0} <DEVICE_NAME> #e.g., /dev/sdx"
  exit 1
fi
echo "DEVICE_NAME:${DEVICE_NAME}"
echo "RASPBIAN:${RASPBIAN}"
echo "WORK_DIR:${WORK_DIR}"

### Check if the device name ends with a digit (partition number).
function find_partition_count_linux() {
  if [[ ${DEVICE_NAME} =~ [0-9]$ ]]; then
    echo "Do not specify device partition. ${DEVICE_NAME}"
    exit 1
  fi
  CNT=$(sudo fdisk -l | grep ${DEVICE_NAME} | wc -l)
}

function find_partition_count_mac() {
  ### Check if the device name ends with a digit (partition number).
  if [[ ${DEVICE_NAME} =~ ^/dev/disk[2-9]$ ]]; then
    echo "Device name seems valid."
  else
    echo "Bad device name. ${DEVICE_NAME}"
    exit 1
  fi
  CNT=$(diskutil list ${DEVICE_NAME} | grep -e [0-9]: | wc -l)
}

function check_device_status() {
  if [ ${CNT} -eq 0 ]; then
    echo "Specified device ${DEVICE_NAME} does not exist. Please specify the device path to your sdcard."
    exit 1
  else
    echo "Valid Device ${DEVICE_NAME} Recognized."
  fi
}

function delete_partitions_mac() {
  if [ ${CNT} -gt 1 ]; then
    echo "Partition(s) found. They will be wiped out."
    diskutil eraseDisk JHFS+ Bubble ${DEVICE_NAME}
  fi

  diskutil unmountDisk ${DEVICE_NAME}
}

function delete_partitions_linux() {
  if [ ${CNT} -gt 1 ]; then
    echo "Partition(s) found. They will be wiped out."
    for i in $(parted -s ${DEVICE_NAME} print | awk '/^ / {print $1}'); do
      parted -s ${DEVICE_NAME} rm ${i}
    done
  fi
}

function download_upzip() {
  echo "Erase everything on ${DEVICE_NAME} and copy ${RASPBIAN}"
  if [ ! -f ${WORK_DIR}/${RASPBIAN}.img ]; then
    if [ ! -f ${WORK_DIR}/${RASPBIAN}.zip ]; then
      echo "Donwloading ${RASPBIAN} (~300MB)... takes a several minutes."
      curl -skL "${RASPBIAN_URL}" --output "${WORK_DIR}/${RASPBIAN}.zip"
      ## verify the downloads
      if [ ! -e "${WORK_DIR}/${RASPBIAN}.zip" ]; then
        echo "download failed..."
        exit 1
      fi
    fi
    unzip ${WORK_DIR}/${RASPBIAN}.zip
    if [ ! -e "${WORK_DIR}/${RASPBIAN}.img" ]; then
        echo "unzip failed..."
        exit 1
    fi
  fi
}

function copy_image_to_device() {
  echo "Copying ${WORK_DIR}/${RASPBIAN}.img to ${DEVICE_NAME}... takes about 7 to 8 minutes. Kick back and relax."
  sudo dd bs=4194304 if=${WORK_DIR}/${RASPBIAN}.img of=${DEVICE_NAME}
  echo "Sync in progress... do not touch nothing."
  sync
}

function create_ssh_file() {
  local BUBBLE=/tmp/bubble
  local BOOT_MNT=${DEVICE_NAME}1
  sudo mkdir -p ${BUBBLE}
  sudo mount ${BOOT_MNT} ${BUBBLE}
  sudo touch ${BUBBLE}/ssh
  sudo umount ${BOOT_MNT}
}

if [ "${OS}" == "Darwin" ]; then
  find_partition_count_mac && check_device_status && delete_partitions_mac
elif [ "${OS}" == "Linux" ]; then
  find_partition_count_linux && check_device_status && delete_partitions_linux
else
  echo "This is unsupported OS"
  exit 1;
fi

## TODO check return status code from the previous command.
download_upzip && copy_image_to_device && create_ssh_file \
  && echo "Script completed. Check for errors in case there is any." \
  && exit 0

echo "[Error] There was an error. Check the error log."
exit 1
