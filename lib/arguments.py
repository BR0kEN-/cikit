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
    '--dry-run',
    action='store_true',
    help='Run CIKit without passing the control to Ansible.',
)

parser.add_argument(
    '--list-tags',
    action='store_true',
    help='Print available tags for a given playbook.',
)

parser.add_argument(
    '--tags',
    default=[],
    action='append',
    nargs='?',
    help=(
        'A list of tags to run a playbook with. You can specify them either in '
        'comma-separated format or pass as much as needed options with a single value.'
    ),
)

parser.add_argument(
    '--limit',
    metavar='HOST',
    nargs='?',
    help=(
        'The host to run a playbook at. The value of this option must be an '
        'alias of a host from the "CIKIT_PROJECT_DIR/.cikit/inventory" file.'
    ),
)

parser.add_argument(
    '--project-dir',
    metavar='DIR',
    nargs='?',
    help=(
        'The path to directory with CIKit project. Not needed if you are '
        'currently in a directory with it.'
    ),
)

args, argv = parser.parse_known_args()
args.extra = {}

parse_extra_vars(argv, args.extra)

# Pass tags to a playbook.
args.extra['tags'] = args.tags
# Duplicate the "limit" option as "extra" because some playbooks may
# require it and required options are checked within the "extra" only.
args.extra['limit'] = args.limit

del argv
