#!/bin/sh

# Lays the focused workspace out as two columns, picked by window count:
#
#   2: [A|B]   3: A | B/C   4: A/B | C/D   5: A/B/C | D/E
#
# AeroSpace has no layout that follows the window count, so this rebuilds the
# tree from flat each time. Run from on-window-detected and from alt-g;
# AeroSpace has no window-closed hook, so after closing one, alt-g tidies up.

focused=$(aerospace list-windows --focused --format '%{window-id}') || exit 0
total=$(aerospace list-windows --workspace focused --count)

aerospace flatten-workspace-tree
aerospace layout --root h_tiles

# list-windows sorts by app name, not by position, and join-with/move need to
# know who sits next to whom. Walking --dfs-index gives the on-screen order.
# Floating windows are in that walk too, so they are skipped here, not counted.
ids=
i=0
while [ "$i" -lt "$total" ]; do
    aerospace focus --dfs-index "$i"
    ids="$ids $(aerospace list-windows --focused --format '%{window-id} %{window-layout}' |
        awk '$2 != "floating" { print $1 }')"
    i=$((i + 1))
done
set -- $ids
n=$#
nth() { echo $ids | cut -d' ' -f"$1"; }

# Left column size: half, rounded up, except 3, which is one big window on the
# left and two stacked on the right.
if [ "$n" -eq 3 ]; then left=1; else left=$(((n + 1) / 2)); fi

# Turn windows first..last of the row into one vertical column: join the
# first two, then move the rest in. join-with on a third window would wrap the
# column in a new container instead, and normalization would flip it sideways.
column() {
    [ "$2" -gt "$1" ] || return 0
    aerospace join-with --window-id "$(nth $(($1 + 1)))" left
    j=$(($1 + 2))
    while [ "$j" -le "$2" ]; do
        aerospace move --window-id "$(nth "$j")" left
        j=$((j + 1))
    done
}

if [ "$n" -gt 2 ]; then
    column 1 "$left"
    column $((left + 1)) "$n"
fi

aerospace balance-sizes
aerospace focus --window-id "$focused"
