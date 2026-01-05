#!/bin/sh

PLUGIN_DIR="$CONFIG_DIR/plugins"

if [ "$SENDER" = "front_app_switched" ]; then
  icon="$($PLUGIN_DIR/icon_map_fn.sh "$INFO")"
  sketchybar --set "$NAME" label="$INFO" icon="$icon"
fi
