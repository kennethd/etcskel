# LESS options:
# -F    --quit-if-one-screen
# -R    --RAW_CONTROL_CHARS (git log friendly)
# -S    --chop-long-lines (never fold lines)
# -X    --no-init (don't clear the screen after exiting)
# -i    --ignore-case (default)
export LESS="-FRSXi"

alias du1='du --max-depth=1 . | sort -n'
alias lesspnum="less -P '%f        ?db%db / %D.'"
alias ls='ls --color=auto'
alias ll='ls -l'
alias moby='dict -d moby-thesaurus'
alias pwsugg='apg -n24 -m10 -x18 -MSNCL'
alias rdiff='diff -bBqr --exclude=CVS'
alias screen='screen -h 1600'
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip'

alias reverse-words="awk '{ for (i=NF; i>0; i--) printf(\"%s \", \$i) } { printf(\"%s\", \"\n\") }'"



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                           #
#                   L O C A L   C U S T O M I Z A T I O N S                 #
#                                                                           #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# put whatever you want into the following directory to add locally-controlled
# files not necessarily kept in source control (all files should be bash syntax)
if [ -d "$HOME"/.bash/aliases.d ]
then
    for f in "$HOME"/.bash/aliases.d/*
    do
        . "$f"
    done
fi

# vi: set syntax=bash
