# Set environment variables that are always there, regardless of shell and OS

## XDG specification
# Setting some variables for https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# My use of this spec diverges a little from defaults to have as little .dotfiles in $HOME, it's already
# cluttered enough without adding to it with cache directories

export XDG_CONFIG_HOME="$HOME/.config"      # Config files
export XDG_DATA_HOME="$HOME/.local/share"   # User-specific data files
export XDG_STATE_HOME="$HOME/.local/state"  # User-specific state files, not portable enough for $XDG_DATA_HOME
                                            # Can contains data like logs, history, recently used files,
                                            # current state of the app that can be reused on startup
export XDG_CACHE_HOME="$HOME/.local/cache"  # User-specific non-essential data files 

# EDITOR is used by many program that needs file-like interaction with the user, e.g Git
export EDITOR="hx"
export VISUAL="hx"

# Lang, most tools do not handle anything but English,
# and americans do not know how to speak English so use GB
export LANGUAGE="en_GB:en_US:fr_FR"
export LC_MESSAGES="en_GB.UTF-8"
export LANG="en_GB.UTF-8"
if ( __shell_init_is_in_nix_shell ); then
    export LC_ALL="en_US.UTF-8"
fi
# Still use French for numbers, time and money, these are the formats and units I know
export LC_ADDRESS="fr_FR.UTF-8"
export LC_COLLATE="fr_FR.UTF-8"
export LC_IDENTIFICATION="fr_FR.UTF-8"
export LC_MEASUREMENT="fr_FR.UTF-8"
export LC_MONETARY="fr_FR.UTF-8"
export LC_NUMERIC="fr_FR.UTF-8"
export LC_TELEPHONE="fr_FR.UTF-8"
export LC_TIME="fr_FR.UTF-8"

export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/rc.py"

less_dir="$XDG_STATE_HOME/less"
export LESSHISTFILE="$less_dir/lesshistory"
export LESSHISTSIZE=1000
mkdir -p "$less_dir"
unset -v less_dir

if ( ! __shell_init_is_in_nix_shell ); then
    # Rust environment because I always install it: I need it for LunarVim and lots of other tools
    export RUSTUP_HOME="$XDG_CACHE_HOME/rustup"  # Put Rustup in cache, it only contains toolchains and downloads
    export CARGO_HOME="$XDG_DATA_HOME/cargo"     # Cargo on the other hand contains user-specific config and binaries 
    path_add "$CARGO_HOME/bin"
fi

path_add "/opt/homebrew/bin"

# The untracked and non-ignored will be at the bottom of the list.
# This is good because they are most of the time the ones I want when working
# on something that has a dirty git state.
export SKIM_DEFAULT_COMMAND="git ls-files -co --exclude-standard || fd --type f --hidden"

export _ZO_DATA_DIR="$XDG_STATE_HOME/zoxide"

export STARSHIP_CACHE="$XDG_CACHE_HOME/starship"

export ZELLIJ_CONFIG_DIR="$XDG_CONFIG_HOME/zellij"
export ZELLIJ_CONFIG_FILE="$ZELLIJ_CONFIG_DIR/config.yaml"
