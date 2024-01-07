VIRT_TYPE=$(systemd-detect-virt)

if [ $VIRT_TYPE = "wsl" ]; then

alias ssh='ssh.exe'
git config --system core.sshCommand ssh.exe
fi