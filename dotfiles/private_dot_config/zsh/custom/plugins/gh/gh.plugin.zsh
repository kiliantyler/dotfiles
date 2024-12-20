#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# Autocompletion for the GitHub CLI (gh).
if (( ! $+commands[gh] )); then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `gh`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_gh" ]]; then
  typeset -g -A _comps
  autoload -Uz _gh
  _comps[gh]=_gh
fi

gh completion --shell zsh >| "$ZSH_CACHE_DIR/completions/_gh" &|
