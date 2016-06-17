
alias diff-color="diff --old-group-format=$'\e[0;31m%<\e[0m' --new-group-format=$'\e[0;32m%>\e[0m' --unchanged-group-format=$'\e[0;37m%=\e[0m'"
alias du1='du --max-depth=1 . | sort -n'
alias lesspnum="less -P '%f        ?db%db / %D.'"
alias ls='ls --color=auto'
alias ll='ls -l'
alias moby='dict -d moby-thesaurus'
alias pwsugg='apg -n24 -m10 -x18 -MSNCL'
alias rdiff='diff -bBqr --exclude=CVS'
# $ echo 'one two three four five' | reverse-words
# five four three two one
alias reverse-words="awk '{ for (i=NF; i>0; i--) printf(\"%s \", \$i) } { printf(\"%s\", \"\n\") }'"
alias screen='screen -h 1600'
alias speedtest='wget -O - https://raw.github.com/sivel/speedtest-cli/master/speedtest_cli.py | python'

# vi: set syntax=bash
