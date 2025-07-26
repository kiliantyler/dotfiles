# Activate mise very early in fish startup to ensure all tools are available
# This file loads before plugins and main config.fish
if status is-interactive; and which mise >/dev/null
    mise activate fish | source
end
