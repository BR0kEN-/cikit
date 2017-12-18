# Login to droplet via SSH

There are two ways to log in at one of the droplets.

### SSH

Find the credentials for the connection in the following paths: 
- `PROJECT_DIR/.cikit/credentials/MATRIX_NAME/DROPLET_NAME/DROPLET_NAME.private.key`
- `/usr/local/share/cikit/credentials/MATRIX_NAME/DROPLET_NAME/DROPLET_NAME.private.key`

```bash
ssh root@DROPLET_NAME.MATRIX_HOST -p22DROPLET_NUMBER -i DROPLET_KEY
```

Review the case when the `matrix1` - it's a name of the matrix with the `example.com` hostname and `cikit04` a name of the droplet:

- `MATRIX_HOST` equal to `example.com`
- `MATRIX_NAME` equal to `matrix1`
- `DROPLET_NAME` equal to `cikit04`
- `DROPLET_NUMBER` equal to `04`
- `DROPLET_KEY` equal to one of the paths where the key is stored. This depends on how a droplet was created. If it was within the project - credentials are in `<PROJECT_DIR>`. Otherwise in a global storage.

```bash
ssh root@cikit04.example.com -p2204 -i /usr/local/share/cikit/credentials/matrix1/cikit04/cikit04.private.key
```

### Docker

Login to your matrix via SSH and to the droplet from there via `docker run -it DROPLET_NAME bash`.

To get the list of matrices you can refer to the [host manager](../../hosts-manager) documentation.
