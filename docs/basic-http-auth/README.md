# Basic HTTP authentication

Remote **CIKit** host - is Nginx based web server. All web connections are serving via it with a basic HTTP authentication. You will [set the credentials for it during server provisioning](../../scripts/provision.yml#L39-L55).

Besides you can set the list of IP addresses which will be whitelisted and authentication for which will be omitted. [Add IPs here](../../scripts/vars/ip.yml) before setup the server.
