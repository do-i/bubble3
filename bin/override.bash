#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian)
# Usage: source override.bash && copy_hostapd_conf
###

###
# What the script does:
# 1) sudo cp ${BUBBLE_DIR}/bin/config/hostapd.conf /etc/hostapd/hostapd.conf
# 2) if ${SSID} has acceptable value, replace the default value in /etc/hostapd/hostapd.conf
# 3) if ${PASS} has acceptable value, replace the default value in /etc/hostapd/hostapd.conf
###
function copy_hostapd_conf() {
  sudo cp ${BUBBLE_DIR}/bin/config/hostapd.conf /etc/hostapd/hostapd.conf \
  && replace_ssid && replace_pass
}

function replace_ssid() {
  # alphanumeric at least one character and at most 32 characters
  if [[ "${SSID}" =~ ^[a-zA-Z0-9]{1,32}$ ]]; then
    # Replace 'ssid=SimpleBubble' with ${SSID} in hostapd.conf
    # -pi: replace original input file in place (i.bak will save original file as hostapd.conf.bak)
    # -e: expression of string replace
    sudo perl -pi -e s/ssid=SimpleBubble/ssid=${SSID}/g /etc/hostapd/hostapd.conf
    if grep -q ${SSID} /etc/hostapd/hostapd.conf; then
      echo "Override SSID to ${SSID}."
    else
      echo "Failed to override SSID ${SSID}."
    fi
  else
    echo "valid SSID not specified: ${SSID}."
  fi
}

function replace_pass() {
  # alphanumeric at least 8 character and at most 63 characters
  if [[ "${PASS}" =~ ^[a-zA-Z0-9]{8,63}$ ]]; then
    sudo perl -pi -e s/wpa_passphrase=raspberry/wpa_passphrase=${PASS}/g /etc/hostapd/hostapd.conf
    if grep -q ${PASS} /etc/hostapd/hostapd.conf; then
      echo "Override wpa_passphrase."
    else
      echo "Failed to override wpa_passphrase."
    fi
  else
    echo "valid wpa_passphrase not specified."
  fi
}
##TESTS
#SSID="abcdefgabcdefgabcdefgabcdefgabcd" && BUBBLE_DIR=/home/pi/bubble3-1.0.0 && copy_hostapd_conf
#SSID="abcde" && PASS="12345678" && BUBBLE_DIR=/home/pi/bubble3-1.0.0 && copy_hostapd_conf
#SSID="" && PASS="" && BUBBLE_DIR=/home/pi/bubble3-1.0.0 && copy_hostapd_conf
