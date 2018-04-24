import os
import unittest
import __init__ as lib


class ParseExtraVarsTestCase(unittest.TestCase):
    def test_parse(self):
        # The "EXTRA_VARS" environment variable overrides options from CLI.
        os.environ['EXTRA_VARS'] = '--bla=13 -test=13 --test=\'[1, 2, {"b": "c"}]\''

        bag = {}
        argv = lib.cikit.functions.parse_extra_vars(
            ['--bla=12', 'bash -c "ls -la /"', '-test=12', '--test={"b": "c"}'],
            bag
        )

        self.assertEqual('13', bag['bla'])
        self.assertEqual('[1, 2, {"b": "c"}]', bag['test'])
        self.assertEqual(['bash -c "ls -la /"', '-test=12', '-test=13'], argv)


if __name__ == '__main__':
    unittest.main()
