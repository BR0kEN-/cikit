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

  OUTPUT="$(${COMMAND})"
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

export ANSIBLE_VERBOSITY=2

########################################################################################################################
# cikit init

for ARGSET in "" "--project" "--project=1"; do
  __cikit_test \
    1 \
    "cikit init --dry-run ${ARGSET}" \
    "ERROR: The \"--project\" option is required for the \"init\" command and currently missing or has a value less than 2 symbols."
done

__cikit_test \
  0 \
  "cikit init --dry-run --project=test" \
  "$(cat <<-HERE
ansible-playbook '${SELF_DIR}/scripts/init.yml' -i 'localhost,' -e '{"project": "test"}' -e __targetdir__='${SELF_DIR}'
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
ansible-playbook '${SELF_DIR}/scripts/provision.yml' -i '${HOME}/.cikit-inventory' -l 'test' -e '{"limit": "test"}' -e __targetdir__='${SELF_DIR}/${TEST_PROJECT}'
HERE
)"

__cikit_test \
  0 \
  "cikit provision --dry-run --limit=test --bla=12 --bla1" \
  "$(cat <<-HERE
ansible-playbook '${SELF_DIR}/scripts/provision.yml' -i '${HOME}/.cikit-inventory' -l 'test' -e '{"bla1": true, "limit": "test", "bla": "12"}' -e __targetdir__='${SELF_DIR}/${TEST_PROJECT}'
HERE
)"
