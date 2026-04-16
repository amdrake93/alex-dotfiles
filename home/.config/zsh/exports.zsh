# PATH additions (conditional — only if the tool/dir exists)
export PATH="$PATH:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin"

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden'
export FZF_DEFAULT_OPTS='--no-height --color=bg+:#343d46,gutter:-1,pointer:#ff3c3c,info:#0dbc79,hl:#0dbc79,hl+:#23d18b --preview="bat --style=numbers --color=always --line-range :500 {}"'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}'"
export FZF_ALT_C_COMMAND='fd --type d . --hidden'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -50'"

# Editor
export EDITOR=nvim
export MYVIMRC="$HOME/.config/nvim/init.lua"

# AWS
export AWS_PROFILE=default

# Homebrew (if not already set by .zprofile)
[[ -d /opt/homebrew/bin/ ]] && export PATH="$PATH:/opt/homebrew/bin/"

# NVM
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

# Pyenv
if [[ -d $HOME/.pyenv ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# Jenv (per-project Java versions)
if type jenv &>/dev/null; then
  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"
fi

# Bun
if [ -s "$HOME/.bun/_bun" ]; then
  source "$HOME/.bun/_bun"
  PATH="$PATH:$HOME/.bun/bin"
fi

# Navi (cheat sheet widget)
if type navi &>/dev/null; then
  eval "$(navi widget zsh)"
fi
