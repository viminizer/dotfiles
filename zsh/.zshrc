[[ ! -o interactive ]] && return
# =========================================================
# ZSHRC — optimized for speed
# =========================================================
#
# DEPENDENCIES (install on new machine):
#   brew install zsh-autosuggestions fzf zoxide powerlevel10k glow bat git-delta gum eza
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
# Plugins
# -------------------------
# Autosuggestions (fish-style, accept with Tab or →)
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# zoxide (use 'cd' to jump to directories, e.g., 'cd proj')
eval "$(zoxide init zsh --cmd cd 2>/dev/null)"

# -------------------------
# Homebrew
# -------------------------
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

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
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
# -------------------------
# Claude Code CLI
# -------------------------
export PATH="$HOME/.local/bin:$HOME/.claude/local/bin:$PATH"

# -------------------------
# Powerlevel10k
# -------------------------
[ -f /usr/local/opt/powerlevel10k/share/powerlevel10k/powerlevel10k.zsh-theme ] && \
  source /usr/local/opt/powerlevel10k/share/powerlevel10k/powerlevel10k.zsh-theme
[ -f "$HOME/.p10k.zsh" ] && source "$HOME/.p10k.zsh"

# -------------------------
# Environment
# -------------------------
export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# bun completions
[ -s "/Users/mac/.bun/_bun" ] && source "/Users/mac/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
