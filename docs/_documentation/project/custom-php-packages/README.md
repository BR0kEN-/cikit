---
title: Custom PHP packages
excerpt: Installing custom PHP extensions.
permalink: /documentation/project/custom-php-packages/
---

At your project's `.cikit/vars` create the `php.yml` and put the `php_packages` variable inside.

## Example

Listed extensions will be installed all together with [default packages](https://github.com/BR0kEN-/cikit/blob/master/scripts/roles/cikit-php/vars/main.yml).

```yaml
php_packages:
  - bcmath
```

Bear in mind that every package in a list gets the `php7.1-` prefix (`7.1` here just for an example, actually there will be a version you've chosen).
{: .notice--warning}

## What if I need something more complex?

If you need to create a config for an extension or modify a system somehow then it's a scope of a custom Ansible role that has to be added to the project dependencies.

Example: [Add Platform.sh CLI](../../workflow/platformsh/#add-platformsh-cli)
