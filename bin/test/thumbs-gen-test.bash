#!/bin/bash
#
# Copyright (c) 2017 Joji Doi
#
# Test for Batch thumbnail generation script.
# Usage: sudo ./thumbs-gen-test.bash

SCRIPT=../thumbs-gen.bash
DATA=../../test
WORK_DIR=/tmp/$(date +%Y%m%d-%H%M%S)
PHOTOS_DIR=${WORK_DIR}/photos

function setup {
  mkdir -p ${PHOTOS_DIR}
}

function teardown {
  rm -r ${WORK_DIR}
}

function runtest {
  cp ${DATA}/Photos/sample01.jpg ${PHOTOS_DIR}/sample01.JPG
  cp ${DATA}/Photos/sample02.jpg ${PHOTOS_DIR}/sample02.jpg
  cp ${DATA}/Photos/sample03.jpg ${PHOTOS_DIR}/sample03.jpG
  export OUTPUT_DIR=${WORK_DIR}
  export IMAGE_DIR=${PHOTOS_DIR}
  ${SCRIPT}

  ### Assertions ###

  if [ -d ${PHOTOS_DIR}/thumbs ]; then
    echo "[PASS] thumbs dir created"
  else
    echo "[FAIL] thumbs dir not created"
    exit 1
  fi

  if [ -f ${PHOTOS_DIR}/thumbs/sample01.JPG ]; then
    echo "[PASS] thumbnail sample01.JPG created"
  else
    echo "[FAIL] thumbnail sample01.JPG not created"
    exit 1
  fi

  if [ -f ${PHOTOS_DIR}/thumbs/sample02.jpg ]; then
    echo "[PASS] thumbnail sample02.jpg created"
  else
    echo "[FAIL] thumbnail sample02.jpg not created"
    exit 1
  fi

  if [ -f ${PHOTOS_DIR}/thumbs/sample03.jpG ]; then
    echo "[PASS] thumbnail sample03.jpG created"
  else
    echo "[FAIL] thumbnail sample03.jpG not created"
    exit 1
  fi

  if [ "$(cat ${WORK_DIR}/thumb-gen.json)" == '{"thumbs":"DONE"}' ]; then
    echo "[PASS] thumb-gen.json has DONE state"
  else
    echo "[PASS] thumb-gen.json does not have DONE state"
    exit 1
  fi
}

setup && runtest && teardown
