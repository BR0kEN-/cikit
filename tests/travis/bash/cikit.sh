#!/usr/bin/env bash

TEST_PROJECT="cikit_test_project"
TEST_HOSTNAME="${TEST_PROJECT//_/-}.loc"

########################################################################################################################
# Functions

locate_path()
{
  local DIR="$1"

  if [ -L "$DIR" ]; then
    while [ -L "$DIR" ]; do
      DIR="$(\cd "$(\dirname -- "$(\readlink -- "$DIR")")" && \pwd)"
    done
  else
    DIR="$(\cd -P -- "$(\dirname -- "$DIR")" && \pwd -P)"
  fi

  \echo "$DIR"
}

# @param int $1
#   The expected exit code.
# @param string $2
#   The command to execute.
# @param string $3
#   The expected stdout.
# @param string $4
#   The expected stderr.
__cikit_test()
{
  local EXPECTED_EC="$1"
  local COMMAND="$2"
  local EXPECTED_OUT="$3"
  local EXPECTED_ERR="$4"
  local EC
  local OUT
  local ERR

  echo "Testing \"$COMMAND\" in \"$(pwd)\"."

  # The "eval" is needed to fully follow the arguments.
  . <({ ERR=$({ OUT=$(eval "${COMMAND}"); EC=$?; } 2>&1; declare -p OUT EC >&2); declare -p ERR; } 2>&1)

  if [ "$EXPECTED_EC" != "$EC" ]; then
    echo -e "\nThe expected exit code is \"$EXPECTED_EC\" when actual is \"$EC\".\n"
    exit 1
  fi

  if [[ -n "$EXPECTED_OUT" && ! "$OUT" = *"$EXPECTED_OUT"* ]]; then
    echo -e "\nThe expected output is:\n  $EXPECTED_OUT\nwhen actual is:\n  $OUT\n"
    exit 1
  fi

  if [[ -n "$EXPECTED_ERR" && ! "$ERR" = *"$EXPECTED_ERR"* ]]; then
    echo -e "\nThe expected error is:\n  $EXPECTED_ERR\nwhen actual is:\n  $ERR\n"
    exit 1
  fi
}

########################################################################################################################
# Set up

cd "$(locate_path "$0")/../../../"

SELF_DIR="$(pwd)"

if [ ! -d "$TEST_PROJECT" ]; then
  cikit init --project="$TEST_PROJECT"
fi

# Ensure no environment configuration exist.
rm "$TEST_PROJECT/.cikit/environment.yml" > /dev/null 2>&1

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
      "ERROR: You are trying to ${TESTS[$ACTION]} the container but its hostname cannot be determined. Did you break the \"site_url\" variable in \"$SELF_DIR/.cikit/config.yml\"?"
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
  "cikit $SELF_DIR/scripts/init.yml --dry-run --project=test" \
  "$(cat <<-HERE
ansible-playbook \
'$SELF_DIR/scripts/init.yml' \
-c 'local' \
-i 'localhost,' \
-e '{"project": "test"}' \
-i '$SELF_DIR/lib/inventory' \
-e __selfdir__='$SELF_DIR' \
-e __targetdir__='$SELF_DIR' \
-e __credentialsdir__='$SELF_DIR/credentials'
HERE
)"

########################################################################################################################
# cikit provision.

__cikit_test \
  20 \
  "cikit provision --dry-run --limit=test" \
  "" \
  "ERROR: Execution of the \"provision\" is available only within the CIKit-project directory."

cd "$TEST_PROJECT"

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
'$SELF_DIR/scripts/provision.yml' \
-i 'cikit-test-project.loc,' \
-c docker \
-u root \
-l '$TEST_HOSTNAME,' \
-e '{"limit": "$TEST_HOSTNAME,"}' \
-i '$SELF_DIR/lib/inventory' \
-e __selfdir__='$SELF_DIR' \
-e __targetdir__='$SELF_DIR/$TEST_PROJECT' \
-e __credentialsdir__='$SELF_DIR/$TEST_PROJECT/.cikit/credentials/$TEST_HOSTNAME'
HERE
)"
done

__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test" \
  "$(cat <<-HERE
ansible-playbook \
'$SELF_DIR/scripts/provision.yml' \
-l 'test' \
-e '{"limit": "test"}' \
-i '$SELF_DIR/lib/inventory' \
-e __selfdir__='$SELF_DIR' \
-e __targetdir__='$SELF_DIR/$TEST_PROJECT' \
-e __credentialsdir__='$SELF_DIR/$TEST_PROJECT/.cikit/credentials/test'
HERE
)"

__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test --bla=12 --bla1" \
  "$(cat <<-HERE
ansible-playbook \
'$SELF_DIR/scripts/provision.yml' \
-l 'test' \
-e '{"bla1": true, "limit": "test", "bla": "12"}' \
-i '$SELF_DIR/lib/inventory' \
-e __selfdir__='$SELF_DIR' \
-e __targetdir__='$SELF_DIR/$TEST_PROJECT' \
-e __credentialsdir__='$SELF_DIR/$TEST_PROJECT/.cikit/credentials/test'
HERE
)"

echo "---
php_version: '5.6'
nodejs_version: '6'
ruby_version: 2.4.0
solr_version: 5.5.5
mssql_install: 'yes'" > ./.cikit/environment.yml

# Ensure the values from the "environment.yml" will be passed as extra variables to the playbook.
# Also, ensure the custom options are passed as well.
__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test --bla=12 --bla1" \
  "$(cat <<-HERE
ansible-playbook \
'$SELF_DIR/scripts/provision.yml' \
-l 'test' \
-e '{"nodejs_version": "6", "solr_version": "5.5.5", "bla1": true, "mssql_install": "yes", "ruby_version": "2.4.0", "limit": "test", "php_version": "5.6", "bla": "12"}' \
-i '$SELF_DIR/lib/inventory' \
-e __selfdir__='$SELF_DIR' \
-e __targetdir__='$SELF_DIR/$TEST_PROJECT' \
-e __credentialsdir__='$SELF_DIR/$TEST_PROJECT/.cikit/credentials/test'
HERE
)"

__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test --bla=12 --bla1 --solr-version=6.6.3" \
  "$(cat <<-HERE
ansible-playbook \
'$SELF_DIR/scripts/provision.yml' \
-l 'test' \
-e '{"nodejs_version": "6", "ruby_version": "2.4.0", "bla1": true, "mssql_install": "yes", "solr_version": "6.6.3", "limit": "test", "php_version": "5.6", "bla": "12"}' \
-i '$SELF_DIR/lib/inventory' \
-e __selfdir__='$SELF_DIR' \
-e __targetdir__='$SELF_DIR/$TEST_PROJECT' \
-e __credentialsdir__='$SELF_DIR/$TEST_PROJECT/.cikit/credentials/test'
HERE
)"

# Ensure we can pass JSON as value for custom options.
__cikit_test \
  0 \
  "$(cat <<-HERE
cikit provision --dry-run --limit=test --bla=12 --bla1 --solr-version=6.6.3 --ob='{"a": {"b": 1}}' --ar='[1, 2, 3]'
HERE
)" \
  "$(cat <<-HERE
ansible-playbook \
'$SELF_DIR/scripts/provision.yml' \
-l 'test' \
-e '{"nodejs_version": "6", "ruby_version": "2.4.0", "bla1": true, "ob": "{\"a\": {\"b\": 1}}", "mssql_install": "yes", "solr_version": "6.6.3", "ar": "[1, 2, 3]", "limit": "test", "php_version": "5.6", "bla": "12"}' \
-i '$SELF_DIR/lib/inventory' \
-e __selfdir__='$SELF_DIR' \
-e __targetdir__='$SELF_DIR/$TEST_PROJECT' \
-e __credentialsdir__='$SELF_DIR/$TEST_PROJECT/.cikit/credentials/test'
HERE
)"

# Ensure the "EXTRA_VARS" environment variable can override the CLI parameters.
export EXTRA_VARS="--bla=14 --ob='{\"a\": {\"b\": 2}}' --ar='[1, 2, 4]'"

__cikit_test \
  0 \
  "$(cat <<-HERE
cikit provision --dry-run --limit=test --bla=12 --bla1 --solr-version=6.6.3 --ob='{"a": {"b": 1}}' --ar='[1, 2, 3]'
HERE
)" \
  "$(cat <<-HERE
ansible-playbook \
'$SELF_DIR/scripts/provision.yml' \
-l 'test' \
-e '{"nodejs_version": "6", "ruby_version": "2.4.0", "bla1": true, "ob": "{\"a\": {\"b\": 2}}", "mssql_install": "yes", "solr_version": "6.6.3", "ar": "[1, 2, 4]", "limit": "test", "php_version": "5.6", "bla": "14"}' \
-i '$SELF_DIR/lib/inventory' \
-e __selfdir__='$SELF_DIR' \
-e __targetdir__='$SELF_DIR/$TEST_PROJECT' \
-e __credentialsdir__='$SELF_DIR/$TEST_PROJECT/.cikit/credentials/test'
HERE
)"

unset EXTRA_VARS
