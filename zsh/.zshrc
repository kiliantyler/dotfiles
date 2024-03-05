typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="false"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 2

plugins=(
alias-tips
colorize
copybuffer
copyfile
copypath
dirhistory
fzf-tab
git
history-substring-search
kubectl
zsh-autosuggestions
zsh-syntax-highlighting
pipenv
pdm
autoswitch_virtualenv
zsh-fzf-history-search
)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
fpath+=~/.zfunc
source $ZSH/oh-my-zsh.sh


# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Plugin Options
ZSH_CUSTOM_AUTOUPDATE_QUIET=true
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

autoload -Uz compinit && compinit
enable_autoswitch_virtualenv
