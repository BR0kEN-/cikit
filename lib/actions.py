from os import path
from argparse import _VersionAction


class VersionAction(_VersionAction):
    def __init__(self, option_strings, dest='', default=None, help="Show program's version number and exit."):
        super(VersionAction, self).__init__(
            option_strings=option_strings,
            default=default,
            version=None,
            help=help,
            dest=dest,
        )

    def __call__(self, parser, namespace, values, option_string=None):
        if path.isfile(self.dest):
            with open(self.dest) as version:
                self.version = version.readline().strip()
        else:
            self.version = self.default

        super(VersionAction, self).__call__(parser, namespace, values, option_string)
