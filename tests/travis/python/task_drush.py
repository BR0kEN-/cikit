import unittest
from task_bash import TaskBashTestCase


class TaskDrushTestCase(TaskBashTestCase):
    file = 'cmf/drupal/all/scripts/tasks/drush.yml'
    tests = [
        # Covers:
        # - cim: ~
        {
            'result': {
                'name': 'Running a Drush command',
                'shell': 'drush cim  -y',
            },
            'args': {
                'cim': '',
            },
        },
        # Covers:
        # - name: "Installing Drupal"
        #   si: ["standard", "--db-url=mysql://root:root@localhost/database"]
        {
            'result': {
                'name': 'Installing Drupal',
                'shell': 'drush si standard --db-url=mysql://root:root@localhost/database -y',
            },
            'args': {
                'name': 'Installing Drupal',
                'si': [
                    'standard',
                    '--db-url=mysql://root:root@localhost/database'
                ],
            },
        },
        # Covers:
        # - name: "Getting a one-time login link"
        #   uli: 12
        {
            'result': {
                'name': 'Getting a one-time login link',
                'shell': 'drush uli 12 -y',
            },
            'args': {
                'name': 'Getting a one-time login link',
                'uli': '12',
            },
        },
    ]


if __name__ == '__main__':
    unittest.main()
