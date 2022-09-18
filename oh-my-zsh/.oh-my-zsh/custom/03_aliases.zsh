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

# `ls` aliases
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.

# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll='ls -lathv --group-directories-first'
alias lm='ll | more'        #  Pipe through 'more'
alias lr='ll -R'           #  Recursive ls.
alias la='ll -A'           #  Show hidden files.
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...

# Kubernetes
alias k='kubectl'

# Bat
alias cat='bat --paging=never'
alias catc='bat -pp'

# Helm
alias h='helm'
alias hui='h upgrade --install'
alias hru='h repo update'
alias hdb='h dependency build'

# Misc
alias path='echo -e ${PATH//:/\\n}'
alias myip='curl http://ipecho.net/plain; echo'
alias upgrade='topgrade'
alias brew_lock="rm -rf $(brew --prefix)/var/homebrew/locks"

# just a better Docker printout
alias dps='docker ps --format "table {{.Names}}\t{{.RunningFor}}\t{{.Status}}"'

alias lsblk='lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT'