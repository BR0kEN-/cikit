import os
import json
import functions

ANSIBLE_COMMAND = 'ansible-playbook'
ANSIBLE_EXECUTABLE = functions.call('which', ANSIBLE_COMMAND)

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

if '' == ANSIBLE_EXECUTABLE:
    functions.error(
        (
            'An executable for the "%s" command cannot be found. '
            'Looks like Python setup cannot provide Ansible operability.'
        )
        %
        (
            ANSIBLE_COMMAND
        )
    )

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
with open(ANSIBLE_EXECUTABLE) as ANSIBLE_EXECUTABLE:
    python_ansible = ANSIBLE_EXECUTABLE.readline().lstrip('#!').strip()

    # Do not apply the workaround if an exactly same interpreter is used for
    # running CIKit and Ansible.
    if functions.call('which', 'python').strip() == python_ansible:
        import ansible.release
        import yaml

        ANSIBLE_VERSION = ansible.release.__version__

        def read_yaml(path):
            if os.path.isfile(path):
                result = yaml.load(open(path))

                if None is not result:
                    return json.loads(json.dumps(result))

            return {}
    else:
        ANSIBLE_VERSION = functions\
            .call(python_ansible, '-c', 'from ansible.release import __version__\nprint __version__')\
            .strip()

        def read_yaml(path):
            if os.path.isfile(path):
                result = functions.call(
                    python_ansible,
                    '-c',
                    'import yaml, json\nprint json.dumps(yaml.load(open(\'%s\')))' % path,
                )

                if 'null' != result:
                    return json.loads(result)

            return {}

functions.is_version_between(ANSIBLE_VERSION, {
    'min': '2.4.3',
    # @todo Set to highest when the regressions introduced in 2.5.1 will be resolved.
    # - https://github.com/ansible/ansible/issues/39007
    # - https://github.com/ansible/ansible/issues/39014
    'max': '2.5.0',
})

CONFIG_FILE = dirs['cikit'] + '/config.yml'
