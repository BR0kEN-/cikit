---
title: May 20, 2017
permalink: /changelog/2017-05-20/
---

Commit-controllable builds are onboard now! Specify whatever you want actions in commit message and write handlers for them.

Example:

```bash
git add composer.json composer.lock
git commit -m '[composer update][my next action] Update Composer packages'
```

Local execution:

```bash
cikit reinstall --actions='["composer update", "my next action"]'
```

## Reference

[Parameterized builds](../../_documentation/jenkins/parameterized-builds)

## Thanks

[https://github.com/gajdamaka](https://github.com/gajdamaka), for inspiring the idea.
