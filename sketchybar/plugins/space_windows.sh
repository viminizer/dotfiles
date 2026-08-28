#!/bin/bash
# Redraws every workspace item in one pass: app icons, which monitor the
# workspace lives on, empty/focused visibility, and the focus highlight.
#
# This deliberately refreshes everything rather than trying to patch individual
# workspaces, because a full refresh costs two `aerospace` calls and one batched
# `sketchybar` call. Asking aerospace about each workspace separately was ~10x
# slower, and patching single workspaces meant the ones you left went stale.

source "$CONFIG_DIR/plugins/icon_map_fn.sh"

FOCUSED_BG=0xffbd2523
UNFOCUSED_BG=0xff2e343c
ACCENT=0xfffb9435

workspaces=$(aerospace list-workspaces --all --format '%{workspace}|%{monitor-appkit-nsscreen-screens-id}')
windows=$(aerospace list-windows --all --format '%{workspace}|%{app-name}')
focused=${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}

# bash 3.2 on macOS has no associative arrays, so the icon strips are built by
# scanning the window list per workspace. It stays in-process, so it's cheap.
args=()
while IFS='|' read -r sid mid; do
  [ -n "$sid" ] || continue

  strip=""
  while IFS='|' read -r wsid app; do
    [ "$wsid" = "$sid" ] || continue
    icon_map "$app"
    strip="$strip $icon_result"
  done <<<"$windows"

  # An empty workspace only earns a slot in the bar while it's the focused one.
  if [ -n "$strip" ] || [ "$sid" = "$focused" ]; then
    drawing=on
  else
    drawing=off
  fi

  args+=(--set "space.$sid" drawing=$drawing display="$mid" label="$strip")
  if [ "$sid" = "$focused" ]; then
    args+=(background.color=$FOCUSED_BG background.border_color=$ACCENT background.border_width=1)
  else
    args+=(background.color=$UNFOCUSED_BG background.border_width=0)
  fi
done <<<"$workspaces"

sketchybar "${args[@]}"
