#!/usr/bin/env zsh

function mcd () {
    mkdir -p $1
    cd $1 || exit
}

function extract {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    return 1
 else
    for n in $@; do
      if [ -f "$n" ] ; then
        case "${n%,}" in
          *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                        tar xvf "$n"       ;;
          *.lzma)      unlzma ./"$n"      ;;
          *.bz2)       bunzip2 ./"$n"     ;;
          *.rar)       unrar x -ad ./"$n" ;;
          *.gz)        gunzip ./"$n"      ;;
          *.zip)       unzip ./"$n"       ;;
          *.z)         uncompress ./"$n"  ;;
          *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar)
                        7z x ./"$n"        ;;
          *.xz)        unxz ./"$n"        ;;
          *.exe)       cabextract ./"$n"  ;;
          *)
            echo "extract: '$n' - unknown archive method"
            return 1
            ;;
        esac
      else
          echo "'$n' - file does not exist"
          return 1
      fi
  done
fi
}

# Creates an archive (*.tar.gz) from given directory.
function maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }

# Create a ZIP archive of a file or folder.
function makezip() { zip -r "${1%%/}.zip" "$1" ; }

function tree() {
  local level=1
  if [ -n "$1" ]; then
    # validate that the argument is a number
    if [[ "$1" =~ ^[0-9]+$ ]]; then
      level=$1
      shift
    fi
  fi
  ls --tree -L $level $@
}

# Generate a gitignore file from gitignore.io
# https://docs.gitignore.io
function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@ ;}

pbfile() {
  osascript \
  -e 'on run args' \
  -e 'set the clipboard to POSIX file (first item of args)' \
  -e end \
  "$@"
}

# function defaults() {
#   git pull ~/Github/defaults
#   for i in `\ls ~/Github/defaults`; do
#   # Prompt for each thing
#   done
# }

# function grep() {
#   rg --color=always --hidden --smart-case --no-ignore --no-ignore-parent --json -C 2 "$@" | delta
# }

# turn this into a function
# alias aider="aider --openai-api-key "$(op read 'op://Personal/auth0.openai.com/API Keys/aider-chat')" --35turbo --no-auto-commits"
