#!/bin/sh

# Purple Custom colors
GREEN="0xff22c55e"
YELLOW="0xfffacc15"
RED="0xfff87171"
FG="0xffe2e0e7"

# One pmset call, not two. `[0-9]` rather than `\d`, which is a PCRE escape that
# only happens to work because macOS grep is lenient about it.
BATT="$(pmset -g batt)"
PERCENTAGE="$(echo "$BATT" | grep -Eo "[0-9]+%" | head -1 | cut -d% -f1)"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "$BATT" in
  *"AC Power"*) CHARGING=1 ;;
  *) CHARGING=0 ;;
esac

case "${PERCENTAGE}" in
  9[0-9]|100) ICON=""
  ;;
  [6-8][0-9]) ICON=""
  ;;
  [3-5][0-9]) ICON=""
  ;;
  [1-2][0-9]) ICON=""
  ;;
  *) ICON=""
esac

if [ "$CHARGING" = 1 ]; then
  ICON=""
  ICON_COLOR="$GREEN"
  LABEL_COLOR="$FG"
elif [ "$PERCENTAGE" -le 20 ]; then
  # The icon was hardcoded green, so a nearly flat battery looked healthy.
  ICON_COLOR="$RED"
  LABEL_COLOR="$RED"
elif [ "$PERCENTAGE" -le 40 ]; then
  ICON_COLOR="$YELLOW"
  LABEL_COLOR="$FG"
else
  ICON_COLOR="$GREEN"
  LABEL_COLOR="$FG"
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  icon.color="$ICON_COLOR" \
  label="${PERCENTAGE}%" \
  label.color="$LABEL_COLOR"
