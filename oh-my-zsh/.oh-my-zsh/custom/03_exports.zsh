#!/usr/bin/env zsh

export UPDATE_ZSH_DAYS=1
export ZSH_PLUGINS_ALIAS_TIPS_TEXT="Alias: "
export MANPATH="/usr/local/man:$MANPATH"
export KUBECONFIG=$(python3 -c "import glob;print(':'.join(glob.glob('$HOME/.kube/config-files/*.yaml')))")
export XDG_CONFIG_HOME="${HOME}/.config"

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
export SOPS_AGE_KEY_FILE="${HOME}/.config/sops/age/keys.txt"
export FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
export NVM_DIR="$HOME/.nvm"
export GOPATH="$HOME/go"
export GOROOT="$HOME/.go"
