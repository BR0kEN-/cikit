#!/usr/bin/env bash

cd ./tests/travis
declare -A TESTS=()

for INTERPRETER in [a-z]*/; do
  EXTENSION="$INTERPRETER/.extension"

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
      echo "[$(date --iso-8601=seconds)] -- $TEST"
      ${INTERPRETER} "$TEST"
    done
  fi
done
