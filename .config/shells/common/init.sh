# This script should be sourced from a .zshrc/.bashrc or equivalent, with the `MAIN_SHELL`
# variable set, see `common/utils.sh` for details.
#
# It will load elements in the following order:
#
# 1) Common envvar and aliases
# 2) Common local details from `common/local.sh`, not versioned
# 3) Shell-specific initialization
# 4) Shell-specific details from `$MAIN_SHELL/local.$MAIN_SHELL`, not versioned
#
# Note that 3) will probably load shell-specific envvar and aliases of its own, as will 4).

shell_config_path="$HOME/.config/shells"

# When calling this script, `MAIN_SHELL` must be defined, see `utils.sh` for details.
source "$shell_config_path/common/utils.sh"
source "$shell_config_path/common/envvar.sh"
source "$shell_config_path/common/aliases.sh"

path_add "/usr/local/bin"
path_add "$HOME/.local/bin" # Part of the XDG specification for user-specific binaries

# Then load common local config, can change predefined common config but not shell-specific config.
[[ -f "$shell_config_path/common/local.sh" ]] && source "$shell_config_path/common/local.sh"

# Shell-specific content is called after to ensure it is not overwritten by common config.
# Then load Shell-specific local config
if ( __shell_init_is_zsh ); then
  source "$shell_config_path/zsh/init.zsh";
  [[ -f "$shell_config_path/zsh/local.zsh" ]] && source "$shell_config_path/zsh/local.zsh"
elif ( __shell_init_is_bash ); then 
  source "$shell_config_path/bash/init.bash";
  [[ -f "$shell_config_path/bash/local.bash" ]] && source "$shell_config_path/bash/local.bash"
fi

unset -v shell_config_path
