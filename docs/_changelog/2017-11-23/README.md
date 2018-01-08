---
title: November 23, 2017
permalink: /changelog/2017-11-23/
---

**CIKit** just got better by getting a new update that affects the speed of Solr downloading. Before, the location of a package was settled to a centralized Apache.org server which is far to people in Australia, for instance.

Since now the Apache.org script for automatic mirror determination will be used to find out the closest server to retrieve the package.

The tests have shown cool performance boost: the package has been downloaded for ~20 seconds instead of couple minutes.

Don't forget `cikit self-update` to get the feature in.

## Reference

[https://github.com/BR0kEN-/cikit/issues/67](https://github.com/BR0kEN-/cikit/issues/67)
