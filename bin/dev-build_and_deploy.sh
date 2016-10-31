#!/bin/bash
# Copyright (c) 2016 Joji Doi
# This is build and deploy script
if [ "$1" == "clean" ]; then
  BIN_DIR=$(pwd)
  WORK_DIR=$(dirname "${BIN_DIR}")
  rm ${WORK_DIR}/tmp/*.tgz
fi
./build.sh && ./dev-deploy.sh
