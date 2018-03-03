---
title: Integrate CMS or framework
permalink: /documentation/project/cmf-integration/
description: Integrate content management system or framework into the CIKit.
---

CIKit is good because doesn't limit the development using Drupal or Wordpress only. Those systems have built-in support, but you can add an integration with another framework or CMS completing several simple steps.

## Define new system

- Create a directory within the `cmf/` with a name that will be used as a value for the `--cmf` option to the `cikit init`. Let's use `symfony` as an example.
  - Put the `main.yml` inside of the created directory.
    ```yaml
    ---
    download_url: "https://get.symfony.com/Symfony_Standard_Vendors_VERSION.tgz"
    default_version: "3.4.0"
    ```
    - The above example is valid for the [Symfony](https://symfony.com/) integration.
    - The `VERSION` will be replaced by a value of the `--version` option to the `cikit init` or fallen back to the `default_version`.
    - The file must be a TAR archive and contain a directory inside since will be processed using `tar` command with the `--strip-components=1` option.
    {: .notice--info}
- Create the `all` directory inside of previously created (`cmf/symfony`). There will live common configurations for a CMF.
  - Add the `APPLICATION_CONFIG.yml` inside. It must contain the path to a settings (i.e. `settings: app/config/config.yml`) file and everything else you want to put into the main [config.yml](https://github.com/BR0kEN-/cikit/blob/master/cmf/all/.cikit/config.yml#L5).
  - Add the `index.php` inside with just an include of the application, `<?php require_once 'web/app.php';`.
  - Add the `tasks/reinstall/modes/full.yml` inside and describe the logic for reinstalling your application.
  - Add the `tasks/sniffers/main.yml` inside and describe the logic for additional code sniffs.
  - Add the `vars/environments/default.yml` inside and put there all the variables for local/development environment of your application. You may also create as much as needed files for different environments (i.e. `demo.yml`) and build those using `cikit reinstall --env=demo` or something like that.
  - Add the `vars/tests.yml` inside.
    ```yaml
    ---
    phpcs:
      standards: ["Symfony2"]
      extensions: ["php"]

    # Available standards:
    # - WCAG2A
    # - WCAG2AA
    # - WCAG2AAA
    # - Section508
    htmlcs:
      Frontpage:
        path: /
        standard: Section508

    # If you ending a pattern by asterisk then put trailing slash at the end!
    scan_dirs:
      - "src"
      - "tests"
    ```
    You may consider modification of the above if needed. Also, don't hesitate to add own variables and use them in a logic for custom sniffers.
    {: .notice--info}
- Create a directory with a number of CMF's major release as a name (let's use `3`) within the `cmf/symfony`.
  - Add the `REPLACEMENTS.yml` inside. It must contain the `replacements` dictionary, having a shell command, assigned to the `THEME_PATH_COMMAND` key, which returns the path to a directory where `npm install` could be run.

### Commands extraction

If the above description is harder to visualize than taking a look at the code, then check it out below. Executing the next snippet you'll be ready to initialize a Symfony-based project via `cikit init --project=test_project --cmf=symfony`.

```bash
cd /usr/local/share/cikit

mkdir -p \
  cmf/symfony/all/tasks/reinstall/modes \
  cmf/symfony/all/tasks/sniffers \
  cmf/symfony/all/vars/environments \
  cmf/symfony/3

cat << EOF > cmf/symfony/main.yml
---
download_url: "https://get.symfony.com/Symfony_Standard_Vendors_VERSION.tgz"
default_version: "3.4.0"
EOF

cat << EOF > cmf/symfony/all/APPLICATION_CONFIG.yml
---
settings: app/config/config.yml
EOF

cat << EOF > cmf/symfony/all/index.php
<?php

require_once 'web/app.php';
EOF

cat << EOF > cmf/symfony/all/tasks/reinstall/modes/full.yml
---
# @todo Implement the logic for reinstalling your application.
EOF

cat << EOF > cmf/symfony/all/tasks/sniffers/main.yml
# A custom set of operations could be here. They will be executed in a scope of "sniffers.yml" playbook.
---
EOF

cat << EOF > cmf/symfony/all/vars/environments/default.yml
# A set of variables for the environment. You can use them everywhere within the reinstall.
---
EOF

cat << EOF > cmf/symfony/all/vars/tests.yml
---
phpcs:
  standards: ["Symfony2"]
  extensions: ["php"]

# Available standards:
# - WCAG2A
# - WCAG2AA
# - WCAG2AAA
# - Section508
htmlcs:
  Frontpage:
    path: /
    standard: Section508

# If you ending a pattern by asterisk then put trailing slash at the end!
scan_dirs:
  - "src"
  - "tests"
EOF

cat << EOF > cmf/symfony/3/REPLACEMENTS.yml
---
replacements:
  THEME_PATH_COMMAND: "echo 'templates/'"
EOF
```

## Wrap up

Despite on missing logic for many of things the creation and usage of a Symfony-based project can be achieved using the above example. Any other content management system or framework could be integrated in the same way.

To ensure the validity of the example, let's create a project, provision a VM for it and run the `reinstall`.

```bash
cikit init --project=test_project --cmf=symfony
cd test_project
vagrant up
vagrant ssh
cikit reinstall
```

The tricky point is that `reinstall` actually do nothing and an integrator needs to decide how it should behave by implementing this stuff. Good luck!
