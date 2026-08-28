#!/bin/sh

# Palette, rewritten by theme/apply.py
FG="0xfffffaf3"
RED="0xffff000f"

# This deliberately does not show the network name. macOS treats the SSID as
# location data, so `ipconfig getsummary` returns the literal string
# "<redacted>" to any process without Location Services authorization, and
# sketchybar cannot be granted it: the Location Services list only offers apps
# that request the permission themselves. macOS 26 also removed the `airport`
# utility and broke `networksetup -getairportnetwork`, which now reports
# "not associated" while online. The local IP is unrestricted and says the same
# thing that matters, which is whether the machine is actually on a network.
IFACE="${WIFI_IFACE:-en0}"

case "$(ifconfig "$IFACE" 2>/dev/null)" in
  *"status: active"*) ;;
  *) sketchybar --set "$NAME" icon="󰖪" icon.color="$RED" \
       label="off" label.color="$RED"
     exit 0 ;;
esac

IP="$(ipconfig getifaddr "$IFACE" 2>/dev/null)"

# Associated but no address yet: DHCP is still going, or the link is captive.
if [ -z "$IP" ]; then
  sketchybar --set "$NAME" icon="󰖩" icon.color="$RED" \
    label="no ip" label.color="$RED"
  exit 0
fi

sketchybar --set "$NAME" icon="󰖩" icon.color="$FG" \
  label="$IP" label.color="$FG"
