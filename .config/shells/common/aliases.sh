# Aliases that are always there regardless of OS and shell

# Config management
alias cfg='GIT_DIR="$HOME/.config/bare-config.git/" GIT_WORK_TREE="$HOME"'
alias gc='cfg git'

# Basic tools
alias g='git'
alias cg='cargo'
alias lv='lvim'
alias ..='z ..'

alias hs='hx $(sk)'
function zs() {
  local target_path=$(fd --type d --hidden --color never --strip-cwd-prefix $@ | sk --exit-0) # --preview='exa --long --all --group-directories-first --no-user {1}'
  if [[ -z "$target_path" ]]; then
    return 1;
  fi;
  z "$target_path"
}

alias rgi='rg --no-ignore'
alias fdi='fd -I'

alias pj='pijul'

alias ls='exa -F --colour-scale --time-style long-iso --group-directories-first';
alias la='exa -haF --colour-scale --time-style long-iso --group-directories-first';
alias ll='exa -lhaF --colour-scale --time-style long-iso --group-directories-first';
alias l='exa -lhF --colour-scale --time-style long-iso --group-directories-first';

alias lg='exa -lhaF --colour-scale --time-style long-iso --git --group-directories-first';
alias llg='exa -lhF --colour-scale --time-style long-iso --git --group-directories-first';
alias lmg='lm --git'; # 'lm' comes from a personal Rust crate and already has the --group-directories-first option

source "$HOME/.config/shells/common/utils.sh"

if ( __shell_init_is_mac ); then
  alias showsystemfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
  alias hidesystemfiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

  alias b='brew'
  alias bu='brew upgrade && brew cleanup'
  alias bnuke='brew cleanup --prune 0'
fi
