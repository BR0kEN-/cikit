from __future__ import print_function
from os import path, environ
from sys import exit, stderr
from glob import glob
from errno import EINVAL
from subprocess import Popen, PIPE
from distutils.version import LooseVersion
import shlex


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
    return Popen(nargs, stdout=PIPE, **kwargs).stdout.read().rstrip()


def parse_extra_vars(args, bag):
    if 'EXTRA_VARS' in environ:
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


def is_version_between(version_current, versions):
    versions.update({'cur': version_current})

    def fail(version_type, message):
        error(message % (versions[version_type], versions['cur']), EINVAL)

    for key, value in versions.iteritems():
        versions[key] = LooseVersion(value)
        # Allow 3 parts maximum.
        versions[key].version = versions[key].version[:3]

    if versions['cur'] < versions['min']:
        fail('min', 'You must have at least Ansible %s while the current version is %s.')
    elif versions['cur'] > versions['max']:
        fail('max', 'Maximum allowed version of Ansible must not be greater than %s while the current one is %s.')

    return versions['cur']


def process_credentials_dir(directory):
    # It's Docker provisioning.
    if directory.endswith(','):
        return directory.rstrip(',')

    # When the "--limit" has value in "a.b" form then it means the "a"
    # represents the name of a matrix that stores a droplet "b". If no
    # dots in string, then it could be a matrix or an external droplet.
    return directory.replace('.', '/')


def get_hostname(config):
    # The name of Docker container for local development is forming based on the
    # hostname that is taken from the "site_url".
    if 'site_url' in config:
        return config['site_url'].split('//')[-1]

    return ''


def error(message, code=1):
    print('\033[91mERROR: ' + message + '\033[0m', file=stderr)
    exit(code)


def warn(message):
    print('\033[93mWARNING: ' + message + '\033[0m')
