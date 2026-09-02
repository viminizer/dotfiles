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
# Brewfile holds only what the tracked configs need. Everything else this
# machine happened to have is in Brewfile.extras, which is deliberately not
# installed here - pull it in by hand if you want it:
#   brew bundle install --file=~/.config/Brewfile.extras
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

# --- borders ---
# bordersrc is only read once the service runs, and nothing else starts it.
brew services restart borders

# --- keyboard ---
# Key repeat, in 15ms units. macOS ships 25/6 -- a 375ms wait and then 90ms a
# step, or about 11 lines a second, which is slow enough that holding j in vim
# feels broken rather than fast. 12/2 is 180ms then 30ms, about 33 a second.
#
# 2 is below what the System Settings slider can reach, so this cannot be done
# in the UI and does not survive as a slider position. Read back with
# `defaults read -g KeyRepeat`. Applications pick the value up when they next
# launch, so the shell you run this from keeps the old rate until restarted.
#
# 1 (15ms, ~66 a second) is the floor and overshoots: you aim for a line and
# land four past it. Note that the rate this *feels* like depends on kitty's
# cursor_trail -- with the trail firing on held keys, 2 felt sluggish and 1
# felt right, and both were the animation rather than the rate. Fix the trail
# before reaching for a faster repeat; see kitty/kitty.conf.
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 12

# --- wallpaper ---
# Tracked here rather than left in ~/Downloads, which is where macOS had been
# pointing at it. macOS stores only the path, so the file has to live somewhere
# permanent. Not fatal if it fails: the first run on a new machine may trip the
# Automation permission prompt for System Events.
osascript -e 'tell application "System Events" to tell every desktop to set picture to "'"$CONFIG_DIR"'/wallpaper/dodge-challenger-srt-demon-4k.jpg"' \
  || echo "could not set the wallpaper, allow System Events under Privacy > Automation and re-run"

cat <<'MANUAL'

done. two things no script can do for you:
  - grant AeroSpace accessibility permission in System Settings
  - start tmux and press prefix + I to install its plugins
MANUAL
