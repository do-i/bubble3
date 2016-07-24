#!/bin/bash

# This is build and deploy script
if [ "$1" == "clean" ]; then
  BIN_DIR=$(pwd)
  WORK_DIR=$(dirname "${BIN_DIR}")
  rm ${WORK_DIR}/tmp/*.tgz
fi
./build.sh && ./deploy.sh
