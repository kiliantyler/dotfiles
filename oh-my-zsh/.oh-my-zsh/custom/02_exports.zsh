export UPDATE_ZSH_DAYS=1
export ZSH_PLUGINS_ALIAS_TIPS_TEXT="Alias: "
export ZSH_PLUGINS_ALIAS_TIPS_EXCLUDES="_"
export KUBECONFIG=$(python3 -c "import glob;print(':'.join(glob.glob('$HOME/.kube/config-files/*.yaml')))")