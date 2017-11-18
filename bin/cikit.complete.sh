_cikit_complete()
{
    COMPREPLY=($(compgen -W "$(CIKIT_SUPPRESS_EXECUTION_TIME=true cikit)" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _cikit_complete cikit
