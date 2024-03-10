
# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -L
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
# shellcheck disable=SC2154
if [[ ${precmd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] && [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]]; then
    chpwd_functions+=(__zoxide_hook)
fi

# Jump to a directory using only keywords.
function __zoxide_z() {
    # shellcheck disable=SC2199
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && { [[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]$ ]]; }; then
        __zoxide_cd "$1"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" && __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

function cd() {
    __zoxide_z "$@"
}

function cdi() {
    __zoxide_zi "$@"
}

# Completions.
if [[ -o zle ]]; then
    __zoxide_result=''

    function __zoxide_z_complete() {
        local __combined_results
        local __ls_results
        local __zoxide_results
        local __stripped_ls_results
        local __pwd
        local __ls_regex
        local __word
        # Only show completions when the cursor is at the end of the line.
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        # If there is only one argument, we can't complete anything.
        if [[ "${#words[@]}" -eq 2 ]]; then
            __word="${words[2]}"
            # If the argument ends in '..', we can complete it to '../', but only if it's the last argument.
            if [[ "${__word}" = '..' ]] || [[ "${__word: -3}" = '/..' ]]; then
              # pass the result to the helper function
              __zoxide_result="${__word}"
              # set the helper function to be called when the terminal responds
              \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
              # automatically request the terminal to respond
              \builtin printf '\e[5n'
              # stop processing the completion
              return
            fi
            if [[ -o GLOB_DOTS ]]; then
                GLOB_DOTS_was_set=true
            else
                GLOB_DOTS_was_set=false
                # Enable GLOB_DOTS
                setopt GLOB_DOTS
            fi
            if [[ -o nocaseglob ]]; then
                nocaseglob_was_set=true
            else
                nocaseglob_was_set=false
                # Enable nocaseglob
                setopt nocaseglob
            fi
            # Get the list of directories in the current directory.
            __ls_results="$(\command eza -1adD --color=always --icons -- ${__word}*/)"
            # if the result is one directory and its the same as the word typed in the terminal add a * to the end and rerun
            if [[ "$(echo "${__ls_results}" | wc -l)" -eq 1 ]]; then
              __ls_results="$(\command eza -1adD --color=always --icons -- ${__word}*/*/)"
            fi
            if [[ $nocaseglob_was_set = false ]]; then
              unsetopt nocaseglob
            fi
            if [[ $GLOB_DOTS_was_set = false ]]; then
              unsetopt GLOB_DOTS
            fi
            # Remove the current and parent directory from the list. (we have to check for unicode characters because folder icons)
            __ls_results="$(echo -e "${__ls_results}" | gawk '{
                  # Remove leading ANSI color codes for the check, store the rest
                  line_without_colors = gensub(/\x1b\[[0-9;]*m/, "", "g", $0)

                  # Check if the line without leading color codes matches the pattern
                  if (line_without_colors ~ /^[[:space:]]*(\.|\.\.)$/) {
                      # Skip printing this line
                      next
                  } else {
                      # Print the original line, preserving ANSI color codes
                      print $0
                  }
              }')"
            # Don't attempt zoxide if nothing has been typed yet.
            if [[ "${words[-1]}" != '' ]]; then
              # Get the list of directories from zoxide.
              __zoxide_results="$(\command zoxide query -l --exclude "$(__zoxide_pwd || \builtin true)" -- ${words[2,-1]} 2>/dev/null | \command head -n 5)" || __zoxide_result=''
            fi
        fi
        # Set up the results to be passed to the helper function
        __combined_results=''
        # if there are results from ls, add them to the combined results
        if [[ -n "${__ls_results}" ]]; then
            __combined_results+="${__ls_results}"
        fi
        # if there are results from zoxide, add them to the combined results
        if [[ -n "${__zoxide_results}" ]]; then
            # if there are results from ls, add a newline to separate them
            if [[ -n "${__ls_results}" ]]; then
              # Since there are results from ls, we should dedupe the list, but the ls results need pwd prepended
              __pwd="$(\command pwd)"
              __stripped_ls_results="$(echo -e "${__ls_results}" \
                            | \command sed -e 's/\x1b\[[0-9;]*m//g' \
                                           -e 's/^.\{0,1\} //' \
                                           -e "s/(.*)/${__pwd//\//\\/}\/\1/" 2>/dev/null)"

              # dedupe the list
              for __stripped_ls_result in ${__stripped_ls_results}; do
                __zoxide_results="$(echo -e "${__zoxide_results}" | grep -v -E "^${__stripped_ls_result}$")"
              done
              # check if there are still results from zoxide
              if [[ -n "${__zoxide_results}" ]]; then
                # add a newline to separate the results
                __combined_results+=$'\n'
              fi
            fi
            if [[ -n "${__zoxide_results}" ]]; then
              __zoxide_results="$(echo -e "${__zoxide_results}" | \command sed -e "s|$HOME|~|g" | \command sed -E 's/(.*)/\x1b[38;5;129m󰬇 \1\x1b[0m/')"
              __combined_results+="${__zoxide_results}"
            fi
        fi
        # if there are no results, just return so we don't get a blank fzf window
        if [[ -z "${__combined_results}" ]]; then
            return 0
        fi
        # if there is only 1 result, just fill it on the line
        if [[ "$(echo -e "${__combined_results}" | wc -l)" -eq 1 ]]; then
            # set the result to the single result
            __zoxide_result=$__combined_results
            # set single_result to true so the helper function knows to fill the line
            __single_result=true
            \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
            \builtin printf '\e[5n'
            return 0
        fi
        __fzf_result_file="/tmp/fzf_result.tmp"
        __zoxide_result="$(echo -e "${__combined_results}" | sort -u | \command fzf-tmux --layout=reverse --ansi -p 75%,60% --preview ". ${functions_source[__zoxide_fzf_preview]}; __zoxide_fzf_preview {1..}" --bind "right:execute(echo {2..} > $__fzf_result_file)+abort" --no-sort --no-multi)"
        if [[ -f "$__fzf_result_file" ]]; then
          \builtin bindkey '\e[0n' '__insert_fzf_selection_into_buffer'
          \builtin printf '\e[5n'
          return 0
        fi
        # echo -e "${__combined_results}"
        \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
        # Send '\e[0n' to console input.
        \builtin printf '\e[5n'
        # Report that the completion was successful, so that we don't fall back
        # to another completion function.
        return 0
    }


    function __insert_fzf_selection_into_buffer() {
      local file_path="$__fzf_result_file"
      local selection
      read selection < "$file_path"
      rm -f "$file_path"

      # Check if a selection was made
      if [[ -n "$selection" ]]; then
          # Assuming you want to append the selection to BUFFER and move the cursor
          BUFFER="cd $selection"
          CURSOR=$#BUFFER
          \builtin zle reset-prompt
          # Accept the line
          \builtin zle complete-word
      fi
    }


    function __zoxide_z_complete_helper() {
        __zoxide_result="$(echo "${__zoxide_result}" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/[󰬇] //')"
        if [[ -n "${__single_result}" ]]; then
            BUFFER="cd ${(q-)__zoxide_result}"
            CURSOR=$#BUFFER
            __single_result=''
            \builtin zle reset-prompt
            return
        fi
        if [[ -n "${__zoxide_result}" ]]; then
            if [[ "${__zoxide_result}" = '..' ]] || [[ "${__zoxide_result: -3}" = '/..' ]]; then
                RBUFFER="/"
                CURSOR=$#BUFFER
                \builtin zle reset-prompt
                return
            fi
            # cut out the first column separated by a space
            __zoxide_result="$(echo "${__zoxide_result}" | cut -d ' ' -f 2-)"
            BUFFER="cd ${__zoxide_result}"
            \builtin zle reset-prompt
            \builtin zle accept-line
        else
            \builtin zle reset-prompt
        fi
    }
    \builtin zle -N __zoxide_z_complete_helper
    \builtin zle -N __insert_fzf_selection_into_buffer

    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete cd
fi
