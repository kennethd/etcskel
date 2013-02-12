
askpass()
# turn off echoing. ask for password twice.
# compare & re-prompt if passwords are different or empty
# use cmd subst to collect output:  NEW_PASS=$( getpass )
{
    # http://billharlan.com/pub/papers/Bourne_shell_idioms.html
    # Here's how to ask for a password without echoing the characters.
    # The trapping ensures that an interrupt does not leave echo off
    stty -echo
    trap "stty echo ; echo 'Interrupted' ; exit 1" 1 2 3 15
    echo -n "Please enter a password: "
    read password1
    echo "" # newline
    echo -n "Please re-enter the password: "
    read password2
    echo "" # newline
    stty echo
    # check for empty password
    if [ -z "$password1" ]; then
        echo "Error: Password cannot be empty" >&2
        getpass
    elif [ "$password1" = "$password2" ]; then
        echo "$password1"
        return 0
    else
        echo "Error: Passwords do not match" >&2
        getpass
    fi
}

search_and_replace()
# relies on GNU sed's -i (in-place) option
{
    local search="$1";
    local replace="$2";
    local grepdir="${3:-$PWD}";
    ### grep -rl "$search" "$grepdir" | xargs -r sed -i -e "s#$search#$replace#g"
    # do not modify private version control files
    find "$grepdir" -type f -wholename '*/.svn/*' -wholename '*/.git/*' -wholename '*/CVS/*' -prune -exec sed -i -e "s#${search}#${replace}g" '{}' \;
}

yes_or_no()
# prompt user for a y/n response
{
    local prompt="${1:-Continue}"
    # `read -p` seems to have some problems over ssh... use `echo -n` && `read`
    echo -n "$prompt? (y/n): "
    read yn
    echo '' # newline
    # to allow answers 'Yes' & 'No' as well, only examine the
    # 1st character of the string returned
    yn="${yn:0:1}"
    if [ "$yn" = 'y' ] || [ "$yn" = 'Y' ]; then
        return 0
    elif [ "$yn" = 'n' ] || [ "$yn" = 'N' ]; then
        return 1
    else
        echo "Please answer 'y' or 'n'" >&2
        yes_or_no "$prompt"
    fi
}

# credit for the following sed script goes to:
# Michael Paoli Michael.Paoli at cal.berkeley.edu
# http://linuxmafia.com/pipermail/sf-lug/2013q1/009829.html
peek()
{
    URL="$1"
    st=$(printf '\040\007') # space and tab
    lynx -dump "$URL" |
    sed -ne \
    '
         :t
         /^['"$st"']*[^'"$st"']/,/^['"$st"']*$/{
             # first "real" paragraph and blank line
             p
             /^['"$st"']*$/{
                 b n
             }
         }
         n
         b t
         :n
         /^['"$st"']*$/{
             # skip blank lines
             n
             b n
         }
         :2
         # 2nd real paragraph
         p
         n
         /^['"$st"']*$/!b 2
         q
    '
}


