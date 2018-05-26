from __future__ import print_function
from re import escape
from os import path, environ
from sys import exit, stderr
from glob import glob
from time import strftime
from errno import EINVAL
from tempfile import gettempdir
from subprocess import Popen, PIPE
from distutils.version import LooseVersion
import shlex

ANSIBLE_COMMAND = 'ansible-playbook'
ANSIBLE_VERBOSITY = int(environ['ANSIBLE_VERBOSITY']) if 'ANSIBLE_VERBOSITY' in environ else 0


def playbooks_print(directory, prefix=''):
    for playbook in glob(directory + '/' + prefix + '*.yml'):
        print('- ' + prefix + path.splitext(path.basename(playbook))[0])


def playbooks_find(*paths):
    for variation in paths:
        variation = path.splitext(variation)[0] + '.yml'

        if path.exists(variation):
            return variation


def is_project_root(directory):
    return \
        path.isdir(directory + '/.cikit') and \
        path.exists(directory + '/.cikit/config.yml')


def call(*nargs, **kwargs):
    return Popen(nargs, stdout=PIPE, **kwargs).stdout.read().strip()


def parse_extra_vars(args, bag):
    if 'EXTRA_VARS' in environ:
        warn(
            'Be aware that CLI options may be overridden by values from "EXTRA_VARS" environment '
            'variable, that is "%s".'
            %
            (
                environ['EXTRA_VARS']
            ),
            2
        )

        args += shlex.split(environ['EXTRA_VARS'])

    copy = list(args)

    for arg in args:
        if arg.startswith('--', 0):
            pair = arg[2:].split('=', 1)

            if 1 == len(pair):
                pair.append(True)

            bag[pair[0].replace('-', '_')] = pair[1]
            copy.remove(arg)

    return copy


def ensure_version(versions, unsupported=None):
    """
    :param dict[str, str] versions:
        The required keys are "min" and "current". The value must be a valid X.Y.Z semver.
        Example:
        {
            'min': '2.4.3',
            'current': '2.0.1',
        }
    :param dict[str, list[str]] unsupported:
        Example:
        {
            '2.5.1': [
                # The list of issues that break the stuff.
                'https://github.com/ansible/ansible/issues/39007',
                'https://github.com/ansible/ansible/issues/39014',
            ],
        }
    :return LooseVersion:
        An instance of the "versions['current']".
    """
    for key, value in versions.iteritems():
        value = value.strip()

        if '' == value:
            raise ValueError('The version must be in "X.Y.Z" format.')

        versions[key] = LooseVersion(value.strip())
        # Allow 3 parts maximum.
        versions[key].version = versions[key].version[:3]

    version_current = str(versions['current'])
    error_message = []

    if unsupported is None:
        unsupported = {}

    def add_issues(text, version, spaces=2):
        return error_message.append(text % (version, ('\n%s- ' % (' ' * spaces)).join([''] + unsupported.pop(version))))

    if versions['current'] < versions['min']:
        error_message.append(
            'You must have Ansible version greater or equal to %s while the current one is %s.'
            %
            (
                versions['min'],
                versions['current'],
            )
        )

    if version_current in unsupported:
        add_issues('Ansible %s is not supported due to the following issues:%s', version_current)

    # An error exists when the current version is less than minimum required or when it's denied for usage.
    if bool(error_message):
        # The "add_issues()" pops the key from the "unsupported" dictionary so if there is only one item
        # and the current version isn't supported the dictionary will become empty.
        if bool(unsupported):
            error_message.append('Please bear in mind the following versions are not supported too:')

            # Show the other unsupported versions.
            for version_unsupported in unsupported.keys():
                add_issues('  - %s%s', version_unsupported, 4)

        error('\n'.join(error_message), EINVAL)

    return versions['current']


def process_credentials_dir(directory):
    # It's Docker provisioning.
    if directory.endswith(','):
        return directory.rstrip(',')

    # When the "--limit" has value in "a.b" form then it means the "a"
    # represents the name of a matrix that stores a droplet "b". If no
    # dots in string, then it could be a matrix or an external droplet.
    return directory.replace('.', '/')


def git(command, directory):
    process = Popen('git ' + command, cwd=directory, shell=True, stderr=PIPE, stdout=PIPE)
    out, err = process.communicate()

    if process.poll() > 0:
        raise Exception(err.strip())

    return out.strip()


def check_updates(directory):
    try:
        branch = git('rev-parse --abbrev-ref HEAD', directory)
        last_commit = git("ls-remote --refs | awk '/refs\/heads\/%s/ {print $1}'" % escape(branch), directory)

        if '' == last_commit:
            raise Exception('Unable to check for the updates.')

        # Compare hashes of the last commit in current and remote branches.
        if git('rev-parse HEAD', directory) == last_commit:
            print('You are using the latest version. There are no updates available.')
        else:
            warn('The new version is available. Consider "cikit self-update" to get new features and bug fixes.')
    except Exception, e:
        error(e.message, 14)


def get_hostname(config):
    # The name of Docker container for local development is forming based on the
    # hostname that is taken from the "site_url".
    if 'site_url' in config:
        return config['site_url'].split('//')[-1]

    return ''


def which(program):
    return call('which', program)


def error(message, code=1):
    print('\033[91mERROR: ' + message + '\033[0m', file=stderr)
    exit(code)


def warn(message, needed_verbosity=0):
    if ANSIBLE_VERBOSITY >= needed_verbosity:
        print('\033[93mWARNING: ' + message + '\033[0m')
