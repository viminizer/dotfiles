[[ ! -o interactive ]] && return
# =========================================================
# ZSHRC — optimized for speed
# =========================================================
#
# DEPENDENCIES (install on new machine):
#   brew install zsh-autosuggestions fzf fd zoxide powerlevel10k glow bat git-delta gum eza lazygit
#
# =========================================================

setopt NO_BEEP

# -------------------------
# History
# -------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# -------------------------
# Completion (cached)
# -------------------------
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# -------------------------
# Homebrew prefix
# -------------------------
# Apple Silicon puts brew in /opt/homebrew, Intel in /usr/local. Hardcoding
# either one makes the plugins below silently not load on the other machine.
# A directory test rather than `brew --prefix`, which would cost a subprocess
# on every shell start.
if [[ -d /opt/homebrew ]]; then
  HOMEBREW_PREFIX=/opt/homebrew
else
  HOMEBREW_PREFIX=/usr/local
fi
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# -------------------------
# Plugins
# -------------------------
# Autosuggestions (fish-style, accept with Tab or →)
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"


# zoxide (use 'cd' to jump to directories, e.g., 'cd proj')
eval "$(zoxide init zsh --cmd cd 2>/dev/null)"

# -------------------------
# Color / display
# -------------------------
export CLICOLOR=1
export COLORTERM=truecolor
export BAT_THEME="Catppuccin Macchiato"
export BAT_STYLE="plain"
export BAT_PAGER="less -FR"
export LESS="-R"
export MANPAGER='sh -c "col -bx | bat -l man -p"'

md() {
  if (( $# == 0 )); then
    glow -
  else
    glow "$@"
  fi
}

ai() {
  if (( $# == 0 )); then
    glow -
    return
  fi

  "$@" | glow -
  return ${pipestatus[1]}
}

alias cat='bat --paging=never --style=plain'
alias diff='delta'
alias ls='eza --group-directories-first'
alias la='eza -la --group-directories-first'
alias ll='eza -lah --group-directories-first --git'
alias tree='eza --tree --group-directories-first --level=2'
alias danger='claude --dangerously-skip-permissions'

# -------------------------
# Java
# -------------------------
# 2>/dev/null so a machine without a 21 JDK gets an empty JAVA_HOME rather
# than an error on every shell start.
export JAVA_HOME=$(/usr/libexec/java_home -v 21 2>/dev/null)
# -------------------------
# Claude Code CLI
# -------------------------
export PATH="$HOME/.local/bin:$HOME/.claude/local/bin:$PATH"

# -------------------------
# Powerlevel10k
# -------------------------
[ -f "$HOMEBREW_PREFIX/opt/powerlevel10k/share/powerlevel10k/powerlevel10k.zsh-theme" ] && \
  source "$HOMEBREW_PREFIX/opt/powerlevel10k/share/powerlevel10k/powerlevel10k.zsh-theme"
# Tracked in this repo, so a new machine gets this prompt instead of the setup
# wizard. p10k rewrites whichever file it was sourced from, so `p10k configure`
# edits the checkout directly.
[ -f "$HOME/.config/zsh/.p10k.zsh" ] && source "$HOME/.config/zsh/.p10k.zsh"

# -------------------------
# Environment
# -------------------------
export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"

if [[ -n "${XDG_CONFIG_HOME-}" ]]; then
  export NVM_DIR="$XDG_CONFIG_HOME/nvm"
else
  export NVM_DIR="$HOME/.nvm"
fi

# Sourcing nvm.sh costs about 0.7s, which was most of the time this file took to
# run. Put the default version straight on PATH and defer nvm itself until it is
# actually called, so node is available immediately and the shell opens fast.
nvm_default=""
[[ -r "$NVM_DIR/alias/default" ]] && nvm_default="$(<"$NVM_DIR/alias/default")"

if [[ -n "$nvm_default" && -d "$NVM_DIR/versions/node/$nvm_default/bin" ]]; then
  path=("$NVM_DIR/versions/node/$nvm_default/bin" $path)
  nvm() {
    unfunction nvm
    source "$NVM_DIR/nvm.sh"
    nvm "$@"
  }
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # The default is an alias we cannot resolve without nvm (say "lts/*"), so take
  # the slow path rather than leave node off PATH entirely.
  source "$NVM_DIR/nvm.sh"
fi
unset nvm_default

# bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"

# -------------------------
# lazygit
# -------------------------
# In a repo: normal lazygit. Not in a repo: pick one from the subfolders.
# Same script the tmux <prefix>g popup uses.
lazygit() { ~/.config/lazygit/lazygit.sh "$@"; }
alias lg='lazygit'

# -------------------------
# Codex CLI
# -------------------------
# Codex with no approval prompts and no sandbox (mirrors `danger` for Claude).
alias dangerx='codex --dangerously-bypass-approvals-and-sandbox'
