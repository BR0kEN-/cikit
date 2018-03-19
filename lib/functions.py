from os import path
from sys import exit
from glob import glob
from subprocess import Popen, PIPE


def playbooks_print(directory, prefix=''):
    for playbook in glob(directory + '/' + prefix + '*.yml'):
        print prefix + path.splitext(path.basename(playbook))[0],


def playbooks_find(*paths):
    for variation in paths:
        variation = path.splitext(variation)[0] + '.yml'

        if path.exists(variation):
            return variation


def is_project_root(directory):
    return \
        path.isdir(directory + '/scripts') and \
        path.isdir(directory + '/.cikit') and \
        path.exists(directory + '/.cikit/config.yml')


def call(*nargs, **kwargs):
    return Popen(nargs, stdout=PIPE, **kwargs).stdout.read().rstrip()


def parse_extra_vars(args, bag):
    for arg in args:
        if arg.startswith('--', 0):
            arg = arg[2:].split('=', 1)

            if 1 == len(arg):
                arg.append(True)

            bag[arg[0].replace('-', '_')] = arg[1]


def get_hostname(config):
    # The name of Docker container for local development is forming based on the
    # hostname that is taken from the "site_url".
    if 'site_url' in config:
        return config['site_url'].split('//')[-1]

    return ''


def error(message, code=1):
    print('\033[91mERROR: ' + message + '\033[0m')
    exit(code)


def warn(message):
    print('\033[93mWARNING: ' + message + '\033[0m')
