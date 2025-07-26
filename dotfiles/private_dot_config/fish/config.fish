if status is-interactive

    fish_add_path ~/.local/bin
    fish_add_path ~/.bin

    # Theme - ./themes/Dracula Official.theme
    fish_config theme choose "Dracula Official"

    # Remove greeting
    set -g fish_greeting

    # Path
    set -gx PATH $PATH $HOME/.krew/bin # Krew plugins

    # Programs
    atuin init fish --disable-up-arrow | source

    # # Completions
    # mise completions fish | source //mise completion fish > ~/.config/fish/completions/mise.fish
    atuin gen-completions --shell fish | source
    kubectl completion fish | source
    talosctl completion fish | source
    helm completion fish | source

    # Paths
    set -gx PATH $PATH $HOME/.krew/bin

    function starship_transient_rprompt_func
      starship module time
    end

    function starship_transient_prompt_func
      starship module character
    end

    # Set the prompt
    starship init fish | source
    enable_transience
end


function reload
    exec fish
end
