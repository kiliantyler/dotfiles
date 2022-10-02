#!/usr/bin/env bash

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

if is_executable "make"; then
  cd "${SETUP_TARGET}" || exit
  make V=5
else
  echo "No 'make' available, please install then run 'make' in ${SETUP_TARGET}"
  exit 1
fi