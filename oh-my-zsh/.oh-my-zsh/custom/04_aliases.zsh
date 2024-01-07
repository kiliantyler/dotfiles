##  Kubernetes has its own file ##

alias python='python3'

alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
alias reload='exec zsh'

# Colors
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

# Grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Pretty readouts
alias du='du -kh'
alias df='df -kTh'
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

## ls ##
# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll='ls -lathv --group-directories-first'
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.
alias lm='ll | more'       #  Pipe through 'more'
alias lr='ll -R'           #  Recursive ls.
alias la='ll -A'           #  Show hidden files.
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...

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
alias kubeclean="for file in `ls ~/.kube/config-files`; do yq 'del(.clusters[0].cluster.certificate-authority-data)' ~/.kube/config-files/${file} --inplace; done"
# .brew is used in the mac-setup repo
if [ -e .brew ]; then
  alias brew='.brew'
fi


## Terraform ##
alias tfinit='terraform init'
alias tf11='tfenv use 0.11.15'
alias tf12='tfenv use 0.12.31'
alias tf12up='tf12 && terraform 0.12upgrade -yes'
alias tf13='tfenv use 0.13.7'
alias tf13up='tf13 && terraform 0.13upgrade -yes'
alias tf15='tfenv use 0.15.5'


## WSL ##
VIRT_TYPE=$(systemd-detect-virt)

if [ $VIRT_TYPE = "wsl" ]; then
alias ssh='ssh.exe'
fi