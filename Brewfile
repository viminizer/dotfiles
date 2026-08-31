# The packages the configs in this repo actually need. install.sh installs these.
#
# Every entry here is referenced by a tracked config file, so dropping one breaks
# something visible. The rest of what this machine happens to have lives in
# Brewfile.extras and is not installed by default.

tap "felixkratz/formulae", "https://github.com/FelixKratz/homebrew-formulae", trusted: true
tap "nikitabobko/tap"

# --- shell: zsh/.zshrc ---
# Fish-like fast/unobtrusive autosuggestions for zsh
brew "zsh-autosuggestions"
# Theme for zsh
brew "powerlevel10k"
# Shell extension to navigate your filesystem faster
brew "zoxide"
# Command-line fuzzy finder written in Go
brew "fzf"
# Simple, fast and user-friendly alternative to find
brew "fd"
# Clone of cat(1) with syntax highlighting and Git integration
brew "bat"
# Modern, maintained replacement for ls
brew "eza"
# Render markdown on the CLI
brew "glow"
# Tool for glamorous shell scripts
brew "gum"
# Display directories as trees (with optional color/HTML output)
brew "tree"
# Manage multiple Node.js versions
brew "nvm"

# --- git: zsh/.zshrc, lazygit/, nvim ---
# Distributed revision control system
brew "git"
# Syntax-highlighting pager for git and diff output
brew "git-delta"
# Simple terminal UI for git commands
brew "lazygit"
# GitHub command-line tool. tmux/scripts/pr-status.sh shells out to this.
brew "gh"

# --- tmux popups: tmux/tmux.conf ---
# Terminal multiplexer
brew "tmux"
# Lazier way to manage everything docker
brew "lazydocker"
# Cross-platform TUI database management tool
brew "lazysql"
# Blazing fast terminal file manager written in Rust, based on async I/O
brew "yazi"

# --- editor: nvim/ ---
# Ambitious Vim-fork focused on extensibility and agility
brew "neovim"
# Search tool like grep and The Silver Searcher. Backs the nvim pickers.
brew "ripgrep"

# --- desktop: aerospace/, sketchybar/, borders/ ---
# Custom macOS statusbar with shell plugin, interaction and graph support
brew "felixkratz/formulae/sketchybar"
# A window border system for macOS
brew "felixkratz/formulae/borders"
cask "aerospace"
# Keyboard customiser
cask "karabiner-elements"

# --- terminal + fonts ---
# GPU-based terminal emulator
cask "kitty"
# Named in sketchybarrc
cask "font-sf-pro"
cask "font-hack-nerd-font"
# What powerlevel10k's glyphs are drawn with
cask "font-meslo-lg-nerd-font"

# --- AI CLIs: aliased in zsh/.zshrc ---
# Terminal-based AI coding assistant
cask "claude-code"
# OpenAI's coding agent that runs in your terminal
cask "codex"

# --- java: zsh/.zshrc:97, nvim/lua/plugins/java.lua ---
# .zshrc asks java_home for 21 specifically. It must be a cask, not the openjdk
# formula: only casks install into /Library/JavaVirtualMachines, which is the
# only place /usr/libexec/java_home looks.
#
# Temurin over Zulu or Oracle: same JVM, but GPLv2+CE with no vendor terms that
# can change, and it is what the eclipse-temurin images most CI and deploys run
# on, so local matches prod.
cask "temurin@21"
# jdtls is tuned for multi-module Maven projects
brew "maven"
