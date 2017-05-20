# Shippable environment configuration

After execution `vagrant up` or `vagrant provision` in the root directory of project will be created/updated the `.env-config.yml` file, which will contain all configuration you made. Launching the `./cikit provision --limit=<HOST>` will not ask you anything, because configuration will be taken from that file. But if you want to override, just pass the options as command line arguments.

```shell
./cikit provision --limit=<HOST> \
  --php-version=7.0 \
  --nodejs-version=7 \
  --ruby-version=2.4.0 \
  --solr-version=6.5.1 \
  --http-auth-user=admin \
  --http-auth-pass=password
```

Running the `vagrant provision` will ask you the same questions again, but default values will be preselected from what you've chosen before. That's how you can *modify* that file in a right manner. Also, you can create/modify it first and the run `vagrant provision` and just bypass all questions.

Do not hesitate to commit this file to your VCS repository to make the team aware about environment they should have. But take care this file to not contain HTTP authentication password if repository is public.
