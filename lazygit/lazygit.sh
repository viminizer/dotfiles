#!/bin/sh
# Open lazygit. If the current folder isn't a git repo, pick one of the repos
# below it instead. Used by both the `lazygit` zsh function and the tmux popup,
# so keep it POSIX sh and dependency-light.
#
# Requires: lazygit, fd, fzf   (brew install lazygit fd fzf)
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

config="$HOME/.config/lazygit/config.yml"

# On macOS lazygit reads its config from Application Support, not ~/.config.
# Link it on first run so a plain `lazygit` outside this script behaves too.
support="$HOME/Library/Application Support/lazygit"
# Links when it's missing or the empty stub lazygit writes itself; never
# touches a config.yml that actually has something in it.
if [ -d "$HOME/Library" ] && [ ! -L "$support/config.yml" ] && [ ! -s "$support/config.yml" ]; then
  mkdir -p "$support"
  ln -sfn "$config" "$support/config.yml"
fi

if git rev-parse --git-dir >/dev/null 2>/dev/null; then
  exec lazygit --use-config-file "$config" "$@"
fi

repo=$(fd -H -t d -d "${LG_SCAN_DEPTH:-3}" --prune '^\.git$' \
  | sed 's|/\.git/$||' \
  | fzf --prompt='repo > ' --reverse --no-multi --header='No repo here. Pick one:')

[ -z "$repo" ] && exit 1
exec lazygit --use-config-file "$config" -p "$repo" "$@"
