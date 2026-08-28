#!/bin/sh
# Prints the current branch for the pane's directory, or nothing at all.
#
# This used to be inline in status-right as an icon followed by `git branch
# --show-current`. Outside a repo git writes nothing to stdout, so the branch
# came back empty but the icon and its padding still rendered, leaving a lone
# glyph floating in the status bar.

pane_path=${1:-}
[ -n "$pane_path" ] || exit 0

branch=$(cd "$pane_path" 2>/dev/null && git branch --show-current 2>/dev/null)
[ -n "$branch" ] || exit 0

printf '#[fg=#46bdff]  %s ' "$branch"
