import unittest
import file_lister
import shutil
import os
import json

class TestFileLister(unittest.TestCase):

    TMP_BUBBLE_DIR = '/tmp/bubble'
    MEDIA_FILES_LIST = TMP_BUBBLE_DIR + '/media_files_list.json'

    @classmethod
    def setUpClass(cls):
        os.makedirs(TestFileLister.TMP_BUBBLE_DIR)

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TestFileLister.TMP_BUBBLE_DIR)

    def test_list_media_dirs(self):
        self.assertEqual(sorted(file_lister.list_media_dirs('../test')), ['Documents', 'Music', 'Photos', 'Videos'])

    def test_list_media_dirs__not_found(self):
        self.assertEqual(file_lister.list_media_dirs('../test/misc'), [])

    def test_list_files(self):
        media_filter = file_lister.file_filter(('.mp4', '.webm'));
        self.assertEqual(file_lister.list_files('../test', 'Videos', media_filter),
            ['video-1.mp4', 'video-2.mp4', 'video-3.mp4', 'video-4.webm'])

    def test_list_files__no_match_found(self):
        media_filter = file_lister.file_filter(('.mkv'));
        self.assertEqual(file_lister.list_files('../test', 'Videos', media_filter), [])

    def test_file_filter(self):
        ext_filter = file_lister.file_filter(('.md', '.txt'))
        self.assertTrue(ext_filter('README.md'))
        self.assertTrue(ext_filter('sample.txt'))

    def test_file_filter__no_match(self):
        ext_filter = file_lister.file_filter(('.txt'))
        self.assertFalse(ext_filter('video-2.mp4'))

    def test_create_file_list_json(self):
        input_json = '''
            {"photos":{"files":[],"dir":"Photos"},"documents":{"files":["sample01.pdf"],"dir":"Documents"},"music":{"files":["audio-1.mp3"],"dir":"Music"},"videos":{"files":["video-1.mp4","video-2.mp4"],"dir":"Videos"}}
            '''
        file_lister.create_file_list_json(TestFileLister.TMP_BUBBLE_DIR, input_json)
        self.assertTrue(os.path.isfile(TestFileLister.MEDIA_FILES_LIST))
        output_json = json.loads(open(TestFileLister.MEDIA_FILES_LIST).read())
        self.assertEqual(output_json, input_json)

    def test_create_file_list_json__empty_json(self):
        input_json = {}
        file_lister.create_file_list_json(TestFileLister.TMP_BUBBLE_DIR, input_json)
        self.assertTrue(os.path.isfile(TestFileLister.MEDIA_FILES_LIST))
        output_json = json.loads(open(TestFileLister.MEDIA_FILES_LIST).read())
        self.assertEqual(output_json, input_json)

if __name__ == '__main__':
    unittest.main()
