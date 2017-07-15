#!/bin/bash

cd /mnt && tree -J | jq . > /var/www/html/data/media_files_list_v3.json
