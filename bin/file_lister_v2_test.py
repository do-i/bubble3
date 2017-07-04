import filecmp
import json
import os
import shutil
import unittest
import file_lister_v2

class FileListerV2Test(unittest.TestCase):
    """
    Unit tests for file_lister_v2.py module.
    Usage: $ python -m unittest file_lister_v2_test
    """
    TMP_BUBBLE_DIR = '/tmp/bubble'
    MEDIA_FILES_LIST = TMP_BUBBLE_DIR + '/media_files_list_v2.json'

    @classmethod
    def setUpClass(cls):
        shutil.rmtree(FileListerV2Test.TMP_BUBBLE_DIR)
        os.makedirs(FileListerV2Test.TMP_BUBBLE_DIR)

    def test_create_file_list_json(self):
        data = [
            {'category': 'Text', 'file_ext': '.txt', 'id': 1, 'dir': '../test/Custom', 'title': 'file1'},
            {'category': 'Image', 'file_ext': '.tiff', 'id': 2, 'dir': '../test/Custom/level2b', 'title': 'fake_image'},
            {'category': 'Video', 'file_ext': '.mp4', 'id': 3, 'dir': '../test/Custom/level2b', 'title': 'fake_video'},
            {'category': 'Audio', 'file_ext': '.mp3', 'id': 4, 'dir': '../test/Custom/level2b', 'title': 'fake_audio'},
            {'category': 'Text', 'file_ext': '.txt', 'id': 5, 'dir': '../test/Custom/level2b', 'title': 'file2b'},
            {'category': 'Image', 'file_ext': '.png', 'id': 6, 'dir': '../test/Custom/level2b', 'title': 'fake_image'},
            {'category': 'Audio', 'file_ext': '.ogg', 'id': 7, 'dir': '../test/Custom/level2b', 'title': 'fake_audio'},
            {'category': 'Image', 'file_ext': '.tif', 'id': 8, 'dir': '../test/Custom/level2b', 'title': 'fake_image'}]
        file_lister_v2.create_file_list_json(FileListerV2Test.TMP_BUBBLE_DIR, data)
        self.assertTrue(os.path.isfile(FileListerV2Test.MEDIA_FILES_LIST))
        output_json = json.loads(open(FileListerV2Test.MEDIA_FILES_LIST).read())
        self.assertEqual(output_json, data)

    def test_walk_dir_level0(self):
        self.assertEquals(len(file_lister_v2.walk_dir('../test/', 0)), 0)

    def test_walk_dir_level1(self):
        expected = [{'category': 'Text', 'dir': '../test/Custom', 'file_ext': '.txt', 'id': 1, 'title': 'file1'}]
        self.assertEquals(file_lister_v2.walk_dir('../test/Custom', 1), expected)

    def test_walk_dir_lvel3(self):
        expected = [
            {'category': 'Text', 'file_ext': '.txt', 'id': 1, 'dir': '../test/Custom', 'title': 'file1'},
            {'category': 'Image', 'file_ext': '.tiff', 'id': 2, 'dir': '../test/Custom/level2b', 'title': 'fake_image'},
            {'category': 'Video', 'file_ext': '.mp4', 'id': 3, 'dir': '../test/Custom/level2b', 'title': 'fake_video'},
            {'category': 'Audio', 'file_ext': '.mp3', 'id': 4, 'dir': '../test/Custom/level2b', 'title': 'fake_audio'},
            {'category': 'Text', 'file_ext': '.txt', 'id': 5, 'dir': '../test/Custom/level2b', 'title': 'file2b'},
            {'category': 'Image', 'file_ext': '.png', 'id': 6, 'dir': '../test/Custom/level2b', 'title': 'fake_image'},
            {'category': 'Audio', 'file_ext': '.ogg', 'id': 7, 'dir': '../test/Custom/level2b', 'title': 'fake_audio'},
            {'category': 'Image', 'file_ext': '.tif', 'id': 8, 'dir': '../test/Custom/level2b', 'title': 'fake_image'},
            {'category': 'Video', 'file_ext': '.webm', 'id': 9, 'dir': '../test/Custom/level2b', 'title': 'fake_video'},
            {'category': 'Image', 'file_ext': '.jpg', 'id': 10, 'dir': '../test/Custom/level2b', 'title': 'fake_image'},
            {'category': 'Text', 'file_ext': '.txt', 'id': 11, 'dir': '../test/Custom/level2b/level3b', 'title': 'file3b'},
            {'category': 'Text', 'file_ext': '.txt', 'id': 12, 'dir': '../test/Custom/level2', 'title': 'file2'},
            {'category': 'Documents', 'file_ext': '.pdf', 'id': 13, 'dir': '../test/Custom/level2', 'title': 'sample01'},
            {'category': 'Unsupported', 'file_ext': '', 'id': 14, 'dir': '../test/Custom/level2', 'title': 'no_ext'},
            {'category': 'Unsupported', 'file_ext': '.zip', 'id': 15, 'dir': '../test/Custom/level2/level3', 'title': 'fake_unsupported'},
            {'category': 'Text', 'file_ext': '.txt', 'id': 16, 'dir': '../test/Custom/level2/level3', 'title': 'file3'}]
        actual_files = file_lister_v2.walk_dir('../test/Custom', 3)
        self.assertEqual(len(actual_files), len(expected))
        self.assertEquals(actual_files, expected)

    def test_walk_dir_level5(self):
        self.assertEquals(len(file_lister_v2.walk_dir('../test/', 5)), 45)


    def test_customize_ui_background_image__custom_image(self):
        file_lister_v2.customize_ui_background_image('../test', FileListerV2Test.TMP_BUBBLE_DIR)
        self.assertTrue(filecmp.cmp(
            os.path.join(FileListerV2Test.TMP_BUBBLE_DIR, 'background.jpg'),
            os.path.join('../test', 'background.jpg')))

    def ztest_customize_ui_background_image__default_image(self):
        shutil.copyfile(
            os.path.join('../test/Photos', 'sample03.jpg'),
            os.path.join(FileListerV2Test.TMP_BUBBLE_DIR, 'background_default.jpg'))
        file_lister_v2.customize_ui_background_image('../test/Photos', FileListerV2Test.TMP_BUBBLE_DIR)
        self.assertTrue(filecmp.cmp(
            os.path.join(FileListerV2Test.TMP_BUBBLE_DIR, 'background.jpg'),
            os.path.join(FileListerV2Test.TMP_BUBBLE_DIR, 'background_default.jpg')))

if __name__ == '__main__':
    unittest.main()
