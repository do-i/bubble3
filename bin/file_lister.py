#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 2016 Joji Doi

import argparse
import os
import json
import shutil

"""
  /usr/local/bin/file_lister.py
  script to list all media files in the given --media-root dir
"""

""" MEDIA_TYPES -- key is supported folder name, value is a tuple of supported file extensions """
MEDIA_TYPES = {
    "documents": ('.pdf', '.txt'),
    "books": ('.pdf', '.txt'),
    "music": ('.mp3', '.ogg'),
    "photos": ('.png', '.jpg'),
    "tv": ('.mp4', '.webm'),
    "videos": ('.mp4', '.webm')
    }

MEDIA_FOLDERS = MEDIA_TYPES.keys()
media_filter = lambda f: f.lower() in MEDIA_FOLDERS

def create_file_list_json(output_dir, media_files):
    """
        Create a media file list in json format.
        Example output
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
    return sorted(filter(media_filter, all_dirs))

def list_media_files(media_root, media_folders):
    """
        Returns a list of media files in the given folders
        arguments:
        media_root    -- root directory for the media_folders
        media_folders -- directories to be scanned

        Example output:
        [{"id": "1", "title":"Tears of Steel","file_ext":"mp4","category":"videos","dir":"Videos"}]
    """
    output = []
    id = 0
    for folder in media_folders:
        lowercase_folder = folder.lower()
        for media_file in list_files(media_root, folder, file_filter(MEDIA_TYPES[lowercase_folder])):
            name, ext = os.path.splitext(media_file)
            output.append({"id": id, "category": lowercase_folder, "title": name, "file_ext": ext, "dir": folder})
            id += 1
    return output

def customize_ui_background_image(media_root, web_image_dir):
    """
        If background.jpg file is provided in Media root directory, use this file.
        If not, then use background_default.jpg
    """
    src = os.path.join(web_image_dir, 'background_default.jpg')
    background_files = [ bg_file for bg_file in os.listdir(media_root)
        if os.path.isfile(os.path.join(media_root, bg_file))
            and bg_file.lower() == 'background.jpg' ]
    if len(background_files) > 0:
        custom_bg_img = background_files[0]
        src = os.path.join(media_root, custom_bg_img)
    dest = os.path.join(web_image_dir, 'background.jpg')
    shutil.copyfile(src, dest)
    os.chmod(dest, 0644)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Media File Lister script parses')
    parser.add_argument('-m', '--media-root', default='/mnt', help='Media root location')
    parser.add_argument('-o', '--output-dir', default='/var/www/html/data',
        help='output json file')
    parser.add_argument('-i', '--image-dir', default='/var/www/html/img',
        help='directory for background.jpg to be created also contains background_default.jpg ')
    args = parser.parse_args()
    media_root = args.media_root
    output_dir = args.output_dir
    web_image_dir = args.image_dir

    media_folders = list_media_dirs(media_root)
    create_file_list_json(output_dir, list_media_files(media_root, media_folders))
    customize_ui_background_image(media_root, web_image_dir)
