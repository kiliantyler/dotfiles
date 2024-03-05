# check if command exists before running it
if command -v systemd-detect-virt &> /dev/null
then
    VIRT_TYPE=$(systemd-detect-virt)
else
    VIRT_TYPE=""
fi

if [ "$VIRT_TYPE" = "wsl" ]; then
alias ssh='ssh.exe'
git config --system core.sshCommand ssh.exe
fi
