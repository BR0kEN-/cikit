---
title: Postgres SQL Server
permalink: /documentation/project/psql/
description: A configuration of the Postgres SQL.
---

The MSSQL could be installed to the machine during its provisioning - the user will be asked a question whether he/she wants to have it.

## Usage

- `vagrant ssh` - login to VM;
- `sudo su - postgres` - change system user to database manager;
- `psql` - login to Postgres SQL shell;
- `\l` - see the list of databases;
- `\du` - see the list of users;

### Default credentials

- Port: `5432`
- Host: `127.0.0.1`

### Examples

Configure a database for Drupal.

```postgresql
CREATE DATABASE drupal;
ALTER DATABASE drupal SET bytea_output = 'escape';
ALTER USER root WITH PASSWORD 'root';
GRANT ALL ON DATABASE drupal TO root;
```
