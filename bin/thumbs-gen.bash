#!/bin/bash
#
# Copyright (c) 2017 Joji Doi
#
# Batch thumbnail generation script.
# Usage: export IMAGE_DIR=/mnt/photos && bash thumbs-gen.bash

# log dir
if [ "${LOG_DIR}" == "" ]; then
  LOG_DIR=/tmp/$(date +%Y%m%d-%H%M%S)
fi
mkdir -p ${LOG_DIR}
LOG_FILE=${LOG_DIR}/thumbs-gen.log
echo "Thumbnail generation is started." > ${LOG_FILE}

# status file to notify UI when thumbs-gen is done
if [ "${OUTPUT_DIR}" == "" ]; then
  OUTPUT_DIR=/var/www/html/data
fi

# create a marker file. used by UI to decide when to load thumbs
echo '{"thumbs":"WIP"}' > ${OUTPUT_DIR}/thumb-gen.json
chmod 644 ${OUTPUT_DIR}/thumb-gen.json

# setup variables
if [ "${IMAGE_DIR}" == "" ]; then
  # support case-insensitive for `photos` dir
  IMAGE_DIR=$(find /mnt -iname photos)
fi

# set thumbnail destination dir
THUMBS_DIR=${IMAGE_DIR}/thumbs

# create thumbnail output dir just in case
sudo mkdir -p ${THUMBS_DIR}

# backup Internal Field Separator variable
IFS_ORIG=${IFS}

# overwrite IFS variable to support filenames with white spaces
IFS=$(echo -en "\n\b")

# delete thumbnails that do not have original images
for fullname in $(find ${THUMBS_DIR} -maxdepth 1 -type f \( -iname '*.jpg' -or -iname '*.png' \)); do
  basename="${fullname##*/}"
  if [ ! -f ${IMAGE_DIR}/${basename} ]; then
    sudo rm "${THUMBS_DIR}/${basename}"
    echo "${basename} thumbnail deleted" >> ${LOG_FILE}
  fi
done

# generate thumbnails if they do not exist
for fullname in $(find ${IMAGE_DIR}/* -maxdepth 0 -type f \( -iname '*.jpg' -or -iname '*.png' \)); do
  # note that this script skips hidden files with dot prefixed files
  basename="${fullname##*/}"
  if [ ! -f ${THUMBS_DIR}/${basename} ]; then
    sudo convert "${IMAGE_DIR}/${basename}" -auto-orient -thumbnail 100x100 "${THUMBS_DIR}/${basename}"
    echo "${basename} thumbnail created" >> ${LOG_FILE}
  fi
done

echo "All thumbnail generation is completed." >> ${LOG_FILE}

# restore original IFS value
IFS=${IFS_ORIG}

# update a marker file
echo '{"thumbs":"DONE"}' > ${OUTPUT_DIR}/thumb-gen.json
