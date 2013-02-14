
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                           #
#                        S C R I P T   H E L P E R S                        #
#                                                                           #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# This section lists functions often useful when writing scripts, for your
# copy-paste convenience.  In particular, you probably do not want to call
# die() from a terminal session.

die() { echo "$0: $*" >&2 ; exit 1 ; }
warn() { echo "$0: WARNING: $*" >&2 ; }
info() { echo "$0: $*" >&2 ; }

# based on a post by ghostdog74
# http://stackoverflow.com/questions/2312762/compare-difference-of-two-arrays-in-bash
array_diff()
{
    awk -v a1="$1" -v a2="$2" 'BEGIN {
        m = split(a1, A1, " ")
        n = split(a2, t, " ")
        for (i = 1; i <= n; i++) {
            A2[t[i]]
        }
        for (j in A2) { print "\t" j ":" A2[j] "\n" }
        for (i = 1; i <= m; i++) {
            printf i": "A1[i]"\n"
            if ( ! (A1[i] in A2) ) {
                printf A1[i]" "
            }
        }
    }'
}


array_intersect()
# based on Ken Bertelson's response (2010 Oct 25) to:
# http://stackoverflow.com/questions/1063347/passing-arrays-as-parameters-in-bash
#
# Note the required calling convention:
# 
#   $ a1=( "one" "two" "three four" "five" "six" )
#   $ a2=( three four five six seven )
#   $ array_intersect a1[@] a2[@]
#   five six
#
# We are passing the NAMES of the arrays which exist in calling scope (& are
# thus inherited by our function) (the "[@]" evidently being part of the name
# of a bash array, not only a dereferencing syntax?)
#
# $1 then becomes the name we passed in: a1[@].  ${!x} is bash's "Inderection"
# mechanism; similar to Perl's ability to have "variable variables": 
#
#   perl -e '$name = "Ken"; $var = "name"; print "name is $$var\n";'
#
# see also: http://tldp.org/LDP/abs/html/arrays.html
{
    local ARR1=( "${!1}" )
    local ARR2=( "${!2}" )
    local COMMON=( )
    # ${!ARRAYNAME[@]} means "the indices of ARRAYNAME"
    for x in ${!ARR1[@]}; do
        for y in ${!ARR2[@]}; do
            #echo "$x $y comparing ${ARR1[x]} <-> ${ARR2[y]}" >&2
            if [ "${ARR1[x]}" == "${ARR2[y]}" ]; then
                COMMON=( "${COMMON[@]}" "${ARR2[y]}" )
            fi
        done
    done
    echo "${COMMON[@]}"
}

askpass()
# turn off echoing. ask for password twice.
# compare & re-prompt if passwords are different or empty
# use cmd subst to collect output:  NEW_PASS=$( askpass )
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

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                           #
#                          S H E L L   H E L P E R S                        #
#                                                                           #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# This section provides some helper functions to achieve common tasks from the
# command line.

search_and_replace()
# recurse through a directory structure replacing all instances of one string
# with another.  Avoids changing metadata files for many VCSs.  Most useful
# when working within a VCS-controlled directory, where you have access to
# diff tools to examine what has changed, and revert tools to undo unexpected
# changes.  relies on GNU sed's -i (in-place) option
{
    local search="$1";
    local replace="$2";
    local grepdir="${3:-$PWD}";
    ### grep -rl "$search" "$grepdir" | xargs -r sed -i -e "s#$search#$replace#g"
    # do not modify private version control files
    find "$grepdir" -type f -wholename '*/.svn/*' -wholename '*/.git/*' -wholename '*/CVS/*' -prune -exec sed -i -e "s#${search}#${replace}g" '{}' \;
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

lstree()
# heirarchically sorted long-format directory listing for all nodes in path
{
    local LSTREE_PATH="${1:-$PWD}"
    local NODES=( "$LSTREE_PATH" )
    # if realpath is not installed, an alternative is:
    # perl -MCwd -e 'print Cwd::realpath($ARGV[0])'
    if [ "" != "`which realpath`" ]; then
        if [ -L "$LSTREE_PATH" ]; then
            LSTREE_PATH="`realpath \"$LSTREE_PATH\" `"
            # if top-level is symlink, include both it & realpath dir in output
            NODES=( "${NODES[@]}" "$LSTREE_PATH" )
        else
            # any usefulness switching to realpath here?
            LSTREE_PATH="`realpath \"$LSTREE_PATH\" `"
        fi
    fi
    # starting @ the end of LSTREE_PATH, work backwards chopping off / as we go
    local LSTREE_LHS= ; local LSTREE_RHS=
    while [ "$LSTREE_PATH" != "" ]
    do
        # LSTREE_PATH = /home/kenneth/clients/kenneth/perl5lib
        LSTREE_LHS="${LSTREE_PATH%/*}"
        LSTREE_RHS="${LSTREE_PATH#$LSTREE_LHS}${LSTREE_RHS}"
        # LHS is /home/kenneth/clients/kenneth ; RHS is /perl5lib
        if [ "$LSTREE_LHS" != "" ]; then
            NODES=( "${NODES[@]}" "$LSTREE_LHS" )
        fi
        LSTREE_PATH="$LSTREE_LHS"
    done
    NODES=( "${NODES[@]}" "/" )
    ls -ldU "${NODES[@]}"
}

# checksums files in two directories.
# considers filename and checksum only.
# files with differences will be listed with size & timestamp.
dircmp()
{
    local DIR1="$1"
    local DIR2="$2"
    # export into your env to use sha*sum, etc..
    local DIRCMP_CHKSUM="${DIRCMP_CHKSUM:-md5sum}"
    # check required args
    if [ -z "$DIR1" ] || [ -z "$DIR2" ]; then
        echo -e "dircmp: need 2 args.\n\t$DIR1\n\t$DIR2" >&2
        return 0
    fi
    # check directories exist
    if [ ! -d "$DIR1" ] || [ ! -d "$DIR2" ]; then
        echo "dircmp: both args must be directories" >&2
        ls -ld "$DIR1" "$DIR2" >&2
        return 0
    fi
    # list filenames only
    local DIR1_LS=( $( ls -1 "$DIR1" | sort ) )
    local DIR2_LS=( $( ls -1 "$DIR2" | sort ) )
    # comparing lists of both dirs, sort each file into one of:
    local DIR1_ONLY=( array_diff "$DIR1_LS" "$DIR2_LS" )
    local DIR2_ONLY=( array_diff "$DIR2_LS" "$DIR1_LS" )
    local BOTH=( )
    # 
}

