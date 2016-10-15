#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 2016 Joji Doi

import argparse
import os
import json

"""
  /usr/local/bin/file_lister.py
  script to list all media files in the given --media-root dir
"""

""" MEDIA_TYPES -- key is supported folder name, value is a tuple of supported file extensions """
MEDIA_TYPES = {
    "documents": ('.pdf', '.txt'),
    "music": ('.mp3', '.ogg'),
    "photos": ('.png', '.jpg'),
    "videos": ('.mp4', '.webm')
    }

MEDIA_FOLDERS = MEDIA_TYPES.keys()
media_filter = lambda f: f.lower() in MEDIA_FOLDERS

def create_file_list_json(output_dir, media_files):
    """
        Create a media file list in json format.
        Example output
        {
          "photos": {
            "files": [
              "contact-bg.jpg",
              "favicon.png",
              "header-bg-ppl-8s.png"
            ],
            "dir": "Photos"
          },
          "documents": {
            "files": [
              "sample01.pdf",
              "sample02.pdf",
              "sample03.pdf"
            ],
            "dir": "Documents"
          },
          "music": {
            "files": [
              "audio-1.mp3",
              "audio-2.ogg"
            ],
            "dir": "Music"
          },
          "videos": {
            "files": [
              "video-1.mp4",
              "video-2.mp4",
              "video-3.mp4",
              "video-4.webm"
            ],
            "dir": "Videos"
          }
        }
    """
    with open(output_dir + '/media_files_list.json', 'w') as the_file:
        the_file.write(json.dumps(media_files))

def file_filter(extensions):
    """
        This lambda function filters out hidden file (starts with '.') and non matched extension.
        argument:
        extensions -- tuple of file extensions string
    """
    return lambda a_file: not a_file.startswith('.') and a_file.lower().endswith(extensions)

def list_files(media_root, dirname, filter):
    """
        List files under specified directory returns filtered files.
        Sort by file name.
        arguments:
        dirname -- directory name
        filter  -- file filter function
    """
    all_files = os.listdir(os.path.join(media_root, dirname))
    return sorted(a_file for a_file in all_files if filter(a_file))

def list_media_dirs(media_root):
    """
        Returns a list of media directories (case insensitive)
    """
    media_root = os.path.abspath(media_root);
    all_dirs = [ dirs for dirs in os.listdir(media_root)
        if os.path.isdir(os.path.join(media_root, dirs)) ]
    return filter(media_filter, all_dirs)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Media File Lister script parses')
    parser.add_argument('-m', '--media-root', default='/mnt', help='Media root location')
    parser.add_argument('-o', '--output-dir', default='/var/www/html/data',
        help='output json file')
    args = parser.parse_args()
    media_root = args.media_root
    output_dir = args.output_dir

    media_folders = list_media_dirs(media_root)
    output = {}
    for folder in media_folders:
        lowercase_folder = folder.lower()
        output[lowercase_folder] = {"dir": folder,
            "files": list_files(media_root, folder, file_filter(MEDIA_TYPES[lowercase_folder]))}
    create_file_list_json(output_dir, output)
