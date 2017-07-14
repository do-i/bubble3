#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 2017 Joji Doi

import argparse
import json
import os
import shutil

UNSUPPORTED = 'Unsupported'
MEDIA_TYPES = {
    '.pdf': 'Documents',
    '.txt': 'Text',
    '.mp3': 'Audio',
    '.ogg': 'Audio',
    '.jpg': 'Image',
    '.png': 'Image',
    '.tif': 'Image',
    '.tiff': 'Image',
    '.gif': 'Image',
    '.mp4': 'Video',
    '.webm': 'Video',
    '': UNSUPPORTED
    }

def create_file_list_json(output_dir, media_files):
    """
        Create a media file list in json format.
        Example output
    """
    with open(output_dir + '/media_files_list_v2.json', 'w') as the_file:
        the_file.write(json.dumps(media_files))


def walk_dir(dir_name, level):
    dir_offset = len(dir_name)
    output = []
    id = 1
    # depth_delta is an offset to directory depth.
    depth_delta = len(dir_name.split(os.sep)) - 1
    for root, dirs, files in os.walk(dir_name):
        path = root.split(os.sep)
        if len(path) - depth_delta > level:
            continue
        for media_file in files:
            name, ext = os.path.splitext(media_file)
            category = MEDIA_TYPES.get(ext.lower(), UNSUPPORTED)
            output.append({
                "id": id,
                "category": category,
                "title": name,
                "file_ext": ext,
                "dir": root[dir_offset:]
                })
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
        help='directory for background.jpg to be created also contains background_default.jpg')
    parser.add_argument('-L', '--level', default=8,
        help='Max display depth of the directory tree')
    args = parser.parse_args()
    media_root = args.media_root
    output_dir = args.output_dir
    web_image_dir = args.image_dir
    dir_level = args.level

    create_file_list_json(output_dir, walk_dir(media_root, dir_level))
    customize_ui_background_image(media_root, web_image_dir)
