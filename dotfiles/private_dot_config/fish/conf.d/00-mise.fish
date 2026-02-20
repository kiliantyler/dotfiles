# Activate mise very early in fish startup to ensure all tools are available
# This file loads before plugins and main config.fish
if which mise >/dev/null
    if status is-interactive
        mise activate fish | source
    else
        mise activate fish --shims | source
    end
end
