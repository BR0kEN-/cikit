#!/usr/bin/env bash

CIKIT_PLAYBOOKS="$(CIKIT_SUPPRESS_EXECUTION_TIME=true cikit)"
CIKIT_PARAMETERS=""

IFS=$'\n'

for PARAMETER in $(cikit --help | \grep -Eo "(--(\w|-)*(\s\[.+?\])?)" | \sort | \uniq); do
    if [[ "${PARAMETER}" =~ [[:space:]] ]]; then
        CIKIT_PARAMETERS+="${PARAMETER% *}= "
    elif [ "${PARAMETER}" != "--help" ]; then
        CIKIT_PARAMETERS+="${PARAMETER} "
    fi
done

unset IFS

_cikit_complete()
{
    local WORDS
    local CURRENT="${COMP_WORDS[COMP_CWORD]}"

    WORDS="${CIKIT_PLAYBOOKS}"

    for PLAYBOOK in ${CIKIT_PLAYBOOKS}; do
        # Playbook has been chosen. Autocomplete the parameters.
        if [ "${PLAYBOOK}" == "${COMP_WORDS[1]}" ]; then
            IFS=" " read -r -a PARAMETERS <<< "${CIKIT_PARAMETERS}"

            for ARGUMENT in "${COMP_WORDS[@]}"; do
                for PARAMETER_INDEX in "${!PARAMETERS[@]}"; do
                    if [ "${ARGUMENT}" == "${PARAMETERS[PARAMETER_INDEX]}" ]; then
                        unset "PARAMETERS[PARAMETER_INDEX]"
                    fi
                done
            done

            WORDS=${PARAMETERS[*]}
            break
        fi
    done

    COMPREPLY=($(\compgen -W "${WORDS}" -- "${CURRENT}"))
}

\complete -F _cikit_complete cikit
