# Installer, should only be called once on system setup and never after.

if [[ -z "$1" ]]; then
  echo "This installer takes one argument, the main shell"
  echo "Possible values: bash, zsh (default)"
  exit 1
fi

if [[ "$1" != "bash" ]] && [[ "$1" != "zsh" ]]; then
  echo "Valid shell values are 'bash' and 'zsh', not '$1'"
  exit 1
fi

MAIN_SHELL="$1"

source "$HOME/.config/shells/common/utils.sh"
source "$HOME/.config/shells/common/envvar.sh"

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$HOME/.local/bin/"
mkdir -p "$CARGO_HOME" "$RUSTUP_HOME"

# Install brew if not already installed. This also install Apple's Command Line Tools on first run
if ( __shell_init_is_mac ) && ! command -v brew &> /dev/null; then
  echo "Installing HomeBrew, and possibly Apple's Command Line Tools if they were not previously installed"
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sh

  brew install \
    cmake \
    gh git \
    python3 \
    zsh zsh-syntax-highlighting

  brew install --cask \
    cyberduck \
    firefox \
    kitty \
    monitorcontrol \
    signal \
    transmission \
    vlc

  brew install neovim --HEAD --build-from-source

  # Use the most recent version of ZSH, not Apple's
  zsh_shell_path="$(brew --prefix)/bin/zsh"
  echo "Adding '$zsh_shell_path' to /etc/shells, this needs sudo"
  sudo echo "$zsh_shell_path" >> /etc/shells
  sudo -k
  echo "Relinquished sudo rights"
  chsh -s "zsh_shell_path"
  unset -v zsh_shell_path

  # Authenticate for Github CLI if wanted
  gh auth login
fi

# Install Rust only if not already installed
if ! command -v rustup &> /dev/null; then
  echo "Installing Rust (rustup, cargo), select the things you want"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > .$$-install-rustup.sh
  sh .$$-install-rustup.sh --no-modify-path
  rm .$$-install-rustup.sh
fi

# Grouped by first letter, in alphabetical order
"$CARGO_HOME/bin/cargo" install \
  bat bingrep \
  cargo-binutils cargo-edit cargo-expand cargo-upgrades cargo-watch cargo-xtask \
  du-dust \
  exa \
  fd-find \
  git-delta gitui \
  hx hyperfine \
  mdbook \
  pastel procs \
  ripgrep rnr \
  sd skim starship \
  tokei typeracer \
  watchexec-cli wool \
  ytop \
  zoxide

# Install LunarVim if not already present
if ! command -v lvim &> /dev/null; then
  restore_backup=0
  function cp_command() {
    if ( __shell_init_is_mac ); then
      cp -R "$@"
    elif ( __shell_init_is_linux ); then
      cp -r "$@"
    fi
  }

  if [[ -d "$XDG_CONFIG_HOME/lvim" ]]; then
    cp_command "$XDG_CONFIG_HOME/lvim" "$XDG_CONFIG_HOME/$$-tmp-lvim"
    restore_backup=1
  fi

  curl -fsSL https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh | sh
  
  if [[ restore_backup -eq 1 ]]; then
    cp_command "$XDG_CONFIG_HOME/$$-tmp-lvim" "$XDG_CONFIG_HOME/lvim" 
    rm -rf "$XDG_CONFIG_HOME/$$-tmp-lvim" 
  fi

  unset -v restore_backup
  unset -f cp_command
fi

gen_all_completions

# macOS specific actions
if ( __shell_init_is_mac ); then
  mkdir -p "$HOME/Projects/rust/"
  cd "$HOME/Projects/rust/"
  git clone https://github.com/rust-analyzer/rust-analyzer
  run_all_updates --ra

  echo "Remember to run 'spctl developer-mode enable-terminal' and enable it in System Preferences"
else
  run_all_updates
fi

echo "Now restart your shell or open a new one"
