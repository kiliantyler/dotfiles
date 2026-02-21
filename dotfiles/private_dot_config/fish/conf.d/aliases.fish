if status is-interactive
    # Aliases
    alias maude "clear & ssh -t maude 'cc'"
    alias claude 'command claude --dangerously-skip-permissions'

    if type -q eza
        alias ls 'eza --icons=auto --color=auto'
    end

    if type -q bat
        alias cat bat
    end

    if type -q kubecolor
        alias kubectl kubecolor
    end
end
