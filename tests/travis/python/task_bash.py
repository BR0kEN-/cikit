import unittest
import __init__ as lib
import jinja2
from ansible.parsing.dataloader import DataLoader


class TaskBashTestCase(unittest.TestCase):
    file = 'cmf/all/scripts/tasks/bash.yml'
    tests = [
        # Covers:
        # - run: "/path/to/script.sh"
        {
            'result': {
                'name': 'Running a Bash command',
                'shell': '/path/to/script.sh',
            },
            'args': {
                'run': '/path/to/script.sh',
            },
        },
        # Covers:
        # - name: "Doing something"
        #   run: "echo 12"
        {
            'result': {
                'name': 'Doing something',
                'shell': 'echo 12',
            },
            'args': {
                'name': 'Doing something',
                'run': 'echo 12',
            },
        },
    ]

    def test(self):
        loader = DataLoader()
        tasks = loader.load_from_file(lib.cikit.dirs['self'] + '/' + self.file)

        self.assertEqual(len(tasks), 1)
        self.assertTrue('shell' in tasks[0])
        self.assertTrue('name' in tasks[0])
        self.assertTrue('when' in tasks[0])
        self.assertTrue('args' in tasks[0])

        for test in self.tests:
            for item in ['name', 'shell']:
                self.assertEqual(
                    jinja2.Template(tasks[0][item]).render({'item': test['args']}),
                    test['result'][item]
                )


if __name__ == '__main__':
    unittest.main()
