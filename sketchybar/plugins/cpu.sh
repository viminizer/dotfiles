#!/bin/sh

# Purple Custom colors
YELLOW="0xffff000f"
GOLD="0xffff000f"
RED="0xffff000f"
FG="0xfffffaf3"

# This used to sum `ps -A -o %cpu`, but that column is each process's average
# over its whole lifetime, not what it is doing now. Summing it reported 92% on
# a machine that was 92% idle, and the result got capped at 100 so the number
# never looked obviously wrong.
#
# iostat measures the real thing. It takes two samples a second apart and sleeps
# in between, so the second of wall time costs about 1% of a core. `top -l 2` is
# the obvious alternative and it pegs a whole core for 1.4s, which at this
# update frequency would be worse than the bug.
#
# Columns are: <disk stats...> us sy id  load1 load5 load15. The number of disk
# columns depends on how many disks are attached, so count idle from the right.
IDLE=$(iostat -c 2 -w 1 | awk 'END { print $(NF - 3) }')

case "$IDLE" in
  '' | *[!0-9]*) exit 0 ;;
esac

CPU=$((100 - IDLE))

if [ "$CPU" -ge 80 ]; then
  ICON_COLOR="$RED"
  LABEL_COLOR="$RED"
elif [ "$CPU" -ge 50 ]; then
  ICON_COLOR="$GOLD"
  LABEL_COLOR="$GOLD"
else
  ICON_COLOR="$YELLOW"
  LABEL_COLOR="$FG"
fi

sketchybar --set "$NAME" \
  label="${CPU}%" \
  icon.color="$ICON_COLOR" \
  label.color="$LABEL_COLOR"
