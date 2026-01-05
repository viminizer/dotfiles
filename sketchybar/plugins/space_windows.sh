#!/bin/bash

if [ "$SENDER" = "aerospace_monitor_change" ]; then
  sketchybar --set space."$FOCUSED_WORKSPACE" display="$TARGET_MONITOR"
  exit 0
fi

# Helper function to update a workspace's icons
update_workspace() {
  local sid="$1"
  local apps=$(aerospace list-windows --workspace "$sid" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
  if [ "${apps}" != "" ]; then
    sketchybar --set space.$sid drawing=on
    local icon_strip=" "
    while read -r app; do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
    done <<<"${apps}"
    sketchybar --set space.$sid label="$icon_strip"
  else
    # Hide empty workspaces (except focused)
    if [ "$sid" != "$FOCUSED_WORKSPACE" ]; then
      aerospace move-workspace-to-monitor --workspace "$sid" 1 2>/dev/null
      sketchybar --set space.$sid drawing=off display=1
    else
      sketchybar --set space.$sid label=""
    fi
  fi
}

# Get focused workspace if not provided by event
if [ -z "$FOCUSED_WORKSPACE" ]; then
  FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused)"
fi

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  # Update previous workspace
  if [ -n "$PREV_WORKSPACE" ]; then
    update_workspace "$PREV_WORKSPACE"
  fi
  # Update focused workspace
  update_workspace "$FOCUSED_WORKSPACE"
  # Always show focused workspace
  sketchybar --set space.$FOCUSED_WORKSPACE drawing=on
elif [ "$SENDER" = "front_app_switched" ] || [ "$SENDER" = "space_windows_change" ]; then
  # Update all non-empty workspaces when apps change
  for sid in $(aerospace list-workspaces --all); do
    update_workspace "$sid"
  done
  # Always show focused workspace
  sketchybar --set space.$FOCUSED_WORKSPACE drawing=on
fi
