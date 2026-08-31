#!/bin/sh
# Prints the node and java versions a shell in this pane would actually use.
#
# Neither is found by running the tool. `java -version` starts a JVM, and tmux
# redraws the status bar every 5 seconds - paying ~200ms that often, for a
# string that only changes when the JDK does, is not worth it. Both versions
# are read from files that already state them.

# Node: nvm's default alias. That is what ~/.config/zsh/.zshrc puts on PATH, so
# it is what a shell here runs. A `nvm use` inside the pane would diverge, but
# tmux has no way to see a variable set in someone else's shell.
NVM_DIR=${NVM_DIR:-$HOME/.nvm}
node_version=$(cat "$NVM_DIR/alias/default" 2>/dev/null)
[ -n "$node_version" ] && printf '#[fg=#8ce00a]  %s ' "${node_version#v}"

# Java: java_home resolves the JDK (about 10ms) and the JDK states its own
# version in release. The -v must match the one in ~/.config/zsh/.zshrc, or the
# bar and the prompt will disagree once a second JDK is installed.
java_home=$(/usr/libexec/java_home -v 21 2>/dev/null)
if [ -n "$java_home" ] && [ -r "$java_home/release" ]; then
  java_version=$(sed -n 's/^JAVA_VERSION="\(.*\)"/\1/p' "$java_home/release")
  [ -n "$java_version" ] && printf '#[fg=#ffa3a9]  %s ' "$java_version"
fi
