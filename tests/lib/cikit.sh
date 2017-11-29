#!/usr/bin/env bash

TEST_PROJECT="cikit_test_project"

########################################################################################################################
# Functions

locate_path()
{
  local DIR="$1"

  if [ -L "${DIR}" ]; then
    while [ -L "${DIR}" ]; do
      DIR="$(\cd "$(\dirname -- "$(\readlink -- "${DIR}")")" && \pwd)"
    done
  else
    DIR="$(\cd -P -- "$(\dirname -- "${DIR}")" && \pwd -P)"
  fi

  \echo "${DIR}"
}

# @param int $1
#   The expected exit code.
# @param string $2
#   The arguments fot the "cikit" command.
# @param string $3
#   The expected output of the command.
__cikit_test()
{
  local COMMAND="$2"
  local EXPECTED_OUTPUT="$3"
  local EXPECTED_EXIT_CODE="$1"
  local EXIT_CODE
  local OUTPUT

  echo "Testing the \"${COMMAND}\" command which ran in \"$(pwd)\"."

  # The "eval" is needed to fully follow the arguments.
  OUTPUT="$(eval "${COMMAND}")"
  EXIT_CODE="$?"

  if [ "${EXPECTED_EXIT_CODE}" != "${EXIT_CODE}" ]; then
    echo -e "\nThe expected exit code is \"${EXPECTED_EXIT_CODE}\" when actual is \"${EXIT_CODE}\".\n"
  fi

  if [[ -n "${EXPECTED_OUTPUT}" && ! "${OUTPUT}" = *"${EXPECTED_OUTPUT}"* ]]; then
    echo -e "\nThe expected output is:\n  ${EXPECTED_OUTPUT}\nwhen actual is:\n  ${OUTPUT}\n"
  fi
}

########################################################################################################################
# Set up

cd "$(locate_path "$0")/../../"

SELF_DIR="$(pwd)"

if [ ! -d "${TEST_PROJECT}" ]; then
  cikit init --project="${TEST_PROJECT}"
fi

# Ensure no environment configuration exist.
rm "${TEST_PROJECT}/.cikit/environment.yml" > /dev/null 2>&1

export ANSIBLE_VERBOSITY=2

########################################################################################################################
# Try to use undefined playbook.

__cikit_test \
  23 \
  "cikit bla" \
  "ERROR: The \"bla\" command is not available."

########################################################################################################################
# cikit init

for ARGSET in "" "--project" "--project=1"; do
  __cikit_test \
    1 \
    "cikit init --dry-run ${ARGSET}" \
    "ERROR: The \"--project\" option is required for the \"init\" command and currently missing or has a value less than 2 symbols."
done

# Try to use a full path to the playbook.
__cikit_test \
  0 \
  "cikit \"${SELF_DIR}/scripts/init.yml\" --dry-run --project=test" \
  "$(cat <<-HERE
ansible-playbook \
'${SELF_DIR}/scripts/init.yml' \
-i 'localhost,' \
-e '{"project": "test"}' \
-e __selfdir__='${SELF_DIR}' \
-e __targetdir__='${SELF_DIR}' \
-e __credentialsdir__='${SELF_DIR}/credentials'
HERE
)"

########################################################################################################################
# cikit provision.

__cikit_test \
  20 \
  "cikit provision --dry-run --limit=test" \
  "ERROR: Execution of the \"provision\" is available only within the CIKit-project directory."

cd "${TEST_PROJECT}"

for ARGSET in "" "--limit" "--limit=1"; do
  __cikit_test \
    1 \
    "cikit provision --dry-run ${ARGSET}" \
    "ERROR: The \"--limit\" option is required for the \"provision\" command and currently missing or has a value less than 2 symbols."
done

__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test" \
  "$(cat <<-HERE
ansible-playbook \
'${SELF_DIR}/scripts/provision.yml' \
-l 'test' \
-i '${SELF_DIR}/lib/inventory' \
-e '{"limit": "test"}' \
-e __selfdir__='${SELF_DIR}' \
-e __targetdir__='${SELF_DIR}/${TEST_PROJECT}' \
-e __credentialsdir__='${SELF_DIR}/${TEST_PROJECT}/.cikit/credentials/test'
HERE
)"

__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test --bla=12 --bla1" \
  "$(cat <<-HERE
ansible-playbook \
'${SELF_DIR}/scripts/provision.yml' \
-l 'test' \
-i '${SELF_DIR}/lib/inventory' \
-e '{"bla1": true, "limit": "test", "bla": "12"}' \
-e __selfdir__='${SELF_DIR}' \
-e __targetdir__='${SELF_DIR}/${TEST_PROJECT}' \
-e __credentialsdir__='${SELF_DIR}/${TEST_PROJECT}/.cikit/credentials/test'
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
'${SELF_DIR}/scripts/provision.yml' \
-l 'test' \
-i '${SELF_DIR}/lib/inventory' \
-e '{"nodejs_version": "6", "solr_version": "5.5.5", "bla1": true, "mssql_install": "yes", "ruby_version": "2.4.0", "limit": "test", "php_version": "5.6", "bla": "12"}' -e __selfdir__='${SELF_DIR}' \
-e __targetdir__='${SELF_DIR}/${TEST_PROJECT}' \
-e __credentialsdir__='${SELF_DIR}/${TEST_PROJECT}/.cikit/credentials/test'
HERE
)"

__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test --bla=12 --bla1 --solr-version=6.6.2" \
  "$(cat <<-HERE
ansible-playbook \
'${SELF_DIR}/scripts/provision.yml' \
-l 'test' \
-i '${SELF_DIR}/lib/inventory' \
-e '{"nodejs_version": "6", "ruby_version": "2.4.0", "bla1": true, "mssql_install": "yes", "solr_version": "6.6.2", "limit": "test", "php_version": "5.6", "bla": "12"}' \
-e __selfdir__='${SELF_DIR}' \
-e __targetdir__='${SELF_DIR}/${TEST_PROJECT}' \
-e __credentialsdir__='${SELF_DIR}/${TEST_PROJECT}/.cikit/credentials/test'
HERE
)"

# Ensure we can pass JSON as value for custom options.
__cikit_test \
  0 \
  "$(cat <<-HERE
cikit provision --dry-run --limit=test --bla=12 --bla1 --solr-version=6.6.2 --ob='{"a": {"b": 1}}' --ar='[1, 2, 3]'
HERE
)" \
  "$(cat <<-HERE
ansible-playbook \
'${SELF_DIR}/scripts/provision.yml' \
-l 'test' \
-i '${SELF_DIR}/lib/inventory' \
-e '{"nodejs_version": "6", "ruby_version": "2.4.0", "bla1": true, "ob": "{\"a\": {\"b\": 1}}", "mssql_install": "yes", "solr_version": "6.6.2", "ar": "[1, 2, 3]", "limit": "test", "php_version": "5.6", "bla": "12"}' \
-e __selfdir__='${SELF_DIR}' \
-e __targetdir__='${SELF_DIR}/${TEST_PROJECT}' \
-e __credentialsdir__='${SELF_DIR}/${TEST_PROJECT}/.cikit/credentials/test'
HERE
)"

# Ensure the "EXTRA_VARS" environment variable can override the CLI parameters.
export EXTRA_VARS="--bla=14 --ob='{\"a\": {\"b\": 2}}' --ar='[1, 2, 4]'"

__cikit_test \
  0 \
  "$(cat <<-HERE
cikit provision --dry-run --limit=test --bla=12 --bla1 --solr-version=6.6.2 --ob='{"a": {"b": 1}}' --ar='[1, 2, 3]'
HERE
)" \
  "$(cat <<-HERE
ansible-playbook \
'${SELF_DIR}/scripts/provision.yml' \
-l 'test' \
-i '${SELF_DIR}/lib/inventory' \
-e '{"nodejs_version": "6", "ruby_version": "2.4.0", "bla1": true, "ob": "{\"a\": {\"b\": 2}}", "mssql_install": "yes", "solr_version": "6.6.2", "ar": "[1, 2, 4]", "limit": "test", "php_version": "5.6", "bla": "14"}' \
-e __selfdir__='${SELF_DIR}' \
-e __targetdir__='${SELF_DIR}/${TEST_PROJECT}' \
-e __credentialsdir__='${SELF_DIR}/${TEST_PROJECT}/.cikit/credentials/test'
HERE
)"

unset EXTRA_VARS
