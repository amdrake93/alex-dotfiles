# Edit command in $EDITOR via Ctrl-X Ctrl-E
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# Arrow keys: history-substring-search (from zsh-history-substring-search plugin)
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# Home / End / Delete (macOS terminal sequences)
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
