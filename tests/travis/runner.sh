#!/usr/bin/env bash

set -e

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
