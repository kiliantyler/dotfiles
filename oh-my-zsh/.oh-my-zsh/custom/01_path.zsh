#!/usr/bin/env/zsh
eval "$(/opt/homebrew/bin/brew shellenv)"

paths=(
  "$(brew --prefix)/opt/coreutils/libexec/gnubin"
  "$(brew --prefix)/opt/gnu-sed/libexec/gnubin"
  "$(brew --prefix)/opt/findutils/libexec/gnubin"
  "$(brew --prefix)/unzip/bin"
  "/Users/kilian/.rd/bin"
  "/Users/kilian/.local/bin"
)

EXPORT_PATH="${PATH}"
export ORG_PATH=${PATH}

for path in ${(Oa)paths[@]}; do
  if [[ ${EXPORT_PATH} = *"${path}"* ]]; then continue; fi
  EXPORT_PATH="${path}:${EXPORT_PATH}"
done

export PATH=${EXPORT_PATH}