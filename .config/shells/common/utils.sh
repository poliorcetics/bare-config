
# To work correctly this script needs a `MAIN_SHELL` variable to be defined
# Else `zsh` is assumed

if [[ -z "${shell_utils_imported+x}" ]]; then
  function __shell_init_sh_error {
    echo "ERROR: $@"
    exit 1
  }

  # Defining the functions this way ensures we do the test only once.
  if [[ "$OSTYPE" == "darwin"* ]]; then
    function __shell_init_is_mac() { return 0; }
    function __shell_init_is_linux() { return 1; }
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    function __shell_init_is_mac() { return 1; }
    function __shell_init_is_linux() { return 0; }
  else
    __shell_init_sh_error "Unsupported os type: '$OSTYPE'"
  fi

  MAIN_SHELL="${MAIN_SHELL:-zsh}"
  if [[ "$MAIN_SHELL" == "zsh" ]]; then
    function __shell_init_is_zsh() { return 0; }
    function __shell_init_is_bash() { return 1; }
  elif [[ "$MAIN_SHELL" == "bash" ]]; then
    function __shell_init_is_zsh() { return 1; }
    function __shell_init_is_bash() { return 0; }
  else
    __shell_init_sh_error "Unsupported shell type: '$MAIN_SHELL'"
  fi

  if [[ -z "$IN_NIX_SHELL" ]]; then
    function __shell_init_is_in_nix_shell() { return 1; }
  else
    function __shell_init_is_in_nix_shell() { return 0; }
  fi

  # Add arg '$1' to $PATH if not already in it.
  # Avoids duplication in $PATH.
  function path_add() {
    case :"$PATH": in
      *:"$1":*)
        ;;
      *) 
        export PATH="$1":"$PATH"
        ;;
    esac
  }

  function gen_all_completions_inner() {
    local comp_dir="$XDG_CONFIG_HOME/shells/$1/completions"
    mkdir -p "$comp_dir"

    rustup completions $1 > "$comp_dir/_rustup"
    rustup completions $1 cargo > "$comp_dir/_cargo"
   
    gh completion -s $1 > "$comp_dir/_gh"

    local has_pip3=`command -v pip3 > /dev/null && echo true || echo false`
    local has_pip=`command -v pip > /dev/null && echo true || echo false`
    if ( $has_pip3 ); then
        pip3 completion --$1 > "$comp_dir/_pip3"
    fi
    if ( $has_pip ); then
        pip completion --$1 > "$comp_dir/_pip"
    fi

    kitty + complete setup $1 > "$comp_dir/_kitty"

    starship completions $1 > "$comp_dir/_starship"
  }

  function gen_all_completions() {
    gen_all_completions_inner zsh
    gen_all_completions_inner bash
  }

  function run_all_updates() {
    local is_apt=`command -v apt > /dev/null && echo true || echo false`
    local is_pacman=`command -v pacman > /dev/null && echo true || echo false`
    if ( __shell_init_is_mac ); then
      echo "=== Homebrew ==="
      echo ""

      brew upgrade
      brew cleanup
    elif ( __shell_init_is_linux ) && ( $is_apt ); then
      echo "=== APT ==="
      echo ""

      sudo -k 2>/dev/null || true
      sudo apt update && sudo apt upgrade
    elif ( __shell_init_is_linux ) && ( $is_pacman ); then
      echo "=== PACMAN ==="
      echo ""

      sudo -k 2>/dev/null || true
      sudo pacman -Syu
    fi

    echo "=== PIP ==="
    echo ""
    pip3 list | rg '(\S+)\s+\d+.\d+.\d+' -r '$1' | xargs pip3 install --upgrade

    echo "=== Rustup ==="
    echo ""
    rustup update

    echo "=== Cargo ==="
    echo ""
    cargo install cargo-update
    cargo install-update --all

    local update_rust_analyzer=false
    local update_helix=false
    for arg in "$@"; do
      case "$arg" in
        "--ra")
          update_rust_analyzer=true
          ;;
        "--hx")
          update_helix=true
          ;;
        *)
          __shell_init_sh_error "Unsupported arg: '$arg'"
          ;;
      esac
    done

    if ( $update_helix ) || ( $update_rust_analyzer ); then
      if ( __shell_init_is_mac ); then
        local manual_install_repos="$HOME/Projects/rust"
      elif ( __shell_init_is_linux ); then
        local manual_install_repos="$HOME/repos"
      else
        __shell_init_sh_error "Not repos from which to update on this platform"
      fi
    fi

    if [ ! -z "$manual_install_repos" ]; then
      if ( $update_rust_analyzer ); then
        echo "=== Rust Analyzer ==="
        echo ""
        ( cd "$manual_install_repos/rust-analyzer" \
            && git checkout master \
            && git pull \
            && cargo xtask install --server )
      fi

      if ( $update_helix ); then
        echo "=== Helix ==="
        echo ""
        local helix_runtime="${HELIX_RUNTIME:-${XDG_CONFIG_HOME:-$HOME/.config}/helix/runtime}"
        ( cd "$manual_install_repos/helix" \
            && git checkout master \
            && git pull \
            && cargo install --force --path helix-term \
            && ln -s "$PWD/runtime" "$helix_runtime" \
            && hx --grammar fetch \
            && hx --grammar build )
      fi
    fi

    gen_all_completions
  }

  # Set to ensure we don't redefine the functions above each time this file is sourced.
  shell_utils_imported="shell_utils_imported"
fi

