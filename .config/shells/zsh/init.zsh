# History options

setopt extended_history   # Record timestamp of command in HISTFILE
setopt histfindnodups     # Ignore duplicates when searching history
setopt histignorealldups  # Don't save duplicates
setopt histignorespace    # Ignore commands that start with space
setopt histverify         # Show command with history expansion to user before running it
setopt incappend_history  # Write to HISTFILE as soon as the command are entered
setopt nocaseglob         # Ignore case when globbing
setopt nocasematch        # Ignore case when matching
setopt numericglobsort    # Sort filenames numerically when it makes sense
setopt sharehistory       # Share command history data

bindkey ^A beginning-of-line
bindkey ^E end-of-line

# Upper/Lower key search history
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

if ( __shell_init_is_mac ); then
  bindkey "^[[A" history-beginning-search-backward-end
  bindkey "^[[B" history-beginning-search-forward-end
elif ( __shell_init_is_linux ); then
  bindkey "^[OA" history-beginning-search-backward-end
  bindkey "^[OB" history-beginning-search-forward-end

  bindkey -e
  bindkey '^[[7~' beginning-of-line                   # Home key
  bindkey '^[[H' beginning-of-line                    # Home key
  if [[ "${terminfo[khome]}" != "" ]]; then
    bindkey "${terminfo[khome]}" beginning-of-line    # [Home] - Go to beginning of line
  fi
  bindkey '^[[8~' end-of-line                         # End key
  bindkey '^[[F' end-of-line                          # End key
  if [[ "${terminfo[kend]}" != "" ]]; then
    bindkey "${terminfo[kend]}" end-of-line           # [End] - Go to end of line
  fi
  bindkey '^[[2~' overwrite-mode                      # Insert key
  bindkey '^[[3~' delete-char                         # Delete key
  bindkey '^[[C'  forward-char                        # Right key
  bindkey '^[[D'  backward-char                       # Left key
  bindkey '^[[5~' history-beginning-search-backward   # Page up key
  bindkey '^[[6~' history-beginning-search-forward    # Page down key

  # Navigate words with ctrl+arrow keys
  bindkey '^[Oc' forward-word       #
  bindkey '^[Od' backward-word      #
  bindkey '^[[1;5D' backward-word   #
  bindkey '^[[1;5C' forward-word    #
  bindkey '^H' backward-kill-word   # delete previous word with ctrl+backspace
  bindkey '^[[Z' undo               # Shift+tab undo last action
fi

export ZSH_CACHE_DIR="$XDG_STATE_HOME/zsh"
test -d "$ZSH_CACHE_DIR" || mkdir -p "$ZSH_CACHE_DIR"

export HISTFILE="$ZSH_CACHE_DIR/.zsh_history"
export SAVEHIST=10000
export HISTSIZE=$SAVEHIST
export HISTORY_IGNORE=fg
export HISTTIMEFORMAT="[%F %T] "

if ( __shell_init_is_mac ); then
  [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || true
  [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif ( __shell_init_is_linux ); then
  ## Plugins section: Enable fish style features
  # Use syntax highlighting
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  # Use history substring search
  source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
  # bind UP and DOWN arrow keys to history substring search
  zmodload zsh/terminfo
  bindkey "$terminfo[kcuu1]" history-substring-search-up
  bindkey "$terminfo[kcud1]" history-substring-search-down
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# Must be loaded before compinit
# zmodload zsh/complist
export fpath=( "$XDG_CONFIG_HOME/shells/zsh/completions" $fpath )

autoload -Uz compinit colors
mkdir -p "$XDG_CACHE_HOME/zsh"
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# pip completion is broken without this
source "$XDG_CONFIG_HOME/shells/zsh/completions/_pip3"
[ -f "$XDG_CONFIG_HOME/shells/zsh/completions/_pip" ] && source "$XDG_CONFIG_HOME/shells/zsh/completions/_pip"


zstyle ':completion:*' menu select                          # Allow you to select in a menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # Case insensitive tab completion
zstyle ':completion:*' rehash true                          # automatically find new executables in path
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/comp-cache"

colors

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-R

alias shistory='history 1 | rg'

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
