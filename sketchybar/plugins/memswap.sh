#!/bin/sh

# Tokyo Night colors
FG_MUTED="0xff565f89"
RED="0xfff7768e"

TOTALSWAP="$(sysctl vm.swapusage | awk '{print $4}')"

if [ "$TOTALSWAP" != "0.00M" ]; then
  sketchybar --set "$NAME" label="$TOTALSWAP" icon.color="$RED" label.color="$RED"
else
  sketchybar --set "$NAME" label="$TOTALSWAP" icon.color="$FG_MUTED" label.color="$FG_MUTED"
fi
