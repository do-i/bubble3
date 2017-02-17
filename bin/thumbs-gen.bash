#!/bin/bash
#
# Copyright (c) 2017 Joji Doi
#
# Batch thumbnail generation script.
# Usage: export IMAGE_DIR=/mnt/photos && bash thumbs-gen.bash

# setup variables
if [ "${IMAGE_DIR}" == "" ]; then
  IMAGE_DIR=/mnt/photos
fi

# set thumbnail destination dir
THUMBS_DIR=${IMAGE_DIR}/thumbs

# create thumbnail output dir just in case
sudo mkdir -p ${THUMBS_DIR}

# backup Internal Field Separator variable
IFS_ORIG=${IFS}

# overwrite IFS variable to support filenames with white spaces
IFS=$(echo -en "\n\b")

#TODO delete thumbnails that do not have original anymore

for fullname in $(find ${IMAGE_DIR} -type f \( -iname '*.jpg' -or -iname '*.png' \)); do
  basename="${fullname##*/}"
  if [ ! -f ${THUMBS_DIR}/${basename} ]; then
    sudo convert "${IMAGE_DIR}/${basename}" -auto-orient -thumbnail 100x100 "${THUMBS_DIR}/${basename}"
  fi
done

# restore original IFS value
IFS=${IFS_ORIG}
