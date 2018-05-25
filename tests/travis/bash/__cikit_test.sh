#!/usr/bin/env bash

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
