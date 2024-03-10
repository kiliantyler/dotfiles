#!/usr/bin/env bash

# # bash <( curl -L https://raw.githubusercontent.com/kiliantyler/dotfiles/main/remote_install.sh)

source /dev/stdin <<< "$(curl -sL https://gist.github.com/kiliantyler/18622c8002bcc30386021f22eff5ba08/raw/test.sh)"

# shellcheck disable=SC2016
if [[ -z "${NONINTERACTIVE-}" ]]; then
  if [[ ! -t 0 ]]; then
    if [[ -z "${INTERACTIVE-}" ]]; then
      .log -l 4 'Running in non-interactive mode because `stdin` is not a TTY.'
      NONINTERACTIVE=1
    else
      .log -l 4 'Running in interactive mode despite `stdin` not being a TTY because `$INTERACTIVE` is set.'
    fi
  fi
else
  ohai 'Running in non-interactive mode because `$NONINTERACTIVE` is set.'
fi

if [ "$EUID" -eq 0 ]; then
  echo "Do not run this as root"
  exit 1
fi

DOTFILES_SOURCE="https://github.com/kiliantyler/dotfiles"
DOTFILES_TARBALL="$DOTFILES_SOURCE/tarball/master"
DOTFILES_TARGET="$HOME/dotfiles"
DOTFILES_TAR_CMD="tar -xzv -C \"${DOTFILES_TARGET}\" --strip-components=1 --exclude='{.gitignore}'"
SETUP_SOURCE="https://github.com/kiliantyler/mac-setup"
SETUP_TARBALL="$SETUP_SOURCE/tarball/master"
SETUP_TARGET="$HOME/mac-setup"
SETUP_TAR_CMD="tar -xzv -C \"${SETUP_TARGET}\" --strip-components=1 --exclude='{.gitignore}'"

is_executable() {
  type "$1" > /dev/null 2>&1
}
if [ -x "$(command -v xcode-select)" ]; then
  check=$( (xcode-select --install) 2>&1)
  echo $check
  str="xcode-select: note: install requested for command line developer tools"
  while [[ "$check" == "$str" ]]; do
    # echo "Installing xcode tools"
    sleep 1
  done
fi

if is_executable "git"; then
  CMD="git clone $DOTFILES_SOURCE $DOTFILES_TARGET"
  CMD2="git clone $SETUP_SOURCE $SETUP_TARGET"
elif is_executable "curl"; then
  CMD="curl -#L $DOTFILES_TARBALL | $DOTFILES_TAR_CMD"
  CMD2="curl -#L $SETUP_TARBALL | $SETUP_TAR_CMD"
elif is_executable "wget"; then
  CMD="wget --no-check-certificate -O - $DOTFILES_TARBALL | $DOTFILES_TAR_CMD"
  CMD2="wget --no-check-certificate -O - $SETUP_TARBALL | $SETUP_TAR_CMD"
fi

if [ -z "$CMD" ]; then
  echo "No git, curl or wget available. Aborting."
  exit 1
else
  echo "Installing dotfiles..."
  mkdir -p "$DOTFILES_TARGET"
  mkdir -p "$SETUP_TARGET"
  eval "$CMD"
  eval "$CMD2"
fi

if [ -x "$(command -v apt-get)" ]; then
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential procps curl file git make zsh
elif [ -x "$(command -v yum)" ]; then
  sudo yum groupinstall 'Development Tools'
  sudo yum install procps-ng curl file git
  sudo yum install libxcrypt-compat
  echo "Cannot install required packages, distrobution probably not supported">&2
  exit 1
fi

cd "${SETUP_TARGET}" || exit
# if ! make V=5; then echo "There was an error"; exit 1; fi
