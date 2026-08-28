#!/bin/sh

pane_path=${1:-}
repo_root=$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null) || exit 0
branch=$(git -C "$repo_root" branch --show-current 2>/dev/null)
[ -n "$branch" ] || exit 0

cache_dir="${TMPDIR:-/tmp}/tmux-pr-status"
mkdir -p "$cache_dir" 2>/dev/null || exit 0
cache_key=$(printf 'v2\n%s\n%s' "$repo_root" "$branch" | shasum -a 256 | cut -d ' ' -f 1)
cache_file="$cache_dir/$cache_key"
now=$(date +%s)

if [ -f "$cache_file" ]; then
  modified=$(stat -f %m "$cache_file" 2>/dev/null || printf '0')
  if [ $((now - modified)) -lt 60 ]; then
    cat "$cache_file"
    exit 0
  fi
fi

pr_data=$(cd "$repo_root" && gh pr list \
  --head "$branch" \
  --state open \
  --limit 1 \
  --json number,isDraft \
  --jq '.[0] // empty | "\(.number) \(.isDraft)"' 2>/dev/null)

if [ -n "$pr_data" ]; then
  pr_number=${pr_data%% *}
  is_draft=${pr_data#* }

  if [ "$is_draft" = "true" ]; then
    printf '#[fg=#9ccfd8]│ PR #%s (draft) ' "$pr_number" > "$cache_file"
  else
    printf '#[fg=#66aeca]│ PR #%s ' "$pr_number" > "$cache_file"
  fi
else
  : > "$cache_file"
fi

cat "$cache_file"
