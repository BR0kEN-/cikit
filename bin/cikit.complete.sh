_cikit_complete()
{
  COMPREPLY=($(compgen -W "$(cikit)" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _cikit_complete cikit
