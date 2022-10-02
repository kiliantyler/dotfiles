#!/usr/bin/env zsh

brewDir=(
  "/opt/homebrew"
  "/usr/local"
)

for dir in ${brewDir[@]}; do
  if [ -f "${dir}/bin/brew" ]; then
    eval "$(${dir}/bin/brew shellenv)"
  fi
done

paths=(
  "$(brew --prefix)/opt/coreutils/libexec/gnubin"
  "$(brew --prefix)/opt/gnu-sed/libexec/gnubin"
  "$(brew --prefix)/opt/findutils/libexec/gnubin"
  "$(brew --prefix)/unzip/bin"
  "${HOME}/.rd/bin"
  "${HOME}/.local/bin"
  "${HOME}/.dotnet/tools"
)

EXPORT_PATH="${PATH}"
export ORG_PATH=${PATH}

for path in ${(Oa)paths[@]}; do
  if [[ ${EXPORT_PATH} = *"${path}"* ]]; then continue; fi
  EXPORT_PATH="${path}:${EXPORT_PATH}"
done

export PATH=${EXPORT_PATH}