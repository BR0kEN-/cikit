# SSH Keys

To provide SQL workflow or similar actions, when connection to remote host required, we need to have SSH keys. They are will be used in every environment where needed.

## Usage

This folder could contain as much as needed keys. Every key should have an extension `*.key` by which they will be identified. Also, to have a possibility to distinguish private keys from public, an additional file extension required: `*.private.key` for private keys and `*.public.key` - for public.

## New key

```shell
ssh-keygen -t rsa -b 2048 -C "cikit@PROJECT" -N '' -q -f PROJECT.private.key && mv $_.pub ${_//private/public}
```

Do not forget to add a `PROJECT.public.key` to `~/.ssh/authorized_keys` file on necessary machines.
