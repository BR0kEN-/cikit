# Continuous Integration Kit [![Build Status](https://img.shields.io/travis/BR0kEN-/cikit/master.svg?style=flat-square)](https://travis-ci.org/BR0kEN-/cikit)

**CIKit** - Ansible-based system that ships as an extensible package and allow building continuous integration and/or local environments for software development.

- Need a VM for local development (JS, NodeJS, Java, PHP, Composer, Solr, Memcache, Selenium, Python, MySQL, MSSQL, Ruby etc.)? Not a problem - `cikit init --project=test && cd test && vagrant up`.
- Wanna replicate a local (VM) environment on continuous integration server? [Not a problem](https://cikit.tools/documentation/matrix).
- Need a park for CI servers? [Not a big deal](https://cikit.tools/documentation/matrix).

*Currently based on [Ubuntu 16.04 LTS (64 bit)](https://cikit.tools/documentation/project/vagrant-box)*.

## End of life

I'm glad to say **CIKit has reached its end of usefulness**. Now I have one project less for active development and that's great since we all got a single life (please contact me if you know how to get more) that shouldn't be spent all in work.

Nowadays, **Docker and Kubernetees** are fairly easier than any existing software for building development environments and that's what I suggest you to chose for new projects. Check out the simple presentation of why you should try to avoid using CIKit, DrupalVM, Lando, DDEV, Docksal, etc. - https://docs.google.com/presentation/d/e/2PACX-1vTxP0DG2gNXChfz7DOncwiWOHG0C4eEDL1LqxaMYpjNLRcrIAKuUjBKvU1pKCBig6mxFxYrq_LneGi0/pub?start=false&loop=false&delayms=15000

Nevertheless, I'm still here for doing any necessary bugfixes, consulting and even accepting new features from third-parties.

Have fun!

## Features

- [Install CIKit package](https://cikit.tools/documentation#installation) just once. This guarantees your minimal involvement in keeping the codebase up to date. [Run `cikit self-update`](https://cikit.tools/documentation#update) and enjoy latest fixes/features that are picked up by every project.
- Build the project by the scenario you want via [Pull Requests on Github (Jenkins CI)](https://cikit.tools/documentation/jenkins/github-bot) or [Gitlab CI](https://cikit.tools/documentation/gitlab-ci/).
- [Create and maintain a hosting of continuous integration servers](https://cikit.tools/documentation/matrix) (Docker) via command line tool.
- Deploy a local environment for development on [Windows 10](https://cikit.tools/documentation/install-on-wsl), Linux or macOS with automatic IP allocation for local VPN and smart provisioner that [remembers the configuration of an environment](https://cikit.tools/documentation/project/env-config) you've built and allows sharing it with others.
- Deploy CI server to whatever cloud hosting you prefer.
- [Base any framework or CMS on CIKit](https://cikit.tools/documentation#create-a-project) and build your own CI workflow if necessary.
- Choose the software and versions that are needed for you. [Nginx or Apache](https://cikit.tools/documentation/project/web-server/), various PHP/Solr/Ruby/Node.js versions, MySQL as a standard server and [Microsoft SQL](https://cikit.tools/documentation/project/mssql) by desire, Phantom.js, Selenium and a lot of tools for providing code quality - all these stuff just out of the box.
- [Extend the software base of a project](https://cikit.tools/documentation/workflow/pantheon#install-terminus) by writing own Ansible roles for controlling the process.

### Components

- Hosts manager
  - [Define a connection to a server](https://cikit.tools/documentation/hosts-manager) via command line.
- Hosts matrices
  - [Produce a host for CI servers](https://cikit.tools/documentation/matrix#usage) by a single command.
  - [Manage CI servers (droplets)](https://cikit.tools/documentation/matrix#management) via single command.
- CI server
  - Docker. More system resources for your needs (comparative to the hypervisor).
  - [Jenkins](https://cikit.tools/documentation/jenkins/) with configured [GitHub workflow](https://cikit.tools/documentation/jenkins/github-bot/) or [Gitlab CI](https://cikit.tools/documentation/gitlab-ci/).
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
