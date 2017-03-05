#!/bin/bash
# Copyright (c) 2016 Joji Doi
# This bash script automates manual installation of raspbian OS
# Require sdcard to be unmounted and no partition should be allocated

echo "[$(date +%H:%M:%S)] Starting raspbianizer"

OS=$(uname)
DEVICE_NAME="${1}"
RASPBIAN="2017-01-11-raspbian-jessie-lite"
RASPBIAN_URL="http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-01-10/2017-01-11-raspbian-jessie-lite.zip"
WORK_DIR=$(pwd)
TMP_DIR=/tmp/bubble-$(date +%Y%m%d-%H%M%S)

## check if the ${DEVICE_NAME} exists
if [ "${DEVICE_NAME}" == "" ]; then
  echo "Usage: bash ${0} <DEVICE_NAME> #e.g., /dev/sdx"
  exit 1
fi
echo "DEVICE_NAME:${DEVICE_NAME}"
echo "RASPBIAN:${RASPBIAN}"
echo "WORK_DIR:${WORK_DIR}"
echo "TMP_DIR:${TMP_DIR}"

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

function mount_partitions() {
  BOOT_MNT=${TMP_DIR}/boot
  DEV_ONE=${DEVICE_NAME}1
  sudo mkdir -p ${BOOT_MNT}
  sudo mount ${DEV_ONE} ${BOOT_MNT}

  # Check mount
  if [ $(ls ${BOOT_MNT} | wc -l) > 0 ]; then
    echo "mount boot partition is successful"
  else
    echo "Failed to mount boot partition ${DEV_ONE} to ${BOOT_MNT}"
    exit 1
  fi

  # TODO combine these two into one function and pass partition id
  ROOT_MNT=${TMP_DIR}/root
  DEV_TWO=${DEVICE_NAME}2
  sudo mkdir -p ${ROOT_MNT}
  sudo mount ${DEV_TWO} ${ROOT_MNT}

  # Check mount
  if [ $(ls ${ROOT_MNT} | wc -l) > 0 ]; then
    echo "mount root partition is successful"
  else
    echo "Failed to mount root partition ${DEV_TWO} to ${ROOT_MNT}"
    exit 1
  fi
}

function umount_partitions() {
  sudo umount ${DEV_ONE}
  echo "umount ${DEV_ONE}"
  sudo umount ${DEV_TWO}
  echo "umount ${DEV_TWO}"
}

function create_ssh_file() {
  touch ${BOOT_MNT}/ssh
  if [ -f ${BOOT_MNT}/ssh ]; then
    echo "Enable sshd"
  else
    echo "Failed to create ssh file in boot dir: ${BOOT_MNT}"
    exit 1
  fi
}

function create_wpa_supplicant_file() {
  if [ "${SSID_CLIENT}" == "" ] || [ "${PASS_CLIENT}" == "" ]; then
    echo "SSID_CLIENT and PASS_CLIENT are required variables"
    exit 1
  else
    local wpa_supplicant_file=${ROOT_MNT}/etc/wpa_supplicant/wpa_supplicant.conf
    sudo echo "country=GB" > ${wpa_supplicant_file}
    sudo echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" >> ${wpa_supplicant_file}
    sudo echo "update_config=1" >> ${wpa_supplicant_file}
    sudo echo "network={" >> ${wpa_supplicant_file}
    sudo echo "  ssid=\"${SSID_CLIENT}\"" >> ${wpa_supplicant_file}
    sudo echo "  psk=\"${PASS_CLIENT}\"" >> ${wpa_supplicant_file}
    sudo echo "}" >> ${wpa_supplicant_file}
  fi
}

function create_interface_file() {
  echo "========== interfaces ============="
  sudo tee ${ROOT_MNT}/etc/network/interfaces <<EOF
source-directory /etc/network/interfaces.d
auto lo
iface lo inet loopback
auto wlan0
iface wlan0 inet dhcp
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
auto uap0
iface uap0 inet static
    address 2.4.8.16
    netmask 255.255.255.0
    network 2.4.8.0
    broadcast 2.4.8.255
    gateway 2.4.8.16
auto eth0
iface eth0 inet manual
EOF
  echo "==================================="
}

function create_config_files() {
  mount_partitions
  create_ssh_file
  create_wpa_supplicant_file
  create_interface_file
  umount_partitions
}

if [ "${OS}" == "Darwin" ]; then
  find_partition_count_mac && check_device_status && delete_partitions_mac
elif [ "${OS}" == "Linux" ]; then
  find_partition_count_linux && check_device_status && delete_partitions_linux
else
  echo "This is unsupported OS"
  exit 1
fi

## TODO check return status code from the previous command.
download_upzip && \
copy_image_to_device && \
create_config_files && \
echo "[$(date +%H:%M:%S)] Script completed. Check for errors in case there is any." && \
exit 0

echo "[Error] There was an error. Check the error log."
exit 1
