import os

dirs = {
    'lib': os.path.realpath(__file__ + '/..'),
    'self': os.path.realpath(__file__ + '/../..'),
    'project': os.environ.get('CIKIT_PROJECT_DIR'),
}

if None is dirs['project']:
    dirs['project'] = os.getcwd()
    dirs['scripts'] = dirs['self']

    INSIDE_VM_OR_CI = False
else:
    # The environment variable must point to a project root.
    dirs['scripts'] = dirs['project']

    INSIDE_VM_OR_CI = True

dirs['cikit'] = dirs['project'] + '/.cikit'
dirs['scripts'] += '/scripts'
