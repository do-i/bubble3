#!/bin/bash
# Copyright (c) 2016 Joji Doi
# This script deploy bubble3/tmp/20160723_220500.tgz to /var/www/html
# Run this script in bubble3/bin/

BIN_DIR=$(pwd)
WORK_DIR=$(dirname "${BIN_DIR}")
LATEST_BUILD=$(ls -t ${WORK_DIR}/tmp | head -1)

cd /var/www/html
tar xvf ${WORK_DIR}/tmp/${LATEST_BUILD}

cd ${WORK_DIR}
