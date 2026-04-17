export ZDOTDIR=$HOME/.config/zsh
export HISTFILE="$HOME/.zsh_history"

# ~/bin first in PATH for user scripts (claudew, etc.)
export PATH="$HOME/bin:$PATH"

# Jenv shims on PATH via .zshenv so non-interactive shells (Claude Code's
# Bash tool, subagent subshells) inherit the shim-based java/javac/mvn.
# `jenv init -` still runs in exports.zsh for interactive-shell features
# (completion, export plugin). PATH ordering keeps ~/bin ahead of shims.
[[ -d "$HOME/.jenv/shims" ]] && export PATH="$HOME/bin:$HOME/.jenv/shims:${PATH#$HOME/bin:}"

# Disable files
export LESSHISTFILE=-
