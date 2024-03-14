function nvm() {
  echo "🚨 NVM not loaded! Loading now..."
  unset -f nvm
  export NVM_PREFIX=$(brew --prefix nvm)
  [ -s "$NVM_PREFIX/nvm.sh" ] && . "$NVM_PREFIX/nvm.sh"
  [ -s "$NVM_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && . "$NVM_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
  nvm "$@"
}
