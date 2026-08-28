#!/bin/sh

# Shows which AeroSpace mode you are in, but only while you are somewhere other
# than main, so the bar stays clean the rest of the time. Without this, alt-r
# silently rebinds hjkl to resize with nothing on screen to say so.
#
# AeroSpace has no mode-change event, so the bindings in aerospace.toml trigger
# this themselves. Every binding that leaves a mode has to send MODE=main, or
# the indicator sticks.

if [ -z "$MODE" ] || [ "$MODE" = "main" ]; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on label="$MODE"
fi
