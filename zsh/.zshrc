#!/usr/bin/env zsh

# TODO: Move comments to a file
# TODO: Make docs a website generated
# TODO: Completions are messed up

### Main zinit Setup ###
## Zinit is a plugin manager for zsh (https://github.com/zdharma-continuum/zinit) ##
# Establish the zinit environment
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
### END Main zinit Setup ###

### zinit Annexes ###

## Allows for installing plugins without the Github username
# as well as some default repos (https://github.com/zdharma-continuum/zinit-annex-unscope)
zinit light zdharma-continuum/zinit-annex-unscope

# Rust to install cargo programs (https://github.com/zdharma-continuum/zinit-annex-rust)
zinit light zdharma-continuum/zinit-annex-rust

# Allows binaries to be installed easily without compiling them (https://github.com/zdharma-continuum/zinit-annex-bin-gem-node)
zinit light zdharma-continuum/zinit-annex-bin-gem-node

# Allowes for URL installs (https://github.com/zdharma-continuum/zinit-annex-readurl)
zinit light zdharma-continuum/zinit-annex-readurl

# Downloads files and applies patches (https://github.com/zdharma-continuum/zinit-annex-patch-dl)
zinit light zdharma-continuum/zinit-annex-patch-dl

# Allows setting ice defaults (https://github.com/zdharma-continuum/zinit-annex-default-ice)
zinit light zdharma-continuum/zinit-annex-default-ice

# Allowed for modules to have submodules (https://github.com/zdharma-continuum/zinit-annex-submods)
zinit light zdharma-continuum/zinit-annex-submods

# Allows for setting up symlinks (https://github.com/zdharma-continuum/zinit-annex-binary-symlink)
zinit light zdharma-continuum/zinit-annex-binary-symlink

# Allows evals to be run for programs (https://github.com/vladdoster/z-a-eval)
zinit light vladdoster/z-a-eval

# Allows setting of aliases in `fbin` and `sbin` ices ()
zinit light kiliantyler/zinit-annex-alias

### END zinit Annexes ###

### Theme ###
## Powerlevel10k (https://github.com/romkatv/powerlevel10k)
# This installs the powerlevel10k theme
# The configuration file is .p10k.zsh
zinit ice id-as'theme/p10k' \
  depth'1' atload"[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" nocd
zinit light romkatv/powerlevel10k
### END Theme ###

## CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] &&
  zinit snippet "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

### Programs ###

## Homebrew (https://brew.sh)
# TODO: Clean this up as much as possible
# This is super complicated and I would love to replace it with a simpler method
# However this allows existing homebrew installations to be used
# as well as allowing for the installation of homebrew on Linux
# This also places brew in the correct location so that Cellars can be installed properly
zinit wait'0' lucid depth'3' as'program' pick'bin/brew' \
  atclone'\
    +zi-log "{happy}Installing {ice}brew{happy}...{rst}"; \
    local brewDir="/opt/homebrew";
    [[ $(uname -o) != "Darwin" ]] && brewDir="/home/linuxbrew/.linuxbrew" && \
    sudo mkdir /home/linuxbrew; \
    local brewPluginDir="$(pwd)"; \
    if [[ ! -d "$brewDir" ]]; then \
    +zi-log "{ice}Brew{w} not found already!{rst}"; \
    sudo mv "$brewPluginDir" "$brewDir";
    local user=$(whoami); \
    sudo chown -R $user "$brewDir"; \
    command ln -s "$brewDir" "$brewPluginDir"; \
    command cd "$brewPluginDir"; \
    ./bin/brew update --preinstall; \
    else \
    +zi-log "{happy}Previous {ice}brew{happy} install found! Symlinking..."; \
    command rm -rf "$brewPluginDir"; \
    command ln -s "$brewDir" "$brewPluginDir"; \
    fi; \
    +zi-log "{happy}Installing {ice}brew{happy} completions...{rst}"; \
    command mkdir -p ${ZPFX}/completions; \
    command cp -f $brewPluginDir/share/zsh/site-functions/_* ${ZPFX}/completions; \
    zinit creinstall -q $brewPluginDir/share/zsh/site-functions; \
    +zi-log "{ice}brew{happy} install complete!{rst}"' \
  atpull'%atclone' run-atpull for \
  @homebrew/brew

## Some useful zinit extras
# TODO: These can move into another block
## ZUI library that is used by zinit-console and zbrowse () ##
## zinit-console allows visibility into what zinit has set up () ##
## zplugin-crasis is another debug tool for zinit () ##
## zbrowse -- allows you to see variables and histories (https://github.com/zdharma-continuum/zbrowse) ##
zinit wait lucid for \
  zdharma-continuum/zui \
  zdharma-continuum/zinit-console \
  zdharma-continuum/zinit-crasis \
  zdharma-continuum/zbrowse

## FZF - fuzzy finder (https://github.com/junegunn/fzf)
# Sets up fzf as well as the completions and keybindings
# TODO: This needs to be improved heavily
zinit \
  atclone'command mkdir -p $ZPFX/{bin,man/man1}' \
  atpull'%atclone' \
  dl'https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh -> _fzf_completion;' \
  dl'https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh -> key-bindings.zsh;' \
  dl'https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf-tmux.1 -> $ZPFX/man/man1/fzf-tmux.1;' \
  dl'https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf.1 -> $ZPFX/man/man1/fzf.1' \
  from'gh-r' \
  id-as'app/fzf' \
  wait \
  lucid \
  nocompile \
  pick'/dev/null' \
  sbin'fzf' \
  src'key-bindings.zsh' \
  for @junegunn/fzf

## Atuin -- history manager (https://atuin.sh)
## Direnv - Load environment variables per directory (https://github.com/direnv/direnv)

## Install Rust and Cargo
# TODO: Cleanup
zi for \
  atload='export CARGO_HOME=$PWD RUSTUP_HOME=$PWD/rustup' \
  atpull='%atclone' \
  as=null \
  id-as=rust \
  lucid \
  rustup \
  sbin="bin/*" \
  wait=1 \
  zdharma-continuum/null

# TODO: Rust installs

# ## pyenv (https://github.com/pyenv/pyenv)
# zinit lucid wait as'command' id-as'app/pyenv' atinit'export PYENV_ROOT="$PWD"' \
#   nocompile'!' pick'bin/pyenv' eval'pyenv init -' for \
#   pyenv/pyenv

## rye
zinit lucid wait'!' as'null' from'gh-r' for \
  id-as'app/rye' sbin'rye* -> rye' \
  atclone'./rye* self install --yes' atpull'%atclone' \
  @astral-sh/rye

# TODO: Python installs

## nvm (https://github.com/nvm-sh/nvm)
zinit lucid wait as'null' id-as'app/nvm' atinit'export NVM_DIR="$PWD";' \
  nocompile'!' \
  eval'cat nvm.sh' for nvm-sh/nvm
# Install the LTS version of node
zinit lucid wait has'nvm' as'null' id-as'app/nvmlts' \
  atclone'nvm install --lts' atpull'%atclone' \
  for zdharma-continuum/null

# TODO: Other node installs

## Yeoman generator (https://yeoman.io)
zinit lucid wait has'nvm' as'null' \
  id-as'node/yo' node'yo <- !yo -> yo' \
  for zdharma-continuum/null

## Static installs
# a good example of how multiple installs can be done with one zinit command
## StaticInstalls.mdx
ghr_installs=(
  id-as'app/aliae' sbin'aliae* -> aliae' eval'aliae init zsh' jandedobbeleer/aliae
  id-as'app/atuin' sbin'**/atuin' eval'atuin init zsh --disable-up-arrow' atuinsh/atuin
  id-as'app/bat-extras' sbin"bin/*" eth-p/bat-extras
  id-as'app/bat' sbin"**/bat" alias'cat' @sharkdp/bat
  id-as'app/delta' sbin'**/delta -> delta' dandavison/delta
  id-as'app/direnv' sbin'direnv* -> direnv' eval'direnv hook zsh' direnv/direnv
  id-as'app/eza' sbin'**/eza -> eza' alias'ls' kiliantyler/eza-releaser
  id-as'app/fd' sbin"**/fd" alias'find' @sharkdp/fd
  id-as'app/flux' sbin'flux' eval'flux completion zsh' fluxcd/flux2
  id-as'app/g' sbin'g' nocompile voidint/g
  id-as'app/gh' sbin'gh' cli/cli
  id-as'app/helm' sbin'helm' kiliantyler/helm-releaser
  id-as'app/jq' sbin'* -> jq' nocompile @jqlang/jq
  id-as'app/k9s' sbin'k9s' derailed/k9s
  id-as'app/kubecolor' sbin'kubecolor' alias'kubectl' kubecolor/kubecolor
  id-as'app/kubectx' sbin'kubectx;kubens' bpick'kubectx;kubens' ahmetb/kubectx
  id-as'app/popeye' sbin'popeye' derailed/popeye
  id-as'app/rg' sbin'**/rg -> rg' BurntSushi/ripgrep
  id-as'app/tenv' sbin'tenv' eval'tenv completion zsh' tofuutils/tenv #TODO: Q Completions
  id-as'app/yq' sbin'* -> yq' nocompile mikefarah/yq
  id-as'app/zoxide' sbin'zoxide' ajeetdsouza/zoxide #TODO: Not being aliased to cd
  id-as'kubectl/blame' sbin'kubectl-blame' knight42/kubectl-blame
  id-as'app/doge' sbin'doge* -> doge' alias'dig' Dj-Codeman/doge
  id-as'app/gotask' sbin'task' go-task/task
  id-as'app/talosctl' sbin'talosctl* -> talosctl' siderolabs/talos
)
zinit wait as'null' completions lucid from:gh-r for \
  $ghr_installs[@]

## TODO:
# kubectl - go build sadly
# pre-commit -- python?
# rbenv
# sops
# topgrade
#
# Things:
# Raycast plugins
# VSCode extensions
# VSCode Project Manager plugin

## Zoxide plugin
# It uses the alias set in the _ZO_CMD_PREFIX variable
_ZO_CMD_PREFIX='cd'
# TODO: Fork this?
# zinit has'zoxide' wait lucid for \
#   z-shell/zsh-zoxide

## Git Extras (https://github.com/tj/git-extras)
# TODO: completions -> zi creinstall
zinit lucid wait for \
  as'null' sbin"bin/git-*" id-as'app/git-extras' \
  tj/git-extras # src"etc/git-extras-completion.zsh"

## iTerm2 shell integration (https://iterm2.com)
# https://github.com/gnachman/iTerm2-shell-integration
zinit lucid wait as'null' for \
  sbin"utilities/*" \
  src"shell_integration/zsh" \
  gnachman/iTerm2-shell-integration

### END PROGRAMS ###

### Plugins ###

zinit wait lucid light-mode for \
  id-as"plugin/ysu" MichaelAquilina/zsh-you-should-use

### END Plguins ###

### Snippets ###

# Load snippets from the .zshrc.d folder
[[ -d "${HOME}/.zshrc.d" ]] && for file in "${HOME}/.zshrc.d"/*; do
  zinit ice wait"0" lucid id-as"snippet/${file:t}"
  zinit snippet $file
done

## Load 1password plugins
if [[ -f "${HOME}/.config/op/plugins.sh" ]]; then
  zinit ice wait lucid id-as"snippet/op_plugins.sh"
  zinit snippet "${HOME}/.config/op/plugins.sh"
fi

### END Snippets ###

### Finale ###

## System completions
zinit id-as'system-completions' as'null' wait lucid \
  atclone'print Installing system completions...; \
    zinit creinstall -Q /usr/share/zsh/$ZSH_VERSION/functions' \
  atpull'%atclone' run-atpull for \
  zdharma-continuum/null

## This loads zicompinit and zicdreplay at the end of .zshrc
# These allow zinit to take over completions and significantly speed up shell startup
# It also requires fzf-tab plugin to be at the end of the completions list
# Syntax highlighting for the shell (https://github.com/zdharma-continuum/fast-syntax-highlighting)
# This is a plugin that highlights commands as you type them
# Needs to be at the towards the end of the .zshrc file
zinit wait lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
  zdharma-continuum/fast-syntax-highlighting \
  zsh-users/zsh-completions
# TODO: fzf-tab

## CodeWhisperer post block. Keep at the bottom of this file.
[[ $(uname) == "Darwin" ]] && (
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && \
zinit snippet "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" || \
(+zi-log "{w}Codewhisper not found. Please install it from homebrew.{rst}" && +zi-log "{ice}brew install --cask codewhisperer{rst}"))

## Only run this on the first shell startup
[[ ! -f "${ZINIT_HOME}/.firstrun" ]] &&
  (touch "${ZINIT_HOME}/.firstrun" &&
    +zi-log "{ice}Zinit{happy} is ready to go!{rst}") || true

### END Finale ###
