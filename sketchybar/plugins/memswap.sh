#!/bin/sh

# Purple Custom colors
FG_MUTED="0xff444444"
YELLOW="0xffff000f"
RED="0xffff000f"

# `sysctl vm.swapusage` prints:
#   vm.swapusage: total = 7168.00M  used = 6148.25M  free = 1019.75M
#
# This read field 4, which is *total*: a constant that never moves. It then
# compared it against 0.00M, so on any machine with swap configured the item sat
# red forever and meant nothing. Field 7 is the one that says whether macOS is
# actually swapping.
USED="$(sysctl vm.swapusage | awk '{print $7}')"
[ -n "$USED" ] || exit 0

# The value carries an M or G suffix and sh cannot compare those, so let awk
# normalise to megabytes and pick the band.
LEVEL="$(echo "$USED" | awk '{ mb = $0 + 0; if (/G$/) mb *= 1024 }
  END { print (mb >= 4096) ? "high" : (mb >= 1024) ? "warn" : "ok" }')"

case "$LEVEL" in
  high) COLOR="$RED" ;;
  warn) COLOR="$YELLOW" ;;
  *) COLOR="$FG_MUTED" ;;
esac

sketchybar --set "$NAME" label="$USED" icon.color="$COLOR" label.color="$COLOR"
