# Droplets management using UI

Control a situation on a physical server using `PHP Virtual Box`.

## List of droplets

Visit your host, login and see the list of all droplets.

## Create new droplet

![Clone original VM](../screenshots/droplet/create/vbox1.png)
![Set an unique name and network reinitialization](../screenshots/droplet/create/vbox2.png)
![Finish cloning](../screenshots/droplet/create/vbox3.png)
![Click on the Network](../screenshots/droplet/create/vbox4.png)
![Click on the Port forwarding](../screenshots/droplet/create/vbox5.png)
![Configure ports](../screenshots/droplet/create/vbox6.png)

When described above steps are done, then just power on a virtual machine, create a record at [inventory](/inventory#L7-L8) and provision new virtual server with main `cikit` tool.

`phpVirtualBox` will be available on the domain which you have to [configure](../../matrix.yml#L5). Imagine that it is: `m2.propeople.com.ua`. As you can see on the screenshots, every port ends by `01`. This means that domain for VM will be `cikit01.propeople.com.ua`.

Why `cikit<NN>`? [Look there](../../matrix.yml#L6) for the answer.

## Delete droplet

![Power off VM](../screenshots/droplet/delete/vbox1.png)
![Remove VM](../screenshots/droplet/delete/vbox2.png)
![Confirm removal](../screenshots/droplet/delete/vbox3.png)
