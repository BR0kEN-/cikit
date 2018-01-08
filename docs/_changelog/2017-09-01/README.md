---
title: September 1, 2017
permalink: /changelog/2017-09-01/
---

Since today the **CIKit** has been converted to a distribution, which needs to be installed on PC first before creating/managing projects based on it.

The new structure of the repository can be found at [https://github.com/Firstvector/cikit-test](https://github.com/Firstvector/cikit-test).

## What's available?

- Changing any possible variables as it was before ([https://github.com/Firstvector/cikit-test/tree/master/.cikit/vars](https://github.com/Firstvector/cikit-test/tree/master/.cikit/vars)).
- Adding custom Ansible roles to include them into provisioning ([https://github.com/Firstvector/cikit-test/blob/master/.cikit/roles/cikit-project/meta/main.yml](https://github.com/Firstvector/cikit-test/blob/master/.cikit/roles/cikit-project/meta/main.yml)).

As it was before, the provisioning is the same for a local VM and for remote CI server.

## What's became unavailable?

- Modification of CIKit-core scripts and tools.

## What was added?

- Selenium Grid for every local VM.

## Will it work on previously provisioned CI servers?

- It can, but jobs need to be modified and CIKIt needs to be installed on the CI server as a package. Note, that if you want to keep existing projects without an update of CIKit than will be better to create new jobs.

## What needs to be done with existing CI server to make it work?

- Install CIKit by `curl -LSs https://raw.githubusercontent.com/BR0kEN-/cikit/master/install.sh | sh`
- Add the `export CIKIT_PROJECT_DIR="${WORKSPACE}"` to every job.
- Remove `chmod a+x ./cikit` and replace all other `./cikit` by just `cikit`.

## How to just add a new job?

- Run `cikit jenkins-job --limit=CI_SERVER --project=PROJECT` locally and new job will be created for existing Jenkins.

## How to update CIKit?

- Run `cikit self-update` locally.

## Will the previous projects continue working?

- Sure, they are fully standalone and having the copy of CIKit inside of themselves.

In total, all new projects will automatically reflect the fixes and improvements of CIKit without needing to update them manually.

This is the biggest architectural redesign which became possible with a very little amount of modifications. And it’s cool!
