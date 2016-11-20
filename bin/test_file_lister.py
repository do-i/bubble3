import unittest
import file_lister
import shutil
import os
import json

class TestFileLister(unittest.TestCase):
    """
    Unit tests for file_lister.py module.
    Usage: $ python -m unittest test_file_lister
    """
    TMP_BUBBLE_DIR = '/tmp/bubble'
    MEDIA_FILES_LIST = TMP_BUBBLE_DIR + '/media_files_list.json'

    @classmethod
    def setUpClass(cls):
        os.makedirs(TestFileLister.TMP_BUBBLE_DIR)

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TestFileLister.TMP_BUBBLE_DIR)

    def test_list_media_dirs(self):
        self.assertEqual(file_lister.list_media_dirs('../test'), ['Books', 'Documents', 'Music', 'Photos', 'TV', 'Videos'])

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

    def test_list_media_files(self):
        expected_json = [
            {'category': 'books', 'file_ext': '.pdf', 'id': 0, 'dir': 'Books', 'title': 'sample03'},
            {'category': 'documents', 'file_ext': '.txt', 'id': 1, 'dir': 'Documents', 'title': 'donreadme'},
            {'category': 'documents', 'file_ext': '.pdf', 'id': 2, 'dir': 'Documents', 'title': 'sample01'},
            {'category': 'documents', 'file_ext': '.pdf', 'id': 3, 'dir': 'Documents', 'title': 'sample02'},
            {'category': 'music', 'file_ext': '.mp3', 'id': 4, 'dir': 'Music', 'title': 'audio-1'},
            {'category': 'music', 'file_ext': '.ogg', 'id': 5, 'dir': 'Music', 'title': 'audio-2'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 6, 'dir': 'Photos', 'title': 'sample01'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 7, 'dir': 'Photos', 'title': 'sample02'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 8, 'dir': 'Photos', 'title': 'sample03'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 9, 'dir': 'Photos', 'title': 'sample04'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 10, 'dir': 'Photos', 'title': 'sample05'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 11, 'dir': 'Photos', 'title': 'sample06'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 12, 'dir': 'Photos', 'title': 'sample07'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 13, 'dir': 'Photos', 'title': 'sample08'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 14, 'dir': 'Photos', 'title': 'sample09'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 15, 'dir': 'Photos', 'title': 'sample10'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 16, 'dir': 'Photos', 'title': 'sample11'},
            {'category': 'photos', 'file_ext': '.jpg', 'id': 17, 'dir': 'Photos', 'title': 'sample12'},
            {'category': 'tv', 'file_ext': '.mp4', 'id': 18, 'dir': 'TV', 'title': 'white space'},
            {'category': 'videos', 'file_ext': '.mp4', 'id': 19, 'dir': 'Videos', 'title': 'video-1'},
            {'category': 'videos', 'file_ext': '.mp4', 'id': 20, 'dir': 'Videos', 'title': 'video-2'},
            {'category': 'videos', 'file_ext': '.mp4', 'id': 21, 'dir': 'Videos', 'title': 'video-3'},
            {'category': 'videos', 'file_ext': '.webm', 'id': 22, 'dir': 'Videos', 'title': 'video-4'}]

        media_list = file_lister.list_media_files('../test', ['Books', 'Documents', 'Music', 'Photos', 'TV', 'Videos'])
        self.assertEqual(len(media_list), len(expected_json))
        self.assertEqual(media_list, expected_json)

if __name__ == '__main__':
    unittest.main()
