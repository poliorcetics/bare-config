# Aliases that have evolved into functions

function hs() {
    local target_path=$( sk \
        --exit-0 \
        --preview='bat -p --color always {1}' \
        --preview-window='right:67%')
    if [[ -z "$target_path" ]]; then return 1; fi;

    hx "$target_path"
}


function zs() {
    local target_path=$(fd \
        --type f \
        --hidden \
        --color never \
        --strip-cwd-prefix $@ \
        | sk \
        --exit-0 \
        --preview='bat -p --color always {1}' \
        --preview-window='right:67%')
    if [[ -z "$target_path" ]]; then return 1; fi;

    target_path=$(dirname "$target_path")

    if [[ $? != 0 ]] || [[ ! -d "$target_path" ]]; then return 1; fi
    z "$target_path"
}
