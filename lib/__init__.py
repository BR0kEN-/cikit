import os
import sys
import json
import errno
import shlex
import functions
import variables
from subprocess import call
from arguments import args
from re import search

PARAMS = []

if variables.INSIDE_VM_OR_CI and not variables.INSIDE_PROJECT_DIR:
    functions.error('The "%s" directory does not store CIKit project.' % variables.dirs['project'], errno.ENOTDIR)

if '' == args.playbook:
    if not variables.INSIDE_VM_OR_CI:
        for group in ['env', 'host', 'matrix']:
            functions.playbooks_print(variables.dirs['self'], '%s/' % group)

    functions.playbooks_print(variables.dirs['scripts'])

    sys.exit(0)
elif 'ssh' == args.playbook:
    # Read the configuration of a project we're currently in.
    hostname = functions.get_hostname(variables.read_yaml(variables.dirs['cikit'] + '/config.yml'))

    if '' != hostname:
        sys.exit(call(['docker exec -it %s bash' % hostname], shell=True))

PLAYBOOK = functions.playbooks_find(
    variables.dirs['scripts'] + '/' + args.playbook,
    # Load playbooks from non "scripts" directory within the CIKit package.
    variables.dirs['self'] + '/' + args.playbook,
    args.playbook,
)

if None is PLAYBOOK:
    functions.error('The "%s" command is not available.' % args.playbook, errno.ENFILE)

if 'CIKIT_LIST_TAGS' in os.environ:
    PARAMS.append('--list-tags')
else:
    # The "cikit provision" run without required "--limit" option.
    if args.playbook.endswith('provision') and not args.limit:
        hostname = functions.get_hostname(variables.read_yaml(variables.dirs['cikit'] + '/config.yml'))

        if '' != hostname:
            # http://blog.oddbit.com/2015/10/13/ansible-20-the-docker-connection-driver
            args.limit = hostname + ','

            PARAMS.append("-i '%s'" % args.limit)
            PARAMS.append("-c 'docker'")
            PARAMS.append("-u 'root'")

    # Duplicate the "limit" option as "extra" because some playbooks may
    # require it and required options are checked within the "extra" only.
    if args.limit:
        args.extra['limit'] = args.limit

    for line in open(PLAYBOOK):
        if search('^# requires-project-root$', line) and not variables.INSIDE_PROJECT_DIR:
            functions.error(
                'Execution of the "%s" is available only within the CIKit-project directory.' % args.playbook,
                errno.ENOTDIR,
            )

        # "ro" - is an acronym of the "required option".
        matches = search('^# ro:(.+?)$', line)

        if matches:
            option = matches.group(1)

            if option not in args.extra or not isinstance(args.extra[option], basestring) or len(args.extra[option]) < 2:
                functions.error(
                    (
                        'The "--%s" option is required for the "%s" command and '
                        'currently missing or has a value less than 2 symbols.'
                    )
                    %
                    (
                        option,
                        args.playbook
                    ),
                    errno.EPERM
                )

    for key, value in variables.read_yaml(variables.dirs['cikit'] + '/environment.yml').iteritems():
        # Add the value from environment config only if it's not specified as
        # an option to the command.
        if key not in args.extra:
            args.extra[key] = value

    if 'EXTRA_VARS' in os.environ:
        functions.parse_extra_vars(shlex.split(os.environ['EXTRA_VARS']), args.extra)

    if 'ANSIBLE_INVENTORY' in os.environ:
        PARAMS.append("-i '%s'" % os.environ['ANSIBLE_INVENTORY'])

    # @todo Improve for Ansible 2.5 - https://github.com/ansible/ansible/pull/30722
    # Remove these lines and adjust docs in favor of "ANSIBLE_RUN_TAGS" environment variable.
    if 'CIKIT_TAGS' in os.environ:
        PARAMS.append("-t '%s'" % os.environ['CIKIT_TAGS'])

# Require privileged execution of CIKit upgrades.
if 'self-update' == args.playbook:
    PARAMS.append('--ask-become-pass')

if args.limit and 'localhost' != args.limit:
    PARAMS.append("-l '%s'" % args.limit)
    # When the "--limit" has value in "a.b" form then it means the "a"
    # represents the name of a matrix that stores a droplet "b". If no
    # dots in string, then it could be a matrix or an external droplet.
    variables.dirs['credentials'] += '/%s' % args.limit.replace('.', '/')
else:
    PARAMS.append("-c 'local'")
    PARAMS.append("-i 'localhost,'")

if args.extra:
    PARAMS.append("-e '%s'" % json.dumps(args.extra))

PARAMS.append("-i '%s/inventory'" % variables.dirs['lib'])
PARAMS.append("-e __selfdir__='%s'" % variables.dirs['self'])
PARAMS.append("-e __targetdir__='%s'" % variables.dirs['project'])
PARAMS.append("-e __credentialsdir__='%s'" % variables.dirs['credentials'])

# https://github.com/sclorg/s2i-python-container/pull/169
os.environ['PYTHONUNBUFFERED'] = '1'
# https://github.com/ansible/ansible/blob/devel/lib/ansible/config/base.yml
os.environ['ANSIBLE_ROLES_PATH'] = variables.dirs['cikit'] + '/roles'
os.environ['ANSIBLE_PIPELINING'] = '1'
os.environ['ANSIBLE_FORCE_COLOR'] = '1'
os.environ['DISPLAY_SKIPPED_HOSTS'] = '0'
os.environ['ANSIBLE_RETRY_FILES_ENABLED'] = '0'

COMMAND = "%s '%s' %s" % (variables.ANSIBLE_COMMAND, PLAYBOOK, ' '.join(PARAMS))

# Print entire command if verbosity requested.
if 'ANSIBLE_VERBOSITY' in os.environ:
    print COMMAND

if not args.dry_run:
    sys.exit(call([COMMAND], shell=True))
