#!/bin/sh
# Bootstrap a fresh Mac: Xcode CLT, chezmoi, then `chezmoi init --apply`.
# Served to `curl -fsSL https://install.dotfiles.wiki/<github-user> | sh` by cloudflare/.
set -eu

[ "$(uname -s)" = "Darwin" ] || { echo "macOS only" >&2; exit 1; }

if [ ! -e /Library/Developer/CommandLineTools/usr/bin/git ]; then
  echo "Installing Xcode Command Line Tools"
  xcode-select --install
  until [ -e /Library/Developer/CommandLineTools/usr/bin/git ]; do sleep 5; done
fi

command -v chezmoi >/dev/null 2>&1 || sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"

"$HOME/.local/bin/chezmoi" init --apply "{{USERNAME}}"
