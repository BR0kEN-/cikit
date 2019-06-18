#!/usr/bin/env bash

set -e

CIKIT_PATH="/usr/local/share/cikit"
PROJECT_NAME="cikit_test_project"
TEST_HOSTNAME="${PROJECT_NAME//_/-}.loc"

source "$CIKIT_PATH/tests/travis/bash/__cikit_test.sh"
cd "$CIKIT_PATH"

########################################################################################################################
# Functions

rm_safe()
{
  if [ -f "$1" ]; then
    rm -rf "$1"
  fi
}

########################################################################################################################
# Set up

if [ ! -d "$PROJECT_NAME" ]; then
  cikit init --project="$PROJECT_NAME"
fi

# Ensure no environment configuration exist.
rm_safe "$PROJECT_NAME/.cikit/environment.yml"

export ANSIBLE_VERBOSITY=2

########################################################################################################################
# Docker-based tests.

if command -v docker > /dev/null; then
  declare -A TESTS=([ssh]="login to" [provision]="provision")

  for ACTION in "${!TESTS[@]}"; do
    __cikit_test \
      200 \
      "cikit $ACTION" \
      "" \
      "ERROR: You are trying to ${TESTS[$ACTION]} the container but its hostname cannot be determined. Did you break the \"site_url\" variable in \"$CIKIT_PATH/.cikit/config.yml\"?"
  done
fi

########################################################################################################################
# Try to use undefined playbook.

__cikit_test \
  23 \
  "cikit bla" \
  "" \
  "ERROR: The \"bla\" command is not available."

########################################################################################################################
# cikit init

for ARGSET in "" "--project" "--project=1"; do
  __cikit_test \
    1 \
    "cikit init --dry-run $ARGSET" \
    "" \
    "ERROR: The \"--project\" option is required for the \"init\" command and currently missing or has a value less than 2 symbols."
done

# Try to use a full path to the playbook.
__cikit_test \
  0 \
  "cikit $CIKIT_PATH/scripts/init.yml --dry-run --project=test" \
  "$(cat <<-HERE
ansible-playbook \
'$CIKIT_PATH/scripts/init.yml' \
-c 'local' \
-i 'localhost,' \
-e '{"project": "test"}' \
-i '$CIKIT_PATH/lib/inventory' \
-e __selfdir__='$CIKIT_PATH' \
-e __targetdir__='$CIKIT_PATH' \
-e __credentialsdir__='$CIKIT_PATH/credentials'
HERE
)"

########################################################################################################################
# cikit provision.

__cikit_test \
  20 \
  "cikit provision --dry-run --limit=test" \
  "" \
  "ERROR: Execution of the \"provision\" is available only within the CIKit-project directory."

cd "$PROJECT_NAME"

__cikit_test \
  1 \
  "cikit provision --dry-run --limit=1" \
  "" \
  "ERROR: The \"--limit\" option is required for the \"provision\" command and currently missing or has a value less than 2 symbols."

for ARGSET in "" "--limit"; do
  __cikit_test \
    0 \
    "cikit provision --dry-run $ARGSET" \
  "$(cat <<-HERE
ansible-playbook \
'$CIKIT_PATH/scripts/provision.yml' \
-i '$TEST_HOSTNAME,' \
-c docker \
-u root \
-l '$TEST_HOSTNAME,' \
-e '{"limit": "$TEST_HOSTNAME,"}' \
-i '$CIKIT_PATH/lib/inventory' \
-e __selfdir__='$CIKIT_PATH' \
-e __targetdir__='$CIKIT_PATH/$PROJECT_NAME' \
-e __credentialsdir__='$CIKIT_PATH/$PROJECT_NAME/.cikit/credentials/$TEST_HOSTNAME'
HERE
)"
done

__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test" \
  "$(cat <<-HERE
ansible-playbook \
'$CIKIT_PATH/scripts/provision.yml' \
-l 'test' \
-e '{"limit": "test"}' \
-i '$CIKIT_PATH/lib/inventory' \
-e __selfdir__='$CIKIT_PATH' \
-e __targetdir__='$CIKIT_PATH/$PROJECT_NAME' \
-e __credentialsdir__='$CIKIT_PATH/$PROJECT_NAME/.cikit/credentials/test'
HERE
)"

__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test --bla=12 --bla1" \
  "$(cat <<-HERE
ansible-playbook \
'$CIKIT_PATH/scripts/provision.yml' \
-l 'test' \
-e '{"bla1": true, "limit": "test", "bla": "12"}' \
-i '$CIKIT_PATH/lib/inventory' \
-e __selfdir__='$CIKIT_PATH' \
-e __targetdir__='$CIKIT_PATH/$PROJECT_NAME' \
-e __credentialsdir__='$CIKIT_PATH/$PROJECT_NAME/.cikit/credentials/test'
HERE
)"

echo "---
php_version: '5.6'
nodejs_version: '6'
ruby_version: 2.4.0
solr_version: 8.1.1
mssql_install: 'yes'" > ./.cikit/environment.yml

# Ensure the values from the "environment.yml" will be passed as extra variables to the playbook.
# Also, ensure the custom options are passed as well.
__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test --bla=12 --bla1" \
  "$(cat <<-HERE
ansible-playbook \
'$CIKIT_PATH/scripts/provision.yml' \
-l 'test' \
-e '{"nodejs_version": "6", "solr_version": "8.1.1", "bla1": true, "mssql_install": "yes", "ruby_version": "2.4.0", "limit": "test", "php_version": "5.6", "bla": "12"}' \
-i '$CIKIT_PATH/lib/inventory' \
-e __selfdir__='$CIKIT_PATH' \
-e __targetdir__='$CIKIT_PATH/$PROJECT_NAME' \
-e __credentialsdir__='$CIKIT_PATH/$PROJECT_NAME/.cikit/credentials/test'
HERE
)"

__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test --bla=12 --bla1 --solr-version=7.7.2" \
  "$(cat <<-HERE
ansible-playbook \
'$CIKIT_PATH/scripts/provision.yml' \
-l 'test' \
-e '{"nodejs_version": "6", "ruby_version": "2.4.0", "bla1": true, "mssql_install": "yes", "solr_version": "7.7.2", "limit": "test", "php_version": "5.6", "bla": "12"}' \
-i '$CIKIT_PATH/lib/inventory' \
-e __selfdir__='$CIKIT_PATH' \
-e __targetdir__='$CIKIT_PATH/$PROJECT_NAME' \
-e __credentialsdir__='$CIKIT_PATH/$PROJECT_NAME/.cikit/credentials/test'
HERE
)"

# Ensure we can pass JSON as value for custom options.
__cikit_test \
  0 \
  "$(cat <<-HERE
cikit provision --dry-run --limit=test --bla=12 --bla1 --solr-version=7.7.2 --ob='{"a": {"b": 1}}' --ar='[1, 2, 3]'
HERE
)" \
  "$(cat <<-HERE
ansible-playbook \
'$CIKIT_PATH/scripts/provision.yml' \
-l 'test' \
-e '{"nodejs_version": "6", "ruby_version": "2.4.0", "bla1": true, "ob": "{\"a\": {\"b\": 1}}", "mssql_install": "yes", "solr_version": "7.7.2", "ar": "[1, 2, 3]", "limit": "test", "php_version": "5.6", "bla": "12"}' \
-i '$CIKIT_PATH/lib/inventory' \
-e __selfdir__='$CIKIT_PATH' \
-e __targetdir__='$CIKIT_PATH/$PROJECT_NAME' \
-e __credentialsdir__='$CIKIT_PATH/$PROJECT_NAME/.cikit/credentials/test'
HERE
)"

# Ensure the "EXTRA_VARS" environment variable can override the CLI parameters.
export EXTRA_VARS="--bla=14 --ob='{\"a\": {\"b\": 2}}' --ar='[1, 2, 4]'"

__cikit_test \
  0 \
  "$(cat <<-HERE
cikit provision --dry-run --limit=test --bla=12 --bla1 --solr-version=7.7.2 --ob='{"a": {"b": 1}}' --ar='[1, 2, 3]'
HERE
)" \
  "$(cat <<-HERE
ansible-playbook \
'$CIKIT_PATH/scripts/provision.yml' \
-l 'test' \
-e '{"nodejs_version": "6", "ruby_version": "2.4.0", "bla1": true, "ob": "{\"a\": {\"b\": 2}}", "mssql_install": "yes", "solr_version": "7.7.2", "ar": "[1, 2, 4]", "limit": "test", "php_version": "5.6", "bla": "14"}' \
-i '$CIKIT_PATH/lib/inventory' \
-e __selfdir__='$CIKIT_PATH' \
-e __targetdir__='$CIKIT_PATH/$PROJECT_NAME' \
-e __credentialsdir__='$CIKIT_PATH/$PROJECT_NAME/.cikit/credentials/test'
HERE
)"

unset EXTRA_VARS
