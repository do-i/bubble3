#!/bin/bash
# Copyright (c) 2016 Joji Doi
# This script is only for development deploy bubble3/tmp/20160723_220500.tgz to /var/www/html/bubble3
# Run this script in bubble3/bin/

BIN_DIR=$(pwd)
WORK_DIR=$(dirname "${BIN_DIR}")
LATEST_BUILD=$(ls -t ${WORK_DIR}/tmp | head -1)
DESTINATION=/var/www/html/bubble3
cd ${DESTINATION}
rm -rf ${DESTINATION}/*
tar xvf ${WORK_DIR}/tmp/${LATEST_BUILD}
mkdir -p ${DESTINATION}/ext-content
cd $_
cp -r ${WORK_DIR}/test/* .
cd ${WORK_DIR}
cp ${DESTINATION}/img/background_default.jpg ${DESTINATION}/img/background.jpg
