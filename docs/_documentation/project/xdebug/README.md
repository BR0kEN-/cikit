---
title: Configure Xdebug
excerpt: Setup a connection between PhpStorm and Xdebug to debug a project.
permalink: /documentation/project/xdebug/
---

After provisioning the environment will have the `XDEBUG_CONFIG="idekey=PHPSTORM"` and `PHP_IDE_CONFIG="serverName=PROJECT_HOSTNAME"` variables set in `/etc/environment`.

The `PHPSTORM` can be changed in the [configuration](https://github.com/BR0kEN-/cikit/blob/master/scripts/roles/cikit-php/defaults/main.yml#L33).
{: .notice--info}

The `PROJECT_HOSTNAME` will be equal to the result returned by `hostname -f`.
{: .notice--info}

Therefore, you're in a couple of steps of completing the setup.

## Configure PhpStorm

The "dump" of environment for PHP 7.1 will look similar to the screenshot.

![CIKit Xdebug](images/cikit-xdebug.png)

Consider `pfqaplatform` as the name of a project and `pfqaplatform.loc` as its hostname.
{: .notice--warning}

### Configure server

The name of a server must be equal to the `serverName=` that is stored in `PHP_IDE_CONFIG` environment variable.

![CIKit Xdebug](images/cikit-phpstorm-webserver.png)

### Configure for WEB

The name of a configuration could be arbitrary.

![CIKit Xdebug](images/cikit-phpstorm-webpage.png)

### Configure for CLI

The value of `IDE key(session id)` must be equal to the `idekey=` that is stored in `XDEBUG_CONFIG` environment variable.

![CIKit Xdebug](images/cikit-phpstorm-cli.png)

All done, use the configuration.

![CIKit Xdebug](images/cikit-phpstorm-debug.png)
