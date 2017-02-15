#!/bin/bash
#
# Copyright (c) 2017 Joji Doi
#
# This install script is ment to be executed in Raspberry Pi3 (Raspbian) to download files from github
# and configure Bubble
# Usage: export BUBBLE_DIR=<bubble directory> && bash thumbs-up.bash

# setup variables
IMAGE_DIR='/mnt/photos'
THUMBS_DIR='/mnt/photos/thumbs'

# create thumbnail output dir
if [ -d ${THUMBS_DIR} ]; then
  echo 'thumbnails are already there. todo: check number of files to match source if numbers are different regenerate???'
else
  sudo mkdir -p ${THUMBS_DIR}
  sudo mogrify -format jpg -path ${THUMBS_DIR} -thumbnail 100x100 ${IMAGE_DIR}/*.jpg
fi
