---
title: December 9, 2017
permalink: /changelog/2017-12-09/
---

- **CIKit** has been rewritten on Python 2.7.
- Added the [hosts manager](../../_documentation/hosts-manager). No more manual edits of the `inventory`.
- Added [MySQL import strategies for SQL workflow](../../_documentation/project/mysql-import-strategies).
- Added the documentation for preparing a project for [hosting on Pantheon](../../_documentation/workflow/pantheon).
- Added `cikit-pantheon-terminus` role which can be optionally used for installing Terminus.
- Added new update system.
- Jenkins 2.76 has been updated to 2.93.

## Required manual actions

**Important:** after `cikit self-update` please do the following actions:

Re-link the utility and do an update once again to enable new update system.

```bash
sudo ln -sf /usr/local/share/cikit/lib/cikit /usr/local/bin/cikit
rm /usr/local/share/cikit/lib/.version
cikit self-update --force
```

- Copy an updated `/usr/local/share/cikit/cmf/all/scripts/tasks/get-hostname.yml` to your projects.

- Ensure `credentials` directory structure:

```
/path/to/project/.cikit/credentials
|-- MATRIX_1
|   |-- DROPLET_1
|   |--   |-- DROPLET_1.private.key
|   |--   |-- DROPLET_1.public.key
|   |--   |-- http_auth_pass
|   |-- DROPLET_2
|   |--   |-- DROPLET_2.private.key
|   |--   |-- DROPLET_2.public.key
|   |--   |-- http_auth_pass
|-- MATRIX_2
|   |-- DROPLET_1
|   |--   |-- DROPLET_1.private.key
|   |--   |-- DROPLET_1.public.key
|   |--   |-- http_auth_pass
```

- Define your matrices via [hosts manager](../../documentation/hosts-manager).

## Reference

[https://github.com/BR0kEN-/cikit/issues/62](https://github.com/BR0kEN-/cikit/issues/62)
