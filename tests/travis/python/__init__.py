import sys

sys.path.append('/usr/local/share/cikit/lib')

import variables as cikit

if cikit.python_system != cikit.python_ansible:
    sys.path.append(cikit.python_ansible.replace('/bin/', '/lib/') + '/site-packages')
