#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# Zsh Plugin Standard
# https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
typeset -gA Plugins
Plugins[KILT_COMPLETION]="${0:h}"

# PMSPEC (functions)
if [[ $PMSPEC != *f* ]]; then
  fpath+=( "${0:h}/functions" )
fi

# PMSPEC (bin)
if [[ $PMSPEC != *b* ]]; then
  path+=( "${0:h}/bin" )
fi

# https://wiki.zshell.dev/community/zsh_plugin_standard#global-parameter-with-capabilities
if [[ $PMSPEC == *P* ]]; then
  _ZO_DATA_DIR=${ZPFX}/share
fi

#
# Requirements
#

if [[ "$TERM" == 'dumb' ]]; then
  return 1
fi

local completions_dir="${0:A:h}/completions"

mkdir -p "${completions_dir}"

# Add folder to store completions
fpath+="${completions_dir}"

fpath+="${0:A:h}/functions"
echo "$PATH"

autoload -Uz __gencom_kubectl && __gencom_kubectl "$completions_dir"


