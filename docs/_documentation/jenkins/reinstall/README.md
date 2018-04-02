---
title: Reinstall Jenkins
permalink: /documentation/jenkins/reinstall/
---

It might happen that you'll need to reinstall a Jenkins and **CIKit** provides such possibility.

## Package reinstall

If you have accidentally broke the service, removed the package or some dependency (*not configuration*) then just reinstall the package executing the next command on your local machine:

```bash
CIKIT_TAGS="ci" cikit provision --limit=HOSTNAME --jenkins-reinstall-deb
```

- What is the [HOSTNAME](../../hosts-manager)?
