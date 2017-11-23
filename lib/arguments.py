from actions import VersionAction
from argparse import ArgumentParser
from functions import parse_extra_vars

parser = ArgumentParser(
    prog='cikit',
    add_help=False,
)

parser.add_argument(
    'playbook',
    nargs='?',
    default='',
    help='The name of a playbook to run.',
)

parser.add_argument(
    '--help',
    action='help',
    help='Show this help message and exit.',
)

parser.add_argument(
    '--version',
    dest='../.version.txt',
    action=VersionAction,
    default='1.0.0',
)

parser.add_argument(
    '--dry-run',
    action='store_true',
    help='Run CIKit without passing the control to Ansible.',
)

parser.add_argument(
    '--limit',
    metavar='HOST',
    nargs='?',
    help=(
        'The host to run a playbook at. The value of this option must '
        'be an alias of a host from the "%%s/.cikit/inventory" file.'
    ),
)

args, argv = parser.parse_known_args()
args.extra = {}

parse_extra_vars(argv, args.extra)

# Duplicate the "limit" option as "extra" because some playbooks may
# require it and required options are checked within the "extra" only.
if args.limit:
    args.extra['limit'] = args.limit

del argv
