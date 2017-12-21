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
COMMAND = 'ansible-playbook'

if variables.INSIDE_VM_OR_CI and not variables.INSIDE_PROJECT_DIR:
    functions.error('The "%s" directory does not store CIKit project.' % variables.dirs['project'], errno.ENOTDIR)

if '' == args.playbook:
    if not variables.INSIDE_VM_OR_CI:
        for group in ['host', 'matrix']:
            functions.playbooks_print(variables.dirs['self'], '%s/' % group)

    functions.playbooks_print(variables.dirs['scripts'])

    sys.exit(0)

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

    ENV_CONFIG = variables.dirs['cikit'] + '/environment.yml'

    if os.path.isfile(ENV_CONFIG):
        ansible_executable = functions.call('which', COMMAND)

        if '' == ansible_executable:
            # Only warn and do not fail the execution because it's possible to continue without
            # these values. The command may be not found in a case it is set as an "alias".
            functions.warn(
                (
                    'Cannot read environment configuration from "%s". Looks '
                    'like Python setup cannot provide Ansible operability.'
                )
                %
                (
                    ENV_CONFIG
                )
            )
        else:
            # It's an interesting trick for detecting Python interpreter. Sometimes it
            # may differ. Especially on MacOS, when Ansible installed via Homebrew. For
            # instance, "which python" returns the "/usr/local/Cellar/python/2.7.13/
            # Frameworks/Python.framework/Versions/2.7/bin/python2.7", but this particular
            # setup may not have necessary packages for full Ansible operability. Since
            # Ansible - is a Python scripts, they must have a shadebag line with a path
            # to interpreter they should run by. Grab it and try!
            # Given:
            #   $(realpath $(which python)) -c 'import yaml'
            # Ends by:
            #   Traceback (most recent call last):
            #     File "<string>", line 1, in <module>
            #   ImportError: No module named yaml
            # But:
            #   $(cat $(which "ansible-playbook") | head -n1 | tr -d '#!') -c 'import yaml'
            # Just works.
            with open(ansible_executable) as ansible_executable:
                for key, value in json.loads(
                    functions.call(
                        ansible_executable.readline().lstrip('#!').rstrip(),
                        '-c',
                        'import yaml, json\nprint json.dumps(yaml.load(open(\'%s\')))' % ENV_CONFIG,
                    )
                ).iteritems():
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

if args.limit:
    PARAMS.append("-l '%s'" % args.limit)
    # When the "--limit" has value in "a.b" form then it means the "a"
    # represents the name of a matrix that stores a droplet "b". If no
    # dots in string, then it could be a matrix or an external droplet.
    variables.dirs['credentials'] += '/%s' % args.limit.replace('.', '/')
else:
    PARAMS.append("-i 'localhost,'")

if args.extra:
    PARAMS.append("-e '%s'" % json.dumps(args.extra))

PARAMS.append("-i '%s/inventory'" % variables.dirs['lib'])
PARAMS.append("-e __selfdir__='%s'" % variables.dirs['self'])
PARAMS.append("-e __targetdir__='%s'" % variables.dirs['project'])
PARAMS.append("-e __credentialsdir__='%s'" % variables.dirs['credentials'])

# https://github.com/sclorg/s2i-python-container/pull/169
os.environ['PYTHONUNBUFFERED'] = '1'
# https://github.com/ansible/ansible/blob/devel/lib/ansible/config/data/config.yml
os.environ['ANSIBLE_ROLES_PATH'] = variables.dirs['cikit'] + '/roles'
os.environ['ANSIBLE_PIPELINING'] = '1'
os.environ['ANSIBLE_FORCE_COLOR'] = '1'
os.environ['DISPLAY_SKIPPED_HOSTS'] = '0'
os.environ['ANSIBLE_RETRY_FILES_ENABLED'] = '0'

COMMAND = "%s '%s' %s" % (COMMAND, PLAYBOOK, ' '.join(PARAMS))

# Print entire command if verbosity requested.
if 'ANSIBLE_VERBOSITY' in os.environ:
    print COMMAND

if not args.dry_run:
    sys.exit(call([COMMAND], shell=True))
