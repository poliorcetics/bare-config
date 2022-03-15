# Aliases that have evolved into functions

function hs() {
    local target_path=$(sk --preview='bat -p --color always {1}');
    if [[ -z "$target_path" ]]; then
        return 1;
    fi;
    hx "$target_path"
}


function zs() {
    local target_path=$(fd --type d --hidden --color never --strip-cwd-prefix $@ | sk --exit-0) # --preview='exa --long --all --group-directories-first --no-user {1}'
    if [[ -z "$target_path" ]]; then
        return 1;
    fi;
    z "$target_path"
}
