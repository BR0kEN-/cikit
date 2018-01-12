# Continuous Integration Kit

**CIKit** - Ansible-based system for building environments for local development and continuous integration.

- Need a VM for local development (JS, NodeJS, Java, PHP, Composer, Solr, Memcache, Selenium, Python, MySQL, MSSQL, Ruby etc.)? Not a problem - `cikit init --project=test && cd test && vagrant up`.
- Wanna replicate a local (VM) environment on continuous integration server? [Not a problem](https://cikit.tools/documentation/matrix).
- Need a park for CI servers? [Not a big deal](https://cikit.tools/documentation/matrix).

*Currently based on [Ubuntu 16.04 LTS (64 bit)](https://cikit.tools/documentation/project/vagrant-box)*.

## Features

- Hosts manager
  - [Define a connection to a server](https://cikit.tools/documentation/hosts-manager) via command line.
- Hosts matrices
  - [Produce a host for CI servers](https://cikit.tools/documentation/matrix#usage) by a single command.
  - [Manage CI servers (droplets)](https://cikit.tools/documentation/matrix#management) via single command.
- CI server
  - Docker. More system resources for your needs (comparative to the hypervisor).
  - Jenkins with configured GitHub workflow.
- Virtual machine
  - Automatic IP allocation. You're no longer care about changing the IP for every new VM.
  - User interaction. You'll be asked what to install during provisioning the machine.
  - [Shippable environment configuration](https://cikit.tools/documentation/project/env-config). Once created - everywhere updated.
  - Selenium 2.x grid: a hub in VM and node on your host.

## Information

|Section|Link|
|:---|:---|
|Documentation|https://cikit.tools/documentation|
|Dependencies|https://cikit.tools/documentation#dependencies|
|Installation|https://cikit.tools/documentation#installation|
|Changelog|https://cikit.tools/changelog|
|About|https://cikit.tools/about|
|Support|https://cikit.slack.com/messages/support|
