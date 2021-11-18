# History options

setopt extended_history         # Record timestamp of command in HISTFILE
setopt hist_find_no_dups        # Ignore duplicates when searching history
setopt hist_ignore_all_dups     # Don't save duplicates
setopt hist_ignore_space        # Ignore commands that start with space
setopt hist_verify              # Show command with history expansion to user before running it
setopt inc_append_history       # Write to HISTFILE as soon as the command are entered
setopt share_history            # Share command history data

# Globbing options

setopt no_case_glob             # Ignore case when globbing
setopt no_case_match            # Ignore case when matching

bindkey ^A beginning-of-line
bindkey ^E end-of-line

# Upper/Lower key search history
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

export ZSH_CACHE_DIR="$XDG_STATE_HOME/zsh"
test -d "$ZSH_CACHE_DIR" || mkdir -p "$ZSH_CACHE_DIR"

export HISTFILE="$ZSH_CACHE_DIR/.zsh_history"
export SAVEHIST=10000
export HISTSIZE=$SAVEHIST
export HISTORY_IGNORE=fg
export HISTTIMEFORMAT="[%F %T] "

if [[ is_mac ]]; then
  [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || true
fi

# Must be loaded before compinit
# zmodload zsh/complist
export fpath=( "$XDG_CONFIG_HOME/shells/zsh/completions" $fpath )

autoload -Uz compinit
compinit

# pip completion is broken without this
source "$XDG_CONFIG_HOME/shells/zsh/completions/_pip3"
source "$XDG_CONFIG_HOME/shells/zsh/completions/_pip"

# setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
# setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
# setopt COMPLETE_IN_WORD     # Complete from both ends of a word.

# Allow you to select in a menu
zstyle ':completion:*' menu select

# zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
# zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
# zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
# zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
# Colors for files and directory
# zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}

alias shistory='history 1 | rg'

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
