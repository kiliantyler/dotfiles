if status is-interactive

    fish_add_path ~/.local/bin
    fish_add_path ~/.bin

    mise activate fish | source

    # Theme - ./themes/Dracula Official.theme
    fish_config theme choose "Dracula Official"

    # Remove greeting
    set --global fish_greeting ""

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