HISTSIZE=10000
SAVEHIST=10000

# History options
setopt append_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_verify
setopt inc_append_history
unsetopt hist_beep

# Exports and PATH
source "${ZDOTDIR}/exports.zsh"

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Completions
autoload -Uz compinit && compinit

# Ensure cache/data dirs exist
[[ ! -d ~/.cache/zsh ]] && mkdir -p ~/.cache/zsh
[[ ! -d ~/.local/share/zsh ]] && mkdir -p ~/.local/share/zsh

# Zoxide (smart cd)
if type zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# Aliases
source "${ZDOTDIR}/aliasrc"

# Source all zshrc.d modules
for i in "${ZDOTDIR}"/zshrc.d/*.zsh; do
  source "$i"
done; unset i
