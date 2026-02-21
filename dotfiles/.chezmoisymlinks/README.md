# Chezmoi Symlinks

### What is this directory?

This is for files that are known to be edited outside of chezmoi, this will keep them away from needing to be "chezmoi merged"'d every time they are changed.

Example file:

mise - config.toml

* This will be changed frequently by mise when installing/updating tools, but we want it to be tracked always, not when remembering to sync it.
