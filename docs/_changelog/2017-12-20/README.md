---
title: December 20, 2017
permalink: /changelog/2017-12-20/
---

- Removed unused generation of the SSL keys during Apache installation for simplifying and accelerating the process.
- Improved installation of Jenkins plugins using Ansible 2.x modules: `jenkins_script` and `jenkins_plugin`. Reduced number of iterations in SSH loop.
- Redesigned the installation of Jenkins and its dependencies using the `apt` instead of the manual downloading and depackaging. Now the provisioning will always install the latest version of server and plugins.
- Enabled [Ansible pipelining](http://docs.ansible.com/ansible/latest/intro_configuration.html#pipelining) that increased (15% and more) the provisioning of VM/CI.

Go ahead with `cikit self-update`.

## Reference

[https://github.com/BR0kEN-/cikit/issues/85](https://github.com/BR0kEN-/cikit/issues/85)
