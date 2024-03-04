#!/usr/bin/env/zsh

sourceFiles=(
  "$(brew --prefix)/opt/git-extras/share/git-extras/git-extras-completion.zsh"
  "${HOME}/.cargo/env"
  "${HOME}/.config/op/plugins.sh"
)

for source in ${sourceFiles[@]}; do
  if [ -f "${source}" ]; then
    . "${source}"
  fi
done

. <(flux completion zsh)
eval "$(zoxide init zsh --cmd cd)"