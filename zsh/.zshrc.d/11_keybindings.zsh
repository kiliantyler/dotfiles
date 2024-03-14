atuin-setup() {
  if ! which atuin &>/dev/null; then return 1; fi
  bindkey '^T' _atuin_search_widget

  export ATUIN_NOBIND="true"
  eval "$(atuin init "$(basename $(echo $SHELL))")"
  fzf-atuin-history-widget() {
    local selected num
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null

    # local atuin_opts="--cmd-only --limit ${ATUIN_LIMIT:-5000}"
    local atuin_opts="--cmd-only"
    local fzf_opts=(
      -p 90%,75%
      --tac
      "-n2..,.."
      --tiebreak=index
      "--query=${LBUFFER}"
      "+m"
      "--bind=ctrl-d:reload(atuin search $atuin_opts -c $PWD),ctrl-r:reload(atuin search $atuin_opts)"
    )

    selected=$(
      eval "atuin search ${atuin_opts}" |
        fzf-tmux "${fzf_opts[@]}"
    )
    local ret=$?
    if [ -n "$selected" ]; then
      # the += lets it insert at current pos instead of replacing
      LBUFFER+="${selected}"
    fi
    zle reset-prompt
    return $ret
  }
  zle -N fzf-atuin-history-widget
  bindkey '^R' fzf-atuin-history-widget
  # bindkey "${key[Up]}" fzf-atuin-history-widget
}
atuin-setup

# _fzf_comprun() {
#   local command=$1
#   shift

#   case "$command" in
#   cd) fzf --preview 'zoxide query -a $@' ;;
#   *) fzf "$@" ;;
#   esac
# }

# __zoxide_z_complete() {
#   args=$(eza -1 | awk '{print $1}' | tr '\n' ' ')
#   _arguments "1:profiles:($args)"
# }
# #fzf-tab config
# zstyle ':completion:*:__zoxide_z:*' sort false

# __zoxide_z_complete() {
#   # Get output from eza for local directories, ensuring no color codes
#   local eza_output
#   eza_output=$(eza -1 | awk '{print $1}' | tr '\n' ' ')

#   # Get zoxide query results, filtering for directory paths
#   local zoxide_output
#   zoxide_output=$(zoxide query -l)

#   # Combine eza output and zoxide output. Convert newlines to spaces for _arguments compatibility
#   local combined_args
#   combined_args="${eza_output}"$'\n'"${zoxide_output}"
#   combined_args=(${(f)combined_args}) # Split combined_args into an array by newlines

#   # Pass combined results to _arguments for autocomplete
#   _arguments "1:directories:(${combined_args[*]})"
# }

# # fzf-tab configuration
# # zstyle ':completion:*:__zoxide_z:*' sort false
