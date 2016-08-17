#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 2016 Joji Doi

import os
import json

"""
  /usr/local/bin/file_lister.py
  script to list all movie files in the CONTENTS_DIR
  TODO CONTENTS_DIR can be specified via command line
"""

def create_file_list_json(extention, output_file):
    CONTENTS_DIR = "/mnt"
    #CONTENTS_DIR = "ext-content"
    all_files = os.listdir(CONTENTS_DIR)
    content_files = sorted([a_file for a_file in all_files
        if not a_file.startswith('.') and a_file.lower().endswith(extention)])
    destination = os.path.join('/var/www/html/data/', output_file)
    with open(destination, 'w') as the_file:
        the_file.write(json.dumps(content_files))

if __name__ == "__main__":
    create_file_list_json('.mp4', 'video_list.json')
    create_file_list_json('.jpg', 'jpg_list.json')
    create_file_list_json('.png', 'png_list.json')
    create_file_list_json('.pdf', 'pdf_list.json')
    create_file_list_json('.mp3', 'mp3_list.json')
