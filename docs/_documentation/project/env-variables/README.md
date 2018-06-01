---
title: Environment variables
permalink: /documentation/project/env-variables/
description: Define variables for CIKit environments.
---

Create the `/path/to/project/.cikit/vars/env.yml` that looks similar to the structure below and define the variables you want.

{% raw %}
```yaml
cikit_env:
  # The list of per-file variables to unconditionally add everywhere.
  global:
    /etc/environment:
      CIKIT_PROJECT: "{{ project }}"
  # The list of per-file variables to add to development environment only (VM).
  local:
    /etc/profile:
      CIKIT_PROJECT_URI: "{{ site_url }}"
  # The list of per-file variables for CI environment (remote CI server).
  ci:
    /etc/environment:
      CIKIT_CI: true
```
{% endraw %}

The contents above provided by CIKit out of the box but if you create own `env.yml` it'll no longer be used since your file overrides the default one. If you want to keep those values we recommend to copy the data and modify them as needed.
{: .notice--info}

## Structure

The `cikit_env` is a multilevel dictionary with three available root keys: `global`, `local` and `ci`. They are self-descriptive, but couple additional words won't be superfluous.

Every key under one of the groups is a path to an existing file to add the variables to (in case of specifying a path to the non-existent file you'll get an error).

### Global variables

By `global` we mean the variables that should be added independently to an environment, whether it's your local VM for development or CI droplet.

### Local variables

The `local` means that variables availability guaranteed inside of VM only.

### CI variables

The `ci` is opposite to `local` and expose variables on CI droplets only.
