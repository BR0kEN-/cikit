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
- Create the `all` directory inside of previously created (`cmf/symfony`). There will live common configurations for a CMF. Add the `APPLICATION_CONFIG.yml` inside that might contain (or be empty) everything you want to put into the main [config.yml](https://github.com/BR0kEN-/cikit/blob/master/cmf/all/.cikit/config.yml#L5).
- Create a directory with a number of CMF's major release as a name (let's use `3`) within the `cmf/symfony` and add the `REPLACEMENTS.yml` inside (the file must contain the `replacements` dictionary that might be empty).

### Commands extraction

If the above description is harder to visualize than taking a look at the code then check it out below. Executing the next snippet you'll be ready to initialize a Symfony-based project via `cikit init --project=test_project --cmf=symfony`.

```bash
cd /usr/local/share/cikit
mkdir -p cmf/symfony/all cmf/symfony/3
cat << EOF > cmf/symfony/main.yml
---
download_url: "https://get.symfony.com/Symfony_Standard_Vendors_VERSION.tgz"
default_version: "3.4.0"
EOF
cat << EOF > cmf/symfony/all/APPLICATION_CONFIG.yml
---
EOF
cat << EOF > cmf/symfony/3/REPLACEMENTS.yml
---
replacements: {}
EOF
```
