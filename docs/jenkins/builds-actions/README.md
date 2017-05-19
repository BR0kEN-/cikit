# Parameterized builds

We believe everyone can invent or already faced the need to occasionally perform some actions. For instance, run `composer update` when the `vendor` directory is not under VCS. It's easy to get this done locally, but how to achieve this on CI server?

Meet the [actions](../../../cmf/all/scripts/tasks/reinstall/actions.yml) - list of Ansible tasks which will be executed on a build if commit message contains constructions with text between square brackets (like `[test action1][test action2] Regular message`).

## Usage

Needed documentation is written directly inside of the playbook, so let's take a look on a case with Composer.

- Create `scripts/tasks/composer-update.yml`:

  ```yaml
  ---
  - name: Update Composer packages
    shell: composer update
    args:
      chdir: "{{ project_workspace }}"
  ```

- Modify `scripts/tasks/reinstall/actions.yml`:

  ```yaml
  ---
  - include: ../tasks/composer-update.yml
    when: "'composer update' in actions"
  ```

That's it. To run the action (parameterize the build), just create a commit with `[composer update]` in it's message, like:

```shell
git add composer.lock composer.json
git commit -m '[composer update] Update Composer dependencies'
git push origin feature/XXX
```

You can handle as much as needed actions per commit, just write the handlers and don't forget to specify their names in commit message.
