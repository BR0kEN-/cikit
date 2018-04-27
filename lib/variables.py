import os
import sys
import functions

ANSIBLE_EXECUTABLE = functions.which(functions.ANSIBLE_COMMAND)

if '' == ANSIBLE_EXECUTABLE:
    functions.error(
        (
            'An executable for the "%s" command cannot be found. '
            'Looks like Python setup cannot provide Ansible operability.'
        )
        %
        (
            functions.ANSIBLE_COMMAND
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
    PYTHON_SYSTEM = functions.which('python')
    PYTHON_ANSIBLE = ANSIBLE_EXECUTABLE.readline().lstrip('#!').strip()

    if PYTHON_SYSTEM != PYTHON_ANSIBLE:
        # This covers the installation on macOS via Homebrew.
        # Installation via Pip uses system-wide Python so there shouldn't be a problem.
        sys.path.append(PYTHON_ANSIBLE.replace('/bin/', '/lib/') + '/site-packages')

        functions.warn(
            'A system-wide Python interpreter is "%s" and it differs from "%s", that is used for '
            'running Ansible.'
            %
            (
                PYTHON_SYSTEM,
                PYTHON_ANSIBLE,
            ),
            1
        )

    import ansible.release

functions.ensure_version({
    'min': '2.4.3',
    'current': ansible.release.__version__,
}, {
    '2.5.1': [
        'https://github.com/ansible/ansible/issues/39007',
        'https://github.com/ansible/ansible/issues/39014',
    ],
})

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

if functions.is_project_root(dirs['project']):
    dirs['credentials'] = dirs['cikit']

    INSIDE_PROJECT_DIR = True
else:
    dirs['credentials'] = dirs['self']

    INSIDE_PROJECT_DIR = False

dirs['credentials'] += '/credentials'
