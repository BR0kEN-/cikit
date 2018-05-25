#!/usr/bin/env bash

set -e

CIKIT_PATH="/usr/local/share/cikit"
PROJECT_NAME="test_project"

cd "$CIKIT_PATH"

verify_output()
{
  local RESULT

  RESULT="$($1 2>&1)"

  if [[ ! "$RESULT" =~ "$2" ]]; then
    echo "Failed: $1"
    exit 1
  fi

  rm -rf "$PROJECT_NAME"
}

# Default Drupal version.
verify_output \
  "cikit init --project='$PROJECT_NAME' --cmf=drupal" \
  "failed=0"

# Wrong Drupal version.
verify_output \
  "cikit init --project='$PROJECT_NAME' --cmf=drupal --version=8.6.x" \
  "failed=1"

# Custom Drupal version.
verify_output \
  "cikit init --project='$PROJECT_NAME' --cmf=drupal --version=8.6.x-dev" \
  "failed=0"

# Default Wordpress version.
verify_output \
  "cikit init --project='$PROJECT_NAME' --cmf=wordpress" \
  "failed=0"

# Wrong Wordpress version.
verify_output \
  "cikit init --project='$PROJECT_NAME' --cmf=wordpress --version=9.0.1" \
  "failed=1"

# Custom Wordpress version.
verify_output \
  "cikit init --project='$PROJECT_NAME' --cmf=wordpress --version=4.6.5" \
  "failed=0"
