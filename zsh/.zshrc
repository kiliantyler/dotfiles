# zmodload zsh/zprof

# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
zinit ice depth"1" lucid
zinit light romkatv/powerlevel10k

HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="false"
# ZSH_TMUX_AUTOSTART=true
# ZSH_TMUX_AUTOCONNECT=false

# zstyle ':omz:update' mode auto
# zstyle ':omz:update' frequency 2

zinit snippet OMZP::git/git.plugin.zsh
zinit snippet OMZP::colorize/colorize.plugin.zsh
zinit snippet OMZP::copybuffer/copybuffer.plugin.zsh
zinit snippet OMZP::copyfile/copyfile.plugin.zsh
zinit snippet OMZP::copypath/copypath.plugin.zsh
zinit snippet OMZP::dirhistory/dirhistory.plugin.zsh
zinit snippet OMZP::kubectl/kubectl.plugin.zsh
zinit snippet OMZP::pipenv/pipenv.plugin.zsh
zinit snippet OMZP::tmux/tmux.plugin.zsh

zinit ice wait"0" lucid
zinit light MichaelAquilina/zsh-you-should-use # TODO: Configure this plugin
zinit ice wait"0" lucid
zinit light MichaelAquilina/zsh-autoswitch-virtualenv
zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
zinit ice wait"0" lucid
zinit light zsh-users/zsh-syntax-highlighting
zinit ice wait"0" lucid
zinit light zsh-users/zsh-completions
zinit ice wait"0" lucid
zinit light zsh-users/zsh-history-substring-search
zinit ice wait"0" lucid pick'poetry.zsh'
zinit light sudosubin/zsh-poetry
zinit ice wait"0" lucid
zinit light Aloxaf/fzf-tab
zinit ice wait"0" lucid
zinit light zdharma-continuum/fast-syntax-highlighting

for file in ~/.zshrc.d/*; do
  zinit ice wait"0" lucid
  zinit snippet $file
done

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/opt/homebrew/sbin"

# fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
# fpath+=~/.zfunc
# source $ZSH/oh-my-zsh.sh

# # Preferred editor for local and remote sessions
# # if [[ -n $SSH_CONNECTION ]]; then
# #   export EDITOR='vim'
# # else
# #   export EDITOR='mvim'
# # fi

# # Plugin Options
# ZSH_CUSTOM_AUTOUPDATE_QUIET=true
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# # Only hit the compinit cache once a day
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C
# enable_autoswitch_virtualenv

zstyle ':completion:*' menu select
# complete -o nospace -C /opt/homebrew/bin/bit bit
# eval "$(direnv hook zsh)"
# zprof
