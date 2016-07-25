#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json

"""
  /usr/local/bin/file_lister.py
  script to list all movie files in the CONTENTS_DIR
  TODO CONTENTS_DIR can be specified via command line
"""

if __name__ == "__main__":
    CONTENTS_DIR = "/mnt"
    #CONTENTS_DIR = "ext-content"
    all_files = os.listdir(CONTENTS_DIR)
    video_files = sorted([a_file for a_file in all_files
        if not a_file.startswith('.') and a_file.lower().endswith('.mp4')])
    with open('/var/www/html/data/video_list.json', 'w') as the_file:
        the_file.write(json.dumps(video_files))
