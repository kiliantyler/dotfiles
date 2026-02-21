function _generate_completion --description "Cache a tool's completions, regenerating when the binary changes"
    # Usage: _generate_completion <command> <completion args...>
    # Example: _generate_completion kubectl completion fish
    # Example: _generate_completion gh completion -s fish
    set -l cmd $argv[1]
    set -l gen_args $argv[2..]

    type -q $cmd; or return

    set -l completions_dir ~/.config/fish/completions
    set -l comp_file $completions_dir/$cmd.fish
    set -l bin_path (command -v $cmd)

    # Regenerate if completion file is missing or older than the binary
    if not test -f $comp_file; or test $bin_path -nt $comp_file
        $cmd $gen_args > $comp_file 2>/dev/null
    end
end
