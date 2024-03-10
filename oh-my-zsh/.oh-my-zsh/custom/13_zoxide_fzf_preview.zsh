# lives in its own file so we don't have to source the giant script into the preview fzf function
# $1 is the folder we need to look in
function __zoxide_fzf_preview() {
  if [[ -o nomatch ]]; then
    __nomatch_set=true
    set +o nomatch
  fi
  folder="$1"
  # strip the color codes from the folder name
  folder="$(echo -e "$folder" | \command sed -e 's/\x1b\[[0-9;]*m//g' -e 's/^.\{0,1\} //')"
  folder="$(echo -e "$folder" | \command sed -e "s|~|${HOME}|g")"
  if [[ -d "$folder" ]]; then
    if output=$(\eza -1ad --icons --group-directories-first --color=always -- $folder/* 2>/dev/null); then
      echo -e "$output" | \command sed -e "s|$folder/||g"
    else
      echo -e "Folder is empty"
    fi
  fi
  if [[ -n "${__nomatch_set}" ]]; then
    set -o nomatch
  fi
}

# \command eza -1adD --color=always -- \$(echo -e "{2}" | sed 's#~#${HOME}##')/*/
