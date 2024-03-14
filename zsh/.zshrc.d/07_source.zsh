#!/usr/bin/env/zsh

sourceFiles=(
  "$(brew --prefix)/opt/git-extras/share/git-extras/git-extras-completion.zsh"
  "${HOME}/.cargo/env"
  "${HOME}/.config/op/plugins.sh"
  "${XDG_CONFIG_HOME}/fzf/fzf.zsh"
  "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"
  "${HOME}/.iterm2_shell_integration.zsh"
)

evalSourcePrograms=(
  "flux completion zsh"
  "cod init $$ zsh"
)

evalCommands=(
  # "zoxide init zsh"
  "atuin init zsh --disable-up-arrow --disable-ctrl-r"
)

for source in ${sourceFiles[@]}; do
  if [ -f "${source}" ]; then
    . "${source}"
  fi
done

for evalSource in "${evalSourcePrograms[@]}"; do
  command=$(echo $evalSource | awk '{print $1}')
  if command -v $command &>/dev/null; then
    . <(eval "${evalSource}")
  fi
done

for evalCommand in "${evalCommands[@]}"; do
  command=$(echo $evalCommand | awk '{print $1}')
  if command -v $command &>/dev/null; then
    evalString=$(eval ${evalCommand})
    eval "${evalString}"
  fi
done
