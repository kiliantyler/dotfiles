alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
alias reload='exec zsh'

# More `ls` aliases
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.

# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lathv --group-directories-first"
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

# just a better Docker printout
alias dps='docker ps --format "table {{.Names}}\t{{.RunningFor}}\t{{.Status}}"'

alias lsblk='lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT'