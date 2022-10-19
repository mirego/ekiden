# $PATH
export PATH="$HOME/Bin:$PATH"

# Aliases
alias l='ls -l'
alias ll='l -ah'

# Key bindings
bindkey -v
bindkey '\e[3~' delete-char
bindkey '^R' history-incremental-search-backward

# Auto-completion
setopt menu_complete
