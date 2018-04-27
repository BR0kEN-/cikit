---
date: 2018-04-24 02:40:00+4
title: "Automate running tests in different languages on Travis CI"
excerpt: "Automatically find and run available tests for a project. Control what to skip via commit messages. Build the conditional system you want."
toc_label: "Sections"
toc: true
header:
  teaser: /assets/posts/2018-04-24-travis-tests-automation/travis-ci.png
tags:
  - bash
  - cikit
  - testing
  - travis
---

![{{ page.title }}]({{ page.header.teaser }}){: .align-center}

There may be a case when you would want to write tests for a project using different programming languages. For instance, using Bash to functionally test a command line utility, Python - for a unit testing of its separate parts.

The approach being described below helps to automate running tests, distributed over the multiple files. Also, it provides a powerful [PoC](https://en.wikipedia.org/wiki/Proof_of_concept) for making builds with conditions - e.g., skip this bunch of tests, run this, do that...

## .travis.yml

Let's consider a base configuration.

```yaml
sudo: required
dist: trusty

script:
  - sudo ./tests/travis/runner.sh
```

That's all we need to have for our process. Of course, the additional steps like installation routines or enabling the services may be added if a project needs them.

## runner.sh

The unified tests runner, written on GNU Bash, is here for you to focus on describing test cases and forget about modifying `.travis.yml`.

The script uses `-v` option of `awk` that is not available in BSD version.
{: .notice--info}

```bash
#!/usr/bin/env bash

# Restrictions:
#   - Will not work with BSD "awk" (i.e. on macOS) due to "awk: invalid -v option".
#
# Usage:
#   - Run all tests.
#     bash runner.sh
#
#   - Run non-bash tests.
#     TRAVIS_COMMIT_MESSAGE="[skip bash]" bash runner.sh
#
#   - List available tests.
#     bash runner.sh --list
#
#   - List non-bash tests.
#     TRAVIS_COMMIT_MESSAGE="[skip bash]" bash runner.sh --list

cd ./tests/travis
declare -A TESTS=()
declare -r OPTION="$1"

# Iterate all over subdirectories.
for INTERPRETER in [a-z]*/; do
  EXTENSION="$INTERPRETER/.extension"

  # Assume tests are in a directory that has the ".extension" file.
  if [ -f "$EXTENSION" ]; then
    TESTS["${INTERPRETER%%/}"]="$(head -n1 "$EXTENSION")"
  fi
done

# Parse the commit message that looks like "#120: [skip bash/init][ skip  python] Commit name".
# The resulting string will be: "|skipbash/init|skippython|"
if [ -v TRAVIS_COMMIT_MESSAGE ]; then
  PARAMS="|$(awk -vRS="]" -vFS="[" '{print $2}' <<< "$TRAVIS_COMMIT_MESSAGE" | head -n -1 | tr '\n' '|' | tr -d '[:space:]')"
fi

for INTERPRETER in "${!TESTS[@]}"; do
  if [[ ! "$PARAMS" =~ \|skip$INTERPRETER\| ]]; then
    for TEST in "$INTERPRETER"/[a-z]*."${TESTS[$INTERPRETER]}"; do
      if [[ ! "$PARAMS" =~ \|skip$TEST\| ]]; then
        if [ "--list" == "$OPTION" ]; then
          echo "- $TEST"
        else
          echo "[$(date --iso-8601=seconds)] -- $TEST"
          ${INTERPRETER} "$TEST"
        fi
      fi
    done
  fi
done
```

The script assumes you have `tests/travis` directory and inside of it lives the subdirectories that are named as a program to run their contents by. For instance, `python` subdirectory with `*.py` files, `bash` with `*.sh` files, `ruby` with `*.rb` and so on.

Visualization of the above structure would look the following:

```
./tests/travis/
|-- bash/
|   |-- .extension
|   |-- test1.sh
|   |-- test2.sh
|-- pyhon/
|   |-- .extension
|   |-- test1.py
|   |-- test2.py
|-- ruby/
|   |-- .extension
|   |-- test1.rb
|   |-- test2.rb
|-- fixtures/
|   |-- fixture-bash.txt
|   |-- fixture-ruby.txt
```

The runner will iterate all over the subdirectories and collect only those, inside of which the `.extension` is present. The files inside of subdirectories that match the `[a-z]*.EXTENSION` pattern (where `EXTENSION` is a first line from the `.extension` file, e.g. `py`) will be treated as tests and executed.

Therefore, even if a subdirectory named `fixtures` exists but has no `.extension` inside, the files from it won't be attempted to run using `fixtures FILE` command.

Taking back to the directories structure the runner will execute the following commands:

```bash
bash bash/test1.sh
bash bash/test2.sh
pyhon pyhon/test1.py
pyhon pyhon/test2.py
ruby ruby/test1.rb
ruby ruby/test2.rb
```

The `fixtures` and files from it were skipped due to missing `.extension`.
{: .notice--info}

Having that unified tests runner you're no longer need to modify your `.travis.yml` by adding new lines of tests you'd like to run. Just create a file in an appropriate directory with a correct extension, commit it and push to the repo and all the magic will be done in the background. Also, since the pattern for matching tests in directories is `[a-z]`, it means you can create `Filename.txt` or `__init__.py` and be sure they won't executed.

## Conditional system

Travis CI allows specifying [`[skip ci]` or `[ci skip]` in a commit message](https://docs.travis-ci.com/user/customizing-the-build#Skipping-a-build) to not even create a build, but what if we would want to have a bit more?

An interesting part of the `runner.sh` which I personally like the most is an ability to control what tests to run via commit messages. This achieved by parsing the `TRAVIS_COMMIT_MESSAGE` environment variable that stores a message of a commit and available during the build.

The structure of tagging the actions in a message is preserved and looks the following - `[do action][do action2]` etc. (text in square brackets).

The runner being posted in this article has the implementation of an ability to skip something but you can extend the logic further. To use skipping functionality, do the following:

- add `[skip DIR]` to commit message and tests from `./tests/travis/DIR` won't be executed;
- use `[skip DIR/FILE]` to skip a particular test from `./tests/travis/DIR/FILE`;
- specify as much as needed actions per commit message.

When skipping a test the extension of a file **MUST NOT** be specified. If file is `bash/init.sh` then you just use `[skip bash/init]`. For `python/test.py` it'll be `[skip python/test]` and so on.
{: .notice--warning}

## Check in action

The [.travis.yml](https://github.com/BR0kEN-/cikit/blob/c37173b93d1eaee9b090fe4655cf6e5081122942/.travis.yml#L37) of CIKit uses exactly same [runner](https://github.com/BR0kEN-/cikit/blob/c37173b93d1eaee9b090fe4655cf6e5081122942/tests/travis/runner.sh#L1), which is responsible for launching [Bash](https://github.com/BR0kEN-/cikit/tree/c37173b93d1eaee9b090fe4655cf6e5081122942/tests/travis/bash) and [Python](https://github.com/BR0kEN-/cikit/tree/c37173b93d1eaee9b090fe4655cf6e5081122942/tests/travis/python) tests.
