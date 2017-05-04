# Droplets management using Ansible

Control a situation on a physical server using `Ansible`.

## List of droplets

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME> --tags=vm --droplet-list
```

Result of execution of this command will be similar to this:

```shell
ok: [m2.propeople.com.ua] => {
    "msg": [
        "\"cikit01\" {f06aec56-3b0b-4a4c-9109-acf17601dc9b}"
    ]
}
```

On the left is the name of VM, on the right - UUID.

## Create new droplet

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME> --tags=vm --droplet-add
```

## Delete droplet

To know the name of droplet desired to delete, look at list of available droplets.

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME> --tags=vm --droplet-delete=<NAME|UUID>
```

## Restart droplet

```shell
./cikit matrix/matrix.yml --limit=matrix --tags=vm --droplet-edit=<NAME|UUID>
```

## Edit droplet

All sizes (memory and hard drive) must be in *megabytes*.

```shell
./cikit matrix/matrix.yml --limit=matrix --tags=vm --droplet-edit=<NAME|UUID> [--droplet-cpus=<NN>] [--droplet-memory=<NN>] [--droplet-size=<NN>]
```

**Read lines below before changing the configuration of virtual machine!**

> For now you able only increase a size of droplet hard drive. For example, if you have 20GB of HDD and you've increase it up to 30GB, then setting it back to lower than 30GB will be impossible.
> 
> Also, the size of HDD should not be changed because VM configured with resizable type of HDD.
