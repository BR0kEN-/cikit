#!/usr/bin/env bash

CIKIT_OPTIONS="--help|--version"
CIKIT_PLAYBOOKS="$(CIKIT_SUPPRESS_EXECUTION_TIME=true cikit)"
CIKIT_ARGUMENTS=""
HAS_COMPOPT=false

# Mac OS has no "compopt" by default.
if \command -v "compopt" >/dev/null; then
  HAS_COMPOPT=true
fi

IFS=$'\n'

for PARAMETER in $(cikit --help | \tail -n+4 | \grep -Eo "(--(\w|-)*(\s\[.+?\])?)" | \sort | \uniq); do
  if [[ "${PARAMETER}" =~ [[:space:]] ]]; then
    CIKIT_ARGUMENTS+="${PARAMETER%% *}= "
  elif [[ ! "${PARAMETER}" =~ ${CIKIT_OPTIONS} ]]; then
    CIKIT_ARGUMENTS+="${PARAMETER} "
  fi
done

unset IFS

_cikit_complete()
{
  local WORDS="${CIKIT_PLAYBOOKS}"
  local CURRENT="${COMP_WORDS[COMP_CWORD]}"
  local PARAMETERS

  if [[ "${COMP_WORDS[1]}" =~ ^- ]]; then
    IFS="|" read -r -a PARAMETERS <<< "${CIKIT_OPTIONS}"
  else
    for PLAYBOOK in ${CIKIT_PLAYBOOKS}; do
      # Playbook has been chosen. Autocomplete the parameters.
      if [ "${PLAYBOOK}" == "${COMP_WORDS[1]}" ]; then
        IFS=" " read -r -a PARAMETERS <<< "${CIKIT_ARGUMENTS}"
        break
      fi
    done
  fi

  if [ -n "${PARAMETERS}" ]; then
    for ARGUMENT in "${COMP_WORDS[@]}"; do
      for PARAMETER_INDEX in "${!PARAMETERS[@]}"; do
        if [ "${ARGUMENT}" == "${PARAMETERS[PARAMETER_INDEX]}" ]; then
          unset "PARAMETERS[PARAMETER_INDEX]"
        fi
      done
    done

    WORDS=${PARAMETERS[*]}
  fi

  COMPREPLY=($(\compgen -W "${WORDS}" -- "${CURRENT}"))

  if ${HAS_COMPOPT} && [[ "${COMPREPLY[@]}" =~ = ]] ; then
    \compopt -o nospace
  fi
}

\complete -F _cikit_complete cikit
