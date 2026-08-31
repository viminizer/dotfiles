#!/bin/sh
# Prints the major node and java versions a shell in this pane would actually
# use. Major only: the patch digits change constantly, say nothing at a glance,
# and the full string is one `node -v` or `java -version` away when it matters.
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
node_version=${node_version#v}
[ -n "$node_version" ] && printf '#[fg=#8ce00a]  v%s ' "${node_version%%.*}"

# Java: java_home resolves the JDK (about 10ms) and the JDK states its own
# version in release. The -v must match the one in ~/.config/zsh/.zshrc, or the
# bar and the prompt will disagree once a second JDK is installed.
java_home=$(/usr/libexec/java_home -v 21 2>/dev/null)
if [ -n "$java_home" ] && [ -r "$java_home/release" ]; then
  java_version=$(sed -n 's/^JAVA_VERSION="\(.*\)"/\1/p' "$java_home/release")
  # Java 8 and older call themselves 1.8.0_452, where the major version is the
  # second field rather than the first. Dropping a leading "1." makes the old
  # and new schemes read alike, so an 8 shows as 8 and not as 1.
  java_version=${java_version#1.}
  [ -n "$java_version" ] && printf '#[fg=#ffa3a9]  v%s ' "${java_version%%.*}"
fi
