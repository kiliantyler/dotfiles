#!/usr/bin/env zsh

brewDir=(
  "/opt/homebrew"
  "/usr/local"
  "/home/linuxbrew/.linuxbrew"
)

for dir in ${brewDir[@]}; do
  if [ -f "${dir}/bin/brew" ]; then
    eval "$(${dir}/bin/brew shellenv)"
  fi
done
