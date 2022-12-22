#!/usr/bin/env/zsh

sourceFiles=(
  "$(brew --prefix)/opt/git-extras/share/git-extras/git-extras-completion.zsh"
  "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"
  "${HOME}/.cargo/env"
  "$(brew --prefix)/opt/asdf/libexec/asdf.sh"
  "${HOME}/.config/op/plugins.sh"
)

for source in ${sourceFiles[@]}; do
  if [ -f "${source}" ]; then
    . "${source}"
  fi
done