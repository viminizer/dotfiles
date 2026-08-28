#!/bin/bash

if [ "$SENDER" = "front_app_switched" ]; then
  source "$CONFIG_DIR/plugins/icon_map_fn.sh"
  icon_map "$INFO"
  sketchybar --set "$NAME" label="$INFO" icon="$icon_result"
fi
