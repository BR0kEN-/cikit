#!/usr/bin/env bash

set -e

export PROJECT_NAME="test_project"
export ANSIBLE_HOST_KEY_CHECKING=False
export EXTRA_VARS="--web-server=nginx --php-version=7.3 --nodejs-version=6 --ruby-version=2.4.0 --solr-version=7.7.2 --mssql-install --psql-install --mongodb-install=no"

cikit init --project="$PROJECT_NAME" --cmf=drupal
cd "$PROJECT_NAME"

cikit env/start
cikit provision

# Test (re-)installation of Drupal
# @todo Think about WordPress and other CMFs.
cikit ssh "cikit reinstall"
