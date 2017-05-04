# Basic HTTP authentication

Remote **CIKit** host is Nginx based web server which protects web-traffic using basic HTTP authentication. You will [set the credentials for it during server provisioning](../../scripts/provision.yml#L41-57).

Besides, you can set the list of IP addresses which will be whitelisted for authentication omitting. [Add IPs here](../../scripts/vars/ip.yml) before the server setup.

Authentication applies to Jenkins, Solr, builds - to each resource accessible from the web.

## Proxy structure

The next scheme demonstrates the structure of **CIKit** based server.

![Proxy structure](images/proxy-structure.png)

HTTPS traffic proxying on 443 port works the same.

Everything is simple in case of **Solr** and **Jenkins**. Here is an answer for question "**what is Apache for?**".

Historically Apache is older than Nginx and all supported by **CIKit** CMFs are working with it out of the box without additional configuration. Also each project could have its own `.htaccess` to influence server configuration.
