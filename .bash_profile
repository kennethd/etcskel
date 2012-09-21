# ~/.bash_profile: executed by bash(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples.
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# if surfraw is available, add its shortcuts to PATH
# see `surfraw -elvi` for a list of commands
[ -d /usr/lib/surfraw ] && [ "$PATH" = "${PATH%%:/usr/lib/surfraw}" ] && export PATH="$PATH":/usr/lib/surfraw
