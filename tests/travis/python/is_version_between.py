import unittest
import __init__ as lib


class IsVersionBetweenTestCase(unittest.TestCase):
    def test_wrong_versions(self):
        with self.assertRaises(SystemExit):
            lib.cikit.functions.is_version_between('2.2.2', {
                'min': '2.4.3',
                'max': '2.5.0',
            })

        with self.assertRaises(SystemExit):
            lib.cikit.functions.is_version_between('2.5.1', {
                'min': '2.4.3',
                'max': '2.5.0',
            })

    def test_correct_versions(self):
        current = lib.cikit.functions.is_version_between('2.4. 9devel', {
            'min': '2.4.3',
            'max': '2.5.0',
        })

        self.assertEqual(2, current.version[0])
        self.assertEqual(4, current.version[1])
        self.assertEqual(' ', current.version[2])

        current = lib.cikit.functions.is_version_between('2.5.0-beta', {
            'min': '2.4.3',
            'max': '2.5.0',
        })

        self.assertEqual(2, current.version[0])
        self.assertEqual(5, current.version[1])
        self.assertEqual(0, current.version[2])


if __name__ == '__main__':
    unittest.main()
