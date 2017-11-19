#!/usr/bin/env bash

export ANSIBLE_VERBOSITY=2

# @param int $1
#   The expected exit code.
# @param string $2
#   The arguments fot the "cikit" command.
# @param string $3
#   The expected output of the command.
__check()
{
  local COMMAND="$2"
  local EXPECTED_OUTPUT="$3"
  local EXPECTED_EXIT_CODE="$1"
  local EXIT_CODE
  local OUTPUT

  echo "Testing the \"${COMMAND}\" command."

  OUTPUT="$(${COMMAND})"
  EXIT_CODE="$?"

  if [ "${EXPECTED_EXIT_CODE}" != "${EXIT_CODE}" ]; then
    echo "The expected exit code is \"${EXPECTED_EXIT_CODE}\" when actual is \"${EXIT_CODE}\"."
  fi

  if [[ -n "${EXPECTED_OUTPUT}" && ! "${OUTPUT}" = *"${EXPECTED_OUTPUT}"* ]]; then
    echo "The expected output of the \"${COMMAND}\" is:"
    echo "  ${EXPECTED_OUTPUT}"
    echo "when the actual is:"
    echo "  ${OUTPUT}"
  fi
}

for ARGSET in "" "--project" "--project=1"; do
  __check \
    1 \
    "cikit init --dry-run ${ARGSET}" \
    "ERROR: The \"--project\" option is required for the \"init\" command and currently missing or has a value less than 2 symbols."
done

__check 0 "cikit init --dry-run --project=test" "12"

for ARGSET in "" "--limit" "--limit=1"; do
  __check \
    1 \
    "cikit provision --dry-run ${ARGSET}" \
    "ERROR: The \"--limit\" option is required for the \"provision\" command and currently missing or has a value less than 2 symbols."
done

__check 0 "cikit provision --dry-run --limit=test"
