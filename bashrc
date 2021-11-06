#   When you use `./Test -i`, this .bashrc is is run when the container
#   goes into interactive mode.

set -o vi

lf()            { ls -CF "$@"; }
lfa()           { lf -a "$@"; }
ll()            { ls -lh "$@"; }
lla()           { ll -a "$@"; }
llt()           { ll -t "$@"; }
llth()          { ll -t "$@" | head; }

findf() {
    [ -z "$1" ] && {
        echo 1>&2 "Usage: findf DIR ... [NAME-FRAGMENT [FIND-OPS ...]]"
        return 2;
    }
    local roots=() namefrag
    #   -d is true for symlinks to dirs as well as directories.
    while [[ -d "$1" ]]; do roots+=("$1"); shift; done
    local name_frag="$1"; shift
    [[ -z $name_frag && ${#roots[@]} -gt 1 ]] \
        && { echo 1>&2 "Warning: last arg is a dir, not name-frag"; sleep 1; }
    [[ $name_frag == -- ]] && { name_frag="$1"; shift; }
    local predicate=-iname
    [[ $name_frag =~ / ]] && predicate=-ipath
    find -L "${roots[@]}" -type f $predicate "*$name_frag*" "$@" 2>/dev/null
}

