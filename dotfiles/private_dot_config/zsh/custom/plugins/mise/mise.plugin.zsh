#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# Zsh Plugin Standard
# https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
typeset -gA Plugins
Plugins[ZSH_MISE]="${0:h}"

# https://wiki.zshell.dev/community/zsh_plugin_standard#funtions-directory
if [[ $PMSPEC != *f* ]]; then
  fpath+=( "${0:h}/functions" )
fi

# https://wiki.zshell.dev/community/zsh_plugin_standard#global-parameter-with-capabilities
if [[ $PMSPEC == *P* ]]; then
  _ZO_DATA_DIR=${ZPFX}/share
fi


if (( ! $+commands[mise] )); then
  print "Please install mise or make sure it is in your PATH"
  print "More info: https://mise.jdx.dev/getting-started.html"
  exit 1
fi

# check if @zsh-eval-cache is loaded
if (( $+functions[@zsh-eval-cache] )); then
  @zsh-eval-cache ~/.local/bin/mise activate zsh
else
  eval "$(~/.local/bin/mise activate zsh)"
fi
