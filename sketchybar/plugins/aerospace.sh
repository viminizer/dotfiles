#!/usr/bin/env bash

# Tokyo Night colors
FOCUSED_BG="0xff3d59a1"
FOCUSED_FG="0xffc0caf5"
UNFOCUSED_BG="0xff292e42"
UNFOCUSED_FG="0xffc0caf5"
ACCENT="0xff7aa2f7"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" \
    background.color=$FOCUSED_BG \
    background.height=22 \
    icon.color=$FOCUSED_FG \
    label.color=$FOCUSED_FG \
    background.border_color=$ACCENT \
    background.border_width=1
else
  sketchybar --set "$NAME" \
    background.color=$UNFOCUSED_BG \
    background.height=22 \
    icon.color=$UNFOCUSED_FG \
    label.color=$UNFOCUSED_FG \
    background.border_width=0
fi
