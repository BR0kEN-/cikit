import re
import sys
import errno
import unittest
from contextlib import contextmanager


class EnsureVersionTestCase(unittest.TestCase):
    versions_incorrect = [
        {
            'versions': {
                'min': '2.4.3',
                'current': '2.4.2',
            },
            'unsupported': {
                '2.5.0': ['somevalue', '2'],
            },
            'result':
                """
                |ERROR: You must have Ansible version greater or equal to 2.4.3 while the current one is 2.4.2.
                |Please bear in mind the following versions are not supported too:
                |  - 2.5.0
                |    - somevalue
                |    - 2
                """,
        },
        {
            'versions': {
                'min': '2.4.3',
                'current': '2.5.1',
            },
            'unsupported': {
                '2.5.1': ['1', '2'],
            },
            'result':
                """
                |ERROR: Ansible 2.5.1 is not supported due to the following issues:
                |  - 1
                |  - 2
                """,
        },
        {
            'versions': {
                'min': '2.4.3',
                'current': '2.5.1',
            },
            'unsupported': {
                '2.5.1': ['1', '2'],
                '2.5.2': ['3', '4'],
            },
            'result':
                """
                |ERROR: Ansible 2.5.1 is not supported due to the following issues:
                |  - 1
                |  - 2
                |Please bear in mind the following versions are not supported too:
                |  - 2.5.2
                |    - 3
                |    - 4
                """,
        },
    ]

    versions_correct = [
        {
            'args': {
                'min': '2.4.3',
                'current': '2.4. 3devel',
            },
            'result': [2, 4, ' '],
        },
        {
            'args': {
                'min': '2.0.0',
                'current': '2.5.0-beta',
            },
            'result': [2, 5, 0],
        },
        {
            'args': {
                'min': '2.0.0',
                'current': '2.6.0devel',
            },
            'result': [2, 6, 0],
        },
        {
            'args': {
                'min': '2.0.0',
                'current': '  \n2.6.0adadsasd',
            },
            'result': [2, 6, 0],
        },
    ]

    def setUp(self):
        # Must be imported after "stdout" and "stderr" were spoofed by "StringIO".
        self.lib = __import__('__init__')

    @contextmanager
    def assertStderr(self, exception_type, expected_code, expected_message):
        # Erase previously stored data.
        sys.stderr.buf = ''

        try:
            yield
        except exception_type as exception:
            self.assertEqual(exception.code, expected_code)
            self.assertEqual(
                sys.stderr.getvalue(),
                '\x1b[91m%s\x1b[0m\n' % re.sub(r'\n\s+?\|', '\n', expected_message.strip().lstrip('|'))
            )
        else:
            self.fail('The expected exception was not thrown!')

    def test_versions_incorrect(self):
        for case in self.versions_incorrect:
            with self.assertStderr(SystemExit, errno.EINVAL, case['result']):
                self.lib.cikit.functions.ensure_version(case['versions'], case['unsupported'])

    def test_versions_correct(self):
        for case in self.versions_correct:
            self.assertEqual(case['result'], self.lib.cikit.functions.ensure_version(case['args']).version)

    def test_arguments_incorrect(self):
        with self.assertRaisesRegexp(KeyError, 'current'):
            self.lib.cikit.functions.ensure_version({})

        with self.assertRaisesRegexp(KeyError, 'min'):
            self.lib.cikit.functions.ensure_version({
                'current': '2.4.2',
            })

        with self.assertRaisesRegexp(AttributeError, "'NoneType' object has no attribute 'strip'"):
            self.lib.cikit.functions.ensure_version({
                'current': None,
            })

        with self.assertRaisesRegexp(ValueError, 'The version must be in "X.Y.Z" format.'):
            self.lib.cikit.functions.ensure_version({
                'current': '',
            })

        with self.assertRaisesRegexp(TypeError, "argument of type 'int' is not iterable"):
            self.lib.cikit.functions.ensure_version({
                'min': '0.0.9',
                'current': '1.0.0',
            }, 12)


if __name__ == '__main__':
    unittest.main(buffer=True)
