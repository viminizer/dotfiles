#!/bin/sh

# Argonaut colors
FG="0xfffffaf3"
RED="0xffff000f"

# macOS 26 removed the `airport` utility, and `networksetup -getairportnetwork`
# now answers "You are not associated with an AirPort network" even while the
# machine is online, so neither of the usual approaches works here.
# `ipconfig getsummary` still reports the association, so read the SSID there.
IFACE="${WIFI_IFACE:-en0}"
SUMMARY="$(ipconfig getsummary "$IFACE" 2>/dev/null)"

# The key is padded and colon-separated: "  SSID : <name>". Take the first hit
# only; the summary repeats it once per configured network profile.
SSID="$(echo "$SUMMARY" | awk -F' SSID : ' '/ SSID : / { print $2; exit }')"

# Long network names would push the whole status group off the bar.
if [ "${#SSID}" -gt 14 ]; then
  SSID="$(echo "$SSID" | cut -c1-13)…"
fi

if [ -n "$SSID" ]; then
  sketchybar --set "$NAME" icon="󰖩" icon.color="$FG" label="$SSID" label.color="$FG"
else
  sketchybar --set "$NAME" icon="󰖪" icon.color="$RED" label="off" label.color="$RED"
fi
