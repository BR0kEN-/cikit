import os
import functions

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

if functions.is_project_root(dirs['project']):
    dirs['credentials'] = dirs['cikit']

    INSIDE_PROJECT_DIR = True
else:
    dirs['credentials'] = dirs['self']

    INSIDE_PROJECT_DIR = False

dirs['scripts'] += '/scripts'
dirs['credentials'] += '/credentials'
