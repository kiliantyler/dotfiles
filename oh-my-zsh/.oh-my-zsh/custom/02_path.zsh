#!/usr/bin/env zsh

paths=(
  "${HOME}/.pyenv/shims"
  "$(brew --prefix)/opt/coreutils/libexec/gnubin"
  "$(brew --prefix)/opt/gnu-sed/libexec/gnubin"
  "$(brew --prefix)/opt/findutils/libexec/gnubin"
  "$(brew --prefix)/unzip/bin"
  "${HOME}/.rd/bin"
  "${HOME}/.local/bin"
  "${HOME}/.dotnet/tools"
  "${HOME}/Github/mac-setup/bin"
  "${GOPATH}/bin"
)

EXPORT_PATH="${PATH}"

for path in ${(Oa)paths[@]}; do
  if [[ ${EXPORT_PATH} = *"${path}"* ]]; then continue; fi
  EXPORT_PATH="${path}:${EXPORT_PATH}"
done

export PATH=${EXPORT_PATH}
