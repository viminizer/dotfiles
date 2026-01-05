#!/bin/sh

CPU=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')

# Cap at 100 for display
if [ "$CPU" -gt 100 ]; then
  CPU=100
fi

sketchybar --set "$NAME" label="${CPU}%"
