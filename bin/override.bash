#!/bin/bash
#
# Copyright (c) 2016 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian)
#
# Usage: source override.bash && replace_ssid
#

#
# if variable ${SSID} has valid value, replace ssid in ./config/hostapd.conf
#
function replace_ssid() {
  # alphanumeric at least one character and at most 32 characters
  if [[ "${SSID}" =~ ^[a-zA-Z0-9]{1,32}$ ]]; then
    perl -pi -e s/BrightLink/${SSID}/g ${BUBBLE_DIR}/bin/config/hostapd.conf
    if grep ${SSID} ${BUBBLE_DIR}/bin/config/hostapd.conf; then
      echo "Override SSID to ${SSID}."
    else
      echo "Failed to override SSID ${SSID}."
    fi
  else
    echo "valid SSID not specified: ${SSID}."
  fi
}

SSID="abcd$" && BUBBLE_DIR=/home/pi/bubble3-1.0.0 && replace_ssid
