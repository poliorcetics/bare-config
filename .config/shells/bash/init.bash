export BASH_CACHE_DIR="$XDG_STATE_HOME/bash"
test -d "$BASH_CACHE_DIR" || mkdir -p "$BASH_CACHE_DIR"

export HISTFILE="$BASH_CACHE_DIR/.bash_history"
export HISTFILESIZE=10000
export HISTSIZE=$HISTFILESIZE
export HISTIGNORE=fg
export HISTTIMEFORMAT="[%F %T] "

# Completion files are named '_{command}' in their shell dir
for compfile in `fd -t f '^_.*' "$HOME/.config/shells/bash/"`; do
  source "$compfile"
done

alias shistory='history | rg'

eval "$(zoxide init bash)"
eval "$(starship init bash)"
