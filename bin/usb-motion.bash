#!/bin/bash
#
# This file is executed by /etc/udev/rules.d/88-local.rules
# When USB drive is unplugged or plugged this script take proper action
#
LOG_FILE=/tmp/usb-motion.log
if [ "$1" == "REMOVED" ]; then
  echo "R" >> ${LOG_FILE}
elif [ "$1" == "ADDED" ]; then
  echo "A" >> ${LOG_FILE}
else
  echo "X" >> ${LOG_FILE}
fi
