---
title: August 8, 2017
permalink: /changelog/2017-08-08/
---

Starting from now all droplets (virtual servers for projects on matrices) will be a `systemd` Docker containers (based on `libcontainer`).

## Benefits

- Host became lighter (due to removed `php`, `php-fpm`, `php-gd`, `php-xml` and `php-soap`, `virtualbox` and its extensions pack and `phpvirtualbox` UI for VMs).
- Fully-provisioned CI server has `~2.8 GB` instead of `~10GB` in case of VM.
- The problem with dynamically allocated storage for VMDK disk is gone (it was expanding automatically, but didn’t shrink back). Now we don’t have VMs at all.
- Improvement of system resources dedication. Now they’re not reserved by VMs.
- Provisioning of a new matrix occurs for 2-4 minutes instead of 10.
- You can safely (from the resources perspective) put matrix inside of VM and have containers there.

So, now hosts will have Nginx, Docker and their basic dependencies only. What does it mean? No more UI for your droplets, which was provided by `phpvirtualbox`. Droplets management possible using Ansible or, if you’re a DevOps/sysadmin guru, by direct SSH access to the host.

## Reference

[Droplets management](../../_documentation/matrix#management)
