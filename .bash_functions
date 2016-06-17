
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

in_array()
# NOTE this does not actually work on an array!
# I could not figure out how to pass an array as a parameter, and instead am
# passing "${ARRAYNAME[@]}", which explodes the array into separate parameters
# of each element.  All this function does, then, is test whether the first
# parameter matches any of the remaining parameters
{
    local needle="$1"
    shift
    local haystack=("$@")
    # i is assigned to each VALUE in turn... not KEY
    for i in "${haystack[@]}"; do
        if [ "$needle" = "$i" ]; then
            return 0
        fi
    done
    # not found 
    return 1
}

array_diff()
# returns elements in arr1 but not in arr2
#
# order is not important, repeated elements are not accounted for
#
# Note the required calling convention (no $, no {}), see comments for
# array_intersect for explanation:
# 
#   $ a1=( "one" "two" "three four" "five" "six" )
#   $ a2=( three four five six seven )
#   $ array_diff a1[@] a2[@]
#   "one" "two" "three four"
#
# KNOWN BUG:
#
# The last line of this function echos values with correct quoting:
#
#   ++ echo one two 'three four'
#
# but recipient doesn't receive it that way:
# 
#   $ for x in $( array_diff a1[@] a2[@] ) ; do echo $x ; done 
#   one
#   two
#   three
#   four
# 
# no IFS tricks seem to provide a workaround
#
#   for x in $( IFS=$'\n' array_diff a1[@] a2[@] ) ; do echo $x ; done
{
    local ARR1=( "${!1}" )
    local ARR2=( "${!2}" )
    local UNIQ=( )
    # ${!ARRAYNAME[@]} means "the indices of ARRAYNAME"
    for x in "${!ARR1[@]}"; do
        for y in "${!ARR2[@]}"; do
            if [ "${ARR1[x]}" == "${ARR2[y]}" ]; then
                # done with y... move on to next x
                continue 2
            fi
        done
        UNIQ=( "${UNIQ[@]}" "${ARR1[x]}" )
    done
    echo "${UNIQ[@]}"
}

array_intersect()
# based on Ken Bertelson's response (2010 Oct 25) to:
# http://stackoverflow.com/questions/1063347/passing-arrays-as-parameters-in-bash
#
# Note the required calling convention (no $, no {}):
# 
#   $ a1=( "one" "two" "three four" "five" "six" )
#   $ a2=( three four five six seven )
#   $ array_intersect a1[@] a2[@]
#   five six
#
# We are passing the NAMES of the arrays which exist in calling scope (& are
# thus accessible by our function)
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
    ## find "$grepdir" -type f -wholename '*/.svn/*' -wholename '*/.git/*' -wholename '*/CVS/*' -prune -exec sed -i -e "s#${search}#${replace}g" '{}' \;
    find "$grepdir" -wholename './.git*' -o -wholename '*/.svn*' -o -wholename '*/CVS*'  -prune  -o -type f -a -exec sed -i -e "s#${search}#${replace}#g" '{}' \;
}

# credit for the following sed script goes to:
# Michael Paoli Michael.Paoli at cal.berkeley.edu
# http://linuxmafia.com/pipermail/sf-lug/2013q1/009829.html
webpeek()
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
# heirarchically sorted long-format directory listing for all directory nodes in path
# handy for checking permissions/ownership on a directory heirarchy
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
# files with differences will be listed with size & timestamp in status report.
# prints status report to STDERR, returns 0 if everything checks out or 1.
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
    local DIR1_ONLY=( $( array_diff DIR1_LS[@] DIR2_LS[@] ) )
    local DIR2_ONLY=( $( array_diff DIR2_LS[@] DIR1_LS[@] ) )
    local BOTH=( $( array_intersect DIR1_LS[@] DIR2_LS[@] ) )
    # dirs are the same?
    local OK=True
    if [ -z "${DIR1_ONLY[@]}" ]; then
        OK=False
        for f in "${DIR1_ONLY[@]}"; do
            echo " < $f only in $DIR1" >&2
        done
    fi
    if [ -z "${DIR2_ONLY[@]}" ]; then
        OK=False
        for f in "${DIR2_ONLY[@]}"; do
            echo " > $f only in $DIR2" >&2
        done
    fi
    local DIR1_HASH= ; local DIR2_HASH=
    for f in "${BOTH[@]}"; do
        echo -n "   $f ... " >&2
        # md5sum & shaXXXsum alike print: HASH FILENAME
        DIR1_HASH=$( "$DIRCMP_CHKSUM" "$DIR1/$f" | awk '{print $1}' )
        DIR2_HASH=$( "$DIRCMP_CHKSUM" "$DIR2/$f" | awk '{print $1}' )
        if [ "$DIR1_HASH" != "$DIR2_HASH" ]; then
            OK=False
            echo "FAIL" >&2 # newline
            ls -l "$DIR1/$f" "$DIR2/$f" >&2
        else
            echo "ok" >&2 # newline
        fi
    done
    # return boolean
    if [ "$OK" = "False" ]; then
        return 1
    fi
    return 0
}

gg()
{
    local SEARCH="$1"
    local ARGS="rIn"
    local CASE_SENSITIVE="False"
    for arg ; do
        if [ x"$arg" = xexact ]; then
            # case-ensitive + word boundaries
            CASE_SENSITIVE="True"
            SEARCH="\b${SEARCH}\b"
            ARGS="${ARGS}E"
        else
            if [ x"$arg" = xcase ]; then
                CASE_SENSITIVE="True"
            fi
            # word boundaries?
            if [ x"$arg" = xword ]; then
                SEARCH="\b${SEARCH}\b"
                ARGS="${ARGS}E"
            fi
        fi
    done
    if [ "$CASE_SENSITIVE" = "False" ]; then
        ARGS="${ARGS}i"
    fi
    grep --exclude-dir=.git --exclude-dir=build --exclude-dir=dist --exclude-dir=include --exclude-dir=lib --exclude-dir=local --exclude-dir=man --exclude=tags -"${ARGS}"  "${SEARCH}"  |  less -XS
}

# vi: set syntax=bash
