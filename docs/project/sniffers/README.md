# Sniffers

During project lifecycle developers produce tons of code which cannot be comprehended and analyzed by human. To help this done were introduced the code sniffers. They are analyzing the codebase in every [Jenkins](../../jenkins) build and could be manually executed inside of development environment - your local Vagrant machine - by running the `cikit sniffers` command.

## Out of the box

- [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)
- [HTML_CodeSniffer](https://github.com/squizlabs/HTML_CodeSniffer)
- [SCSS Lint](https://github.com/brigade/scss-lint)
- [ES Lint](https://github.com/eslint/eslint)
- [Code Spell](https://github.com/lucasdemarchi/codespell)

## Configuration

Brief pointers on files affecting sniffers configuration. Look for them in a built project and change if needed.

- Global config - `scripts/vars/tests.yml`
- SCSS rules - `scripts/configs/scss-lint.yml`
- JS rules - `scripts/configs/.eslintrc`

Below you'll find expanded description of basic configuration, available after constructing the project.

### PHP

For analyzing PHP the `phpcs` command line utility is used. Execute the next command to list all available coding standards: 

```shell
find $(phpcs --config-show | grep 'installed_paths' | awk '{print $2}' | tr ',' ' ') -name "ruleset.xml" -exec dirname {} \; | sort | uniq
```

The result will looks like:

```text
/usr/share/coding-standards/Drupal/coder_sniffer/Drupal
/usr/share/coding-standards/DrupalSecure/DrupalSecure
/usr/share/coding-standards/Security/Security
/usr/share/coding-standards/Symfony2
/usr/share/coding-standards/WordPress/WordPress
/usr/share/coding-standards/WordPress/WordPress-Core
/usr/share/coding-standards/WordPress/WordPress-Docs
/usr/share/coding-standards/WordPress/WordPress-Extra
/usr/share/coding-standards/WordPress/WordPress-VIP
```

Example command for verifying validity using one of standards:

```shell
phpcs --standard=WordPress-Core /var/www/docroot
```

Configuration:

- Drupal
  - [standards](../../../cmf/drupal/all/scripts/vars/tests.yml#L3)
  - [file extensions](../../../cmf/drupal/all/scripts/vars/tests.yml#L4)
  - [directories](../../../cmf/drupal/all/scripts/vars/tests.yml#L17)
- WordPress
  - [standards](../../../cmf/wordpress/all/scripts/vars/tests.yml#L3)
  - [file extensions](../../../cmf/wordpress/all/scripts/vars/tests.yml#L4)
  - [directories](../../../cmf/wordpress/all/scripts/vars/tests.yml#L17)

According to above list it means, that listed standards will be applied for files, having listed extensions, in specified directories.

### HTML

For analyzing HTML the `htmlcs` command line utility is used. Execute the next command to list all available coding standards:

```shell
ls /usr/share/coding-standards/HTML/Standards/
```

The result will looks like:

```text
Section508  WCAG2A  WCAG2AA  WCAG2AAA
```

Example command for verifying validity using one of standards:

```shell
htmlcs https://google.com WCAG2AAA
```

Configuration:

- [Drupal](../../../cmf/drupal/all/scripts/vars/tests.yml#L11)
- [WordPress](../../../cmf/wordpress/all/scripts/vars/tests.yml#L11)

As many as needed pages could be listed in that file. Also, each page can be checked for compliance of the specific standard.

### SCSS

For analyzing SCSS the `scss-lint` command line utility is used. [Validation rules](../../../cmf/all/scripts/configs/scss-lint.yml) are fully configurable and the same for all CMFs.

Example command for manual execution:

```shell
scss-lint -c /var/www/scripts/configs/scss-lint.yml profiles/pp/*/custom
```

### JS

For analyzing JS the `eslint` command line utility is used. Validation rules are fully configurable but differs for each CMF.

- [Drupal](../../../cmf/drupal/all/scripts/configs/.eslintrc)
- [WordPress](../../../cmf/wordpress/all/scripts/configs/.eslintrc)

Moreover, there is a possibility to exclude some files from verification using the [.eslintignore](../../../cmf/all/scripts/configs/.eslintignore).

Example command for manual execution:

```shell
eslint -c /var/www/scripts/configs/.eslintrc --ignore-path /var/www/scripts/configs/.eslintignore  profiles/pp/*/custom
```

### Code Spell

For fixing common misspellings in text files the `codespell.py` command line utility is used. Use [.codespellignore](../../../cmf/all/scripts/configs/.codespellignore) to exclude files from processing.

Example command for manual execution:

```shell
codespell.py -S .DS_Store,*.png,*.gif,*.jpg,*.jpeg profiles/pp/*/custom
```

## Hooking into the process

To crown it all you have a possibility to add your own tasks into sniffing process. Enumerate them in the `scripts/tasks/sniffers/main.yml` (create if needed) and they are will be executed.
