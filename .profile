# ~/.bash_profile will supercede ~/.profile if your login shell is bash
# if your shell is sh, it will look for this ~/.profile 
# your ~/.bash_profile explicitly sources this file so these settings work for both shells

# the default umask is set in /etc/login.defs
#umask 022
[ -d "$HOME/bin" ] && [ "$PATH" == "${PATH##$HOME/bin}" ] && export PATH="$HOME/bin:$PATH"
[ -f "$HOME/.keychainrc" ] && . "$HOME/.keychainrc"
[ -f "$HOME/.pythonstartup" ] && export PYTHONSTARTUP="$HOME/.pythonstartup"
[ -d "$HOME/perl5lib" ] && export PERL5LIB="$HOME/perl5lib:$PERL5LIB"
# if surfraw is available, add its shortcuts to PATH
# see `surfraw -elvi` for a list of commands
[ -d /usr/lib/surfraw ] && [ "$PATH" = "${PATH%%:/usr/lib/surfraw}" ] && export PATH="$PATH":/usr/lib/surfraw
SURFRAW_text_browser=/usr/bin/elinks
SURFRAW_graphical=no
# on some systems pinentry will not be able to prompt you without this
export GPG_TTY=`tty`
# never use nano
export EDITOR=vim
export PAGER=less
# still have a few clients using this
export CVS_RSH=ssh
