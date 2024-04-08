#!/usr/bin/env zsh

## Various changes needed for WSL to keep dotfiles universal

# check if command exists before running it
if command -v systemd-detect-virt &>/dev/null; then
  VIRT_TYPE=$(systemd-detect-virt)
else
  VIRT_TYPE=""
fi

if [ "$VIRT_TYPE" = "wsl" ]; then
  ## Use Windows' ssh.exe instead of the one from Git for Windows
  # This allows 1password to work with ssh properly in WSL
  alias ssh='ssh.exe'
  git config --system core.sshCommand ssh.exe
fi
