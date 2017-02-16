#!/bin/bash
#
# Copyright (c) 2017 Joji Doi
#
# Batch thumbnail generation script.
# Usage: export IMAGE_DIR=/mnt/photos && bash thumbs-up.bash

# setup variables
if [ "${IMAGE_DIR}" == "" ]; then
  IMAGE_DIR=/mnt/photos
fi

THUMBS_DIR=${IMAGE_DIR}/thumbs

# create thumbnail output dir
if [ -d ${THUMBS_DIR} ]; then
  echo 'thumbnails are already there. todo: check number of files to match source if numbers are different regenerate???'
else
  sudo mkdir -p ${THUMBS_DIR}
  # suports case-insensitive extensions for jpg and png files
  sudo find ${IMAGE_DIR} -type f \( -iname '*.jpg' -or -iname '*.png' \) -execdir \
  mogrify -auto-orient -format jpg -path thumbs -thumbnail 100x100 {} \;
fi
