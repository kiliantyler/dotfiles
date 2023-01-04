export UPDATE_ZSH_DAYS=1
export ZSH_PLUGINS_ALIAS_TIPS_TEXT="Alias: "
export ZSH_PLUGINS_ALIAS_TIPS_EXCLUDES="_"
export MANPATH="/usr/local/man:$MANPATH"
export KUBECONFIG=$(python3 -c "import glob;print(':'.join(glob.glob('$HOME/.kube/config-files/*.yaml')))")
export SOPS_AGE_KEY_FILE="${HOME}/.config/sops/age/keys.txt"