#!/bin/bash
# Copyright (c) 2016 Joji Doi
# This script creates a compressed tar file.
# Run this script in bin/
BIN_DIR=$(pwd)
WORK_DIR=$(dirname "${BIN_DIR}")
mkdir -p ${WORK_DIR}/tmp
DATE_PREFIX=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${WORK_DIR}/tmp/${DATE_PREFIX}.tgz"

echo ${OUTPUT_FILE}

cd ${WORK_DIR}/web && tar -czf ${OUTPUT_FILE} *
cd ${WORK_DIR}
