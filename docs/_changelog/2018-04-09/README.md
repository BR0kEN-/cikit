---
title: April 9, 2018
permalink: /changelog/2018-04-09/
---

- Added an ability to use [Gitlab CI](/documentation/gitlab-ci/) as a continuous integration platform (instead of Jenkins).
- Fixed an error that caused `vagrant ssh` to fail within the child directory of a project (not in that where `Vagrantfile` is stored).
- A list of [custom PHP extensions](/documentation/project/custom-php-packages/) is easier to define now. Use `php_packages` variable within a project and specify everything you need.
- The `xdebug.remote_host` is automatically set to VM's gateway for allowing the use of xDebug from CLI with zero configuration.

## References

- [https://github.com/BR0kEN-/cikit/issues/114](https://github.com/BR0kEN-/cikit/issues/114)

## Documentation

- [Gitlab CI](/documentation/gitlab-ci/)
- [Custom PHP packages](/documentation/project/custom-php-packages/)
