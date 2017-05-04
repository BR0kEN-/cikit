# Documentation

- [Basic HTTP authentication](basic-http-auth) - the frontier of your server protection.
- [Jenkins](jenkins) - build project instance with incoming changes.
  - [GitHub Bot configuration](jenkins/github-bot) - pull requests manager.
  - [Reinstall Debian package](jenkins/reinstall-deb) - upgrade/downgrade Jenkins version.
- Ansible
  - [Inventory](ansible/inventory) - list of managed hosts.
- Vagrant
  - [Box](vagrant/box) - information and access details.
- Project
  - [Sniffers](project/sniffers) - code quality tests.
  - [Solr](project/solr) - all about the way it's configured.
- [Matrix](matrix) - storage and controller of virtual servers.
  - [Host](matrix/host) - prepare machine for hosting virtual machines.
  - Droplet - virtual server on the host.
    - [Ansible](matrix/droplet/ANSIBLE.md) - control droplets by Ansible from command line.
    - [GUI](matrix/droplet/UI.md) - no, thank you, I'm mouseclicker.
