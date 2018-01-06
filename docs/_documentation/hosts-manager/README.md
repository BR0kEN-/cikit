---
title: Hosts manager
permalink: /documentation/hosts-manager/
description: Defining/deleting/listing credentials of servers to work with.
---

The manager of hosts provides you abilities to add, delete and list the hosts you can provision. Let's say you want to create a matrix of CI servers. Where do you want it? At `example.com`? Okay.

```bash
cikit host/add --alias=example_matrix --domain=example.com [--ssh-key=~/.ssh/id_rsa] [--ssh-user=root] [--ssh-port=22]
```

In short, it's just credentials for connecting to a server via SSH (options in square brackets are optional and the example above lists their default values).

Good, if the credentials are valid (they are verified at the moment of addition), then a new host will be added and aliased by the associated name (`example_matrix` from the example above, which also checks for uniqueness). Now you can run some operations over it.

## Theses

- You can't add an invalid data for SSH connection but they can become outdated.
- You can't define two hosts with the same name.

## List the hosts

Going forward, we want to make sure that host has been defined. Let's do so.

```bash
cikit host/list
```

The output will be close to something like this.

```
TASK [Print hosts] *****************************************************************************************************************************************************************************************
ok: [localhost] => {
    "cikit_hosts": {
        "matrix1": {
            "hosts": [
                "example.com"
            ],
            "vars": {
                "ansible_port": 22,
                "ansible_ssh_private_key_file": "~/.ssh/id_rsa",
                "ansible_user": "root"
            }
        }
    }
}
```

## Remove a host

The removal process is also quite similar and easy.

```bash
cikit host/delete --alias=example_matrix
```
