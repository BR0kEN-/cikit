#!/usr/bin/env bash

set -e

CIKIT_PATH="/usr/local/share/cikit"
PROJECT_NAME="test_project"
TEST_HOSTNAME="${PROJECT_NAME//_/-}.loc"

source "$CIKIT_PATH/tests/travis/bash/__cikit_test.sh"
cd "$CIKIT_PATH"

# Default Drupal version.
__cikit_test \
  0 \
  "cikit init --project='$PROJECT_NAME' --cmf=drupal" \
  "failed=0"

# Wrong Drupal version.
__cikit_test \
  2 \
  "cikit init --project='$PROJECT_NAME' --cmf=drupal --version=8.6.x" \
  "failed=1"

# Custom Drupal version.
__cikit_test \
  0 \
  "cikit init --project='$PROJECT_NAME' --cmf=drupal --version=8.6.x-dev" \
  "failed=0"

# Default Wordpress version.
__cikit_test \
  0 \
  "cikit init --project='$PROJECT_NAME' --cmf=wordpress" \
  "failed=0"

# Wrong Wordpress version.
__cikit_test \
  2 \
  "cikit init --project='$PROJECT_NAME' --cmf=wordpress --version=9.0.1" \
  "failed=1"

# Custom Wordpress version.
__cikit_test \
  0 \
  "cikit init --project='$PROJECT_NAME' --cmf=wordpress --version=4.6.5" \
  "failed=0"
