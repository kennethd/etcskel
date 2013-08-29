# LESS options:
# -F    --quit-if-one-screen
# -R    --RAW_CONTROL_CHARS (git log friendly)
# -S    --chop-long-lines (never fold lines)
# -X    --no-init (don't clear the screen after exiting)
# -i    --ignore-case (default)
export LESS="-FRSXi"
# to allow viewing of tar files, etc with less
eval $(lesspipe)

alias du1='du --max-depth=1 . | sort -n'
alias lesspnum="less -P '%f        ?db%db / %D.'"
alias ls='ls --color=auto'
alias ll='ls -l'
alias moby='dict -d moby-thesaurus'
alias rdiff='diff -bBqr --exclude=CVS'
alias screen='screen -h 1200'

alias reverse-words="awk '{ for (i=NF; i>0; i--) printf(\"%s \", \$i) } { printf(\"%s\", \"\n\") }'"

# vi: set syntax=bash
