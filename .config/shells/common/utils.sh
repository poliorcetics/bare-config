
# To work correctly this script needs a `MAIN_SHELL` variable to be defined
# Else `zsh` is assumed

if [[ -z "${shell_utils_imported+x}" ]]; then
  function sh_error {
    echo "ERROR: $@"
    exit 1
  }

  # Defining the functions this way ensures we do the test only once.
  if [[ "$OSTYPE" == "darwin"* ]]; then
    function is_mac() { return true; }
    function is_linux() { return false; }
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    function is_mac() { return false; }
    function is_linux() { return true; }
  else
    sh_error "Unsupported os type: '$OSTYPE'"
  fi

  MAIN_SHELL="${MAIN_SHELL:-zsh}"
  if [[ "$MAIN_SHELL" == "zsh" ]]; then
    function is_zsh() { return true; }
    function is_bash() { return false; }
  elif [[ "$MAIN_SHELL" == "bash" ]]; then
    function is_zsh() { return false; }
    function is_bash() { return true; }
  else
    sh_error "Unsupported shell type: '$MAIN_SHELL'"
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

    pip3 completion --$1 > "$comp_dir/_pip3"
    pip completion --$1 > "$comp_dir/_pip"

    kitty + complete setup $1 > "$comp_dir/_kitty"

    starship completions $1 > "$comp_dir/_starship"
  }

  function gen_all_completions() {
    gen_all_completions_inner zsh
    gen_all_completions_inner bash
  }

  function run_all_updates() {
    local is_apt=`command -v apt; echo $?`
    if [[ is_mac ]]; then
      echo "=== Homebrew ==="
      echo ""

      brew upgrade
      brew cleanup
    elif [[ is_linux ]] && [[ is_apt ]]; then
      echo "=== APT ==="
      echo ""

      sudo -k 2>/dev/null || true
      sudo apt update && sudo apt upgrade
    fi

    echo "=== PIP ==="
    echo ""
    pip3 list | rg '(\S+)\s+\d+.\d+.\d+' -r '$1' | xargs pip3 install --upgrade
  
    echo "=== Rustup ==="
    echo ""
    rustup update
  
    echo "=== Cargo ==="
    echo ""
    cargo install --list | rg '([\w-]+) v\S+:' -r '$1' | xargs cargo install

    local update_rust_analyzer=false
    for arg in "$@"; do
      case "$arg" in
        "--ra")
          update_rust_analyzer=true
          ;;
        *)
          sh_error "Unsupported arg: '$arg'"
          ;;
      esac
    done

    if [[ is_mac ]] && [[ update_rust_analyzer ]]; then
      echo "=== Rust Analyzer ==="
      echo ""
      ( cd ~/Projects/rust/rust-analyzer \
          && git checkout master \
          && git pull \
          && cargo xtask install --server )
    elif [[ update_rust_analyzer ]]; then
      sh_error "Updating Rust Analyzer from source is not supported outside of macOS for now"
    fi

    gen_all_completions
  }

  # Set to ensure we don't redefine the functions above each time this file is sourced.
  shell_utils_imported="shell_utils_imported"
fi

