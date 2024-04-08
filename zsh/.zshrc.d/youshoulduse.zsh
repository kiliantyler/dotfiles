#!/usr/bin/env zsh

## Aliases that I don't want to see tips for
aliasesToIgnore=(
  "_"
  "apt"
)

IGNORE_ALIASES=""

for alias in ${(Oa)aliasesToIgnore[@]}; do
  if [[ ${IGNORE_ALIASES} = *"${alias}"* ]]; then continue; fi
  IGNORE_ALIASES="${alias} ${IGNORE_ALIASES}"
done

export ZSH_PLUGINS_ALIAS_TIPS_EXCLUDES="${IGNORE_ALIASES}"
