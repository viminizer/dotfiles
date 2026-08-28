#!/bin/bash
# Sets up this checkout on a fresh machine. Safe to re-run.
#
#   git clone <repo> ~/.config && bash ~/.config/install.sh
#
# Most tools here read ~/.config directly, so cloning to the right place is most
# of the work. This covers the parts cloning cannot: the packages, the one
# symlink zsh needs, and tmux's plugin manager.
set -euo pipefail

CONFIG_DIR="$HOME/.config"

command -v brew >/dev/null || { echo "install homebrew first: https://brew.sh"; exit 1; }

# --- packages ---
# Regenerate with: brew bundle dump --file=Brewfile --force
brew bundle install --file="$CONFIG_DIR/Brewfile"

# --- zsh ---
# zsh only ever reads ~/.zshrc, so the tracked copy needs a link pointing at it.
# The link is the easy thing to forget: without it a fresh clone looks complete
# but silently runs stock zsh.
if [ -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.pre-dotfiles"
  echo "kept your existing ~/.zshrc as ~/.zshrc.pre-dotfiles"
fi
ln -sfn "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"

# --- tmux ---
# This path has to match TMUX_PLUGIN_MANAGER_PATH at the bottom of tmux.conf.
# The plugins themselves are gitignored, so install them with prefix + I once
# tmux is running.
if [ ! -d "$CONFIG_DIR/tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$CONFIG_DIR/tmux/plugins/tpm"
fi

# --- sketchybar ---
# Pulls the app icon font and registers the launchd service.
bash "$CONFIG_DIR/sketchybar/install.sh"

cat <<'MANUAL'

done. two things no script can do for you:
  - grant AeroSpace accessibility permission in System Settings
  - start tmux and press prefix + I to install its plugins
MANUAL
