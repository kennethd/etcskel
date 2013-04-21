# ~/.bash_profile will supercede ~/.profile if your login shell is bash
# if your shell is sh, it will look for this ~/.profile 
# your ~/.bash_profile explicitly sources this file so these settings work for both shells

# user's bin should be first in PATH, other HOME-based paths come immediately
# after (listed before here)
[ -d "$HOME/perl5/bin" ] && [ "$PATH" == "${PATH##$HOME/perl5/bin}" ] && PATH="$HOME/perl5/bin:$PATH"
[ -d "$HOME/bin" ] && [ "$PATH" == "${PATH##$HOME/bin}" ] && PATH="$HOME/bin:$PATH"
export PATH
# if using keychain set SSH env vars appropriately
[ -f "$HOME/.keychainrc" ] && . "$HOME/.keychainrc"
# PYTHONSTARTUP enables readline history in python interpreter
[ -f "$HOME/.pythonstartup" ] && PYTHONSTARTUP="$HOME/.pythonstartup"
export PYTHONSTARTUP
[ -d "$HOME/perl5/lib/perl5" ] && PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB"
[ -d "$HOME/perl5lib" ] && PERL5LIB="$HOME/perl5lib:$PERL5LIB"
export PERL5LIB
# if surfraw is available, add its shortcuts to PATH
# see `surfraw -elvi` for a list of commands
[ -d /usr/lib/surfraw ] && [ "$PATH" = "${PATH%%:/usr/lib/surfraw}" ] && export PATH="$PATH":/usr/lib/surfraw
SURFRAW_text_browser=/usr/bin/elinks
SURFRAW_graphical=no
# on some systems pinentry will not be able to prompt you without this
export GPG_TTY=`tty`
export EDITOR=vim
export PAGER=less
# still have a few clients using this
export CVS_RSH=ssh
