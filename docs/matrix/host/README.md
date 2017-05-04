# Host for virtual servers

Assume that we're ready to create own matrix of virtual servers. What's needed to have for that?

- Machine with **Ubuntu 16.04 LTS (64 bit)**
- `openssh-server` configured for key-based access
- Root or no-password `sudo` user

## Questions

Some points you might be interested in.

### Whether host for matrix can be a virtual machine?

Yes. But it's **definitely not recommended**, because you will create virtual machines inside of virtual machine. Also, nested virtualization must be supported on hardware level. And be ready for slower usability doing this weird way.