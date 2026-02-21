if status is-interactive
    _generate_completion atuin gen-completions --shell fish
    _generate_completion kubectl completion fish
    _generate_completion talosctl completion fish
    _generate_completion helm completion fish
    _generate_completion gh completion -s fish
    _generate_completion flux completion fish
    _generate_completion k9s completion fish
    _generate_completion cilium completion fish
end
