# Parameterized builds

I believe everyone can invent or already faced the need to occasionally perform some actions. For instance, run `composer update` when the `vendor` directory is not under VCS. It's easy to get this done locally, but how to achieve this on CI server?

## Usage

Meet the [actions](../../../cmf/all/scripts/actions.yml) a.k.a parameterized builds. Needed documentation is written directly inside of the playbook, so let's take a look on a case with Composer there.

- Create `scripts/tasks/composer-update.yml`:

  ```yaml
  ---
  - name: Update Composer packages
    shell: composer update
    args:
      chdir: "{{ project_workspace }}"
  ```

- Modify `scripts/actions.yml`:

  ```yaml
  ---
  - include: tasks/environment/initialize.yml

  - name: Obtain home directory of a user, who triggered this script
    shell: "echo ~{{ ansible_env.SUDO_USER }}"
    register: user_home
    when: "'SUDO_USER' in ansible_env"

  - name: Set the user's home directory
    set_fact:
      become_home: "{{ ansible_env.HOME if 'skipped' in user_home else user_home.stdout }}"
      become_name: "{{ ansible_env.USER if 'skipped' in user_home else ansible_env.SUDO_USER }}"

  - include_vars: vars/environments/default.yml

  # Don't worry about condition. This playbook will not be executed if no actions in commit.
  - include: tasks/composer-update.yml
    when: "'composer update' in actions"
  ```

That's it. To run the action (parameterize the build), just create a commit with `[composer update]` in it's message, like:

```shell
git add composer.lock composer.json
git commit -m '[composer update] Update Composer dependencies'
git push origin feature/XXX
```

You can handle as much as needed actions per commit, just write the handlers and don't forget to specify their names in commit message.
