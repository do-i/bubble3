#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 2016 Joji Doi

import os
import json

"""
  /usr/local/bin/file_lister.py
  script to list all movie files in the CONTENTS_DIR
"""
CONTENTS_DIR = "/mnt"
#TODO pass override value for CONTENTS_DIR
#CONTENTS_DIR = "../test"

""" MEDIA_TYPES -- key is folder name, value is a tuple of supported file extensions """
MEDIA_TYPES = {
    "Documents": ('.pdf', '.txt'),
    "Music": ('.mp3', '.ogg'),
    "Photos": ('.png', '.jpg'),
    "Videos": ('.mp4', '.webm')
    }
OUTPUT_FILE = '/var/www/html/data/media_files_list.json'

def create_file_list_json(media_files):
    """
        Create a media file list in json format.
        Example output
        {
          "photos": [
            "contact-bg.jpg",
            "favicon.png",
            "header-bg-ppl-8s.png"
          ],
          "documents": [
            "sample01.pdf",
            "sample02.pdf",
            "sample03.pdf"
          ],
          "music": [
            "audio-1.mp3",
            "audio-2.ogg"
          ],
          "videos": [
            "video-1.mp4",
            "video-2.mp4",
            "video-3.mp4",
            "video-x.webm"
          ]
        }
    """
    with open(OUTPUT_FILE, 'w') as the_file:
        the_file.write(json.dumps(media_files))

def file_filter(extensions):
    """
        This lambda function filters out hidden file (starts with '.') and non matched extension.
        argument:
        extensions -- tuple of file extensions string
    """
    return lambda a_file: not a_file.startswith('.') and a_file.lower().endswith(extensions)

def list_files(dirname, filter):
    """
        List files under specified directory returns filtered files.
        Sort by file name.
        arguments:
        dirname -- directory name
        filter  -- file filter function
    """
    all_files = os.listdir(os.path.join(CONTENTS_DIR, dirname))
    return sorted(a_file for a_file in all_files if filter(a_file))

if __name__ == "__main__":
    output = {}
    for key, value in MEDIA_TYPES.iteritems():
        output[key.lower()] = list_files(key, file_filter(value))
    create_file_list_json(output)
