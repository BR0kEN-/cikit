#!/usr/bin/env bash

set -e

export PROJECT_NAME="test_project"
export ANSIBLE_HOST_KEY_CHECKING=False
export EXTRA_VARS="--web-server=nginx --php-version=7.1 --nodejs-version=6 --ruby-version=2.4.0 --solr-version=6.6.3 --mssql-install"

cikit init --project="$PROJECT_NAME" --cmf=drupal
cd "$PROJECT_NAME"

cikit env/start
cikit provision

# Test (re-)installation of Drupal
# @todo Think about WordPress and other CMFs.
# @todo Cannot run due to https://github.com/solita/docker-systemd/issues/15.
#cikit ssh "bash -lc 'cikit reinstall'"
