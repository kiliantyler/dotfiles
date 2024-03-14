#!/usr/bin/env zsh

##  Kubernetes has its own file ##

alias python='python3'

alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
alias reload='exec zsh'

# Colors
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

# Grep
# Lives in function file

# Pretty readouts'
alias free='free -m -l -t -h'

# Prevents accidentally clobbering files.
alias rm='rm -I --preserve-root'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias wget='wget -c'

# less is more and more is most
alias less='most'
alias more='most'

# Replace ls with eza
alias ls='eza --no-quotes --group-directories-first -w120'
alias ll='ls -1a'
alias la='ls -a'
alias lll='ls -lga --smart-group --time-style="+%Y-%m-%d %H:%M:%S" --sort name'
alias lt='tree'
alias lm='lll | most'
alias lf='ll -f'
alias ld='ll -D'
alias lls='lll --total-size'
alias lg='ls -l --no-permissions --no-user --git --git-repos --git-ignore -a'

## Bat ##
alias cat='bat --paging=never'
alias catc='bat -pp'

## Helm ##
alias h='helm'
alias hui='h upgrade --install'
alias hru='h repo update'
alias hdb='h dependency build'
alias hra='h repo add'

## Misc ##
alias path='echo -e ${PATH//:/\\n}'
alias myip='curl http://ipecho.net/plain; echo'
alias upgrade='topgrade'
alias brew_lock="rm -rf $(brew --prefix)/var/homebrew/locks"
alias cls='clear'
# just a better Docker printout
alias dps='docker ps --format "table {{.Names}}\t{{.RunningFor}}\t{{.Status}}"'
alias lsblk='lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT'
alias kubeclean="for file in $(ls ~/.kube/config-files); do yq 'del(.clusters[0].cluster.certificate-authority-data)' ~/.kube/config-files/${file} --inplace; done"

# .brew is used in the mac-setup repo
if command -v .brew &>/dev/null; then
  alias brew='.brew'
else
  echo "no .brew"
  path
fi

alias kubeclean="for file in $(\ls ~/.kube/config-files); do yq 'del(.clusters[0].cluster.certificate-authority-data)' ~/.kube/config-files/${file} --inplace; done"

## Terraform ##
alias tfinit='terraform init'
alias tf11='tfenv use 0.11.15'
alias tf12='tfenv use 0.12.31'
alias tf12up='tf12 && terraform 0.12upgrade -yes'
alias tf13='tfenv use 0.13.7'
alias tf13up='tf13 && terraform 0.13upgrade -yes'
alias tf15='tfenv use 0.15.5'

## WSL has its own file ##

alias apt='brew'

alias du='dust -w 120'

alias ps='procs'

alias dig='dog'

alias top='btop'

alias gitignore='curl -L -s https://www.gitignore.io/api/$@'

alias yq='yq -P -e -I 2'

alias c='clear'

alias header='python ~/Github/make-hash/hash.py'

# allows me to use `g` while keeping git alias
alias govm='\g'

alias which="type -a"

alias git='bit'
