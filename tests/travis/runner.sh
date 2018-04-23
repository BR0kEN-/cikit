#!/usr/bin/env bash

cikit init --project=test_project --without-sources
cd test_project
cikit env/start
cikit ssh env
cd ../

cd ./tests/travis
declare -A TESTS=()

for INTERPRETER in [a-z]*/; do
  TESTS["${INTERPRETER%%/}"]="$(head -n1 "$INTERPRETER/.extension")"
done

# Parse the commit message that looks like "#120: [skip bash/init][ skip  python] Commit name".
# The resulting string will be: "|skipbash/init|skippython|"
if [ -v TRAVIS_COMMIT_MESSAGE ]; then
  PARAMS="|$(awk -vRS="]" -vFS="[" '{print $2}' <<< "$TRAVIS_COMMIT_MESSAGE" | head -n -1 | tr '\n' '|' | tr -d '[:space:]')"
fi

for INTERPRETER in "${!TESTS[@]}"; do
  if [[ ! "$PARAMS" =~ \|skip$INTERPRETER\| ]]; then
    find "$INTERPRETER" -name "[a-z]*.${TESTS[$INTERPRETER]}" -type f | while read -r TEST; do
      if [[ ! "$PARAMS" =~ \|skip${TEST%%.${TESTS[$INTERPRETER]}}\| ]]; then
        echo "[$(date --iso-8601=seconds)] -- $TEST"
        ${INTERPRETER} "$TEST"
      fi
    done
  fi
done
