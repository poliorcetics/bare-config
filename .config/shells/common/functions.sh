# Aliases that have evolved into functions

function hs() {
    local target_path=$(sk \
        --exit-0 \
        --preview='bat -p --color always {1}' \
        --preview-window='right:67%')
    if [[ -z "$target_path" ]]; then return 1; fi;

    hx "$target_path"
}


function hr() {
    local target_path=$(sk \
        --exit-0 \
        --ansi \
        --interactive \
        --cmd 'if [ ! -z "{}" ]; then rg --color=always --block-buffered --vimgrep "{}"; else echo "-- No search query --"; fi' \
        --delimiter ':' \
        --preview='echo {1}:{2}:{3} | hgrep -c 5 -C 25' \
        --preview-window='right:67%' \
        | rg '^(.*:\d+:\d+):.*$' --replace '$1')
    if [[ -z "$target_path" || "$target_path" == "-- No search query --"* ]]; then return 1; fi;

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
