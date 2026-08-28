#!/bin/bash
# Sets up the bar on a fresh machine. Safe to re-run.
#
#   bash ~/.config/sketchybar/install.sh
#
# sketchybar reads ~/.config/sketchybar/sketchybarrc by default, so cloning the
# dotfiles into ~/.config is all the linking this needs.
set -euo pipefail

command -v brew >/dev/null || { echo "install homebrew first: https://brew.sh"; exit 1; }

brew tap FelixKratz/formulae
# Recent homebrew refuses to run services from third-party taps until trusted.
brew trust felixkratz/formulae
brew install sketchybar

# AeroSpace drives the workspace items, so the bar is useless without it.
brew install --cask nikitabobko/tap/aerospace

# "SF Pro" and "Hack Nerd Font" are named in sketchybarrc.
brew install --cask font-sf-pro font-hack-nerd-font

# The per-app glyphs. Not in homebrew, so pull the release artifact directly.
mkdir -p "$HOME/Library/Fonts"
curl -fsSL -o "$HOME/Library/Fonts/sketchybar-app-font.ttf" \
  https://github.com/kvndrsslr/sketchybar-app-font/releases/latest/download/sketchybar-app-font.ttf

# Run it under launchd rather than as a child of AeroSpace, so it comes back by
# itself if it crashes instead of leaving you with no bar until the next reboot.
brew services restart sketchybar

echo "done. open AeroSpace to finish wiring up the workspace items."
