# Kilian's Dotfiles

## Vision

Single command sets up entire computer.
When I say single command I mean **SINGLE** command.

So many dotfiles repos have a "single" command but the truth is you need to install X, Y, and Z before you run that command.

Or you need to git clone the repo then run a script to install things _then_ it's "one command"


I want this to *truly* be a single command

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kiliantyler
```

The focus is that this entire repo should be able to be applied with that single command. This links everything to Chezmoi.


## Structure

```
TODO
```

[Programs](Programs.md)

## Supported systems

- MacOS (Darwin)
- Debian


## Notes

This repo is not intended to be used in it's current form by *anyone* except myself.

It is, however, a good starting place for anyone to adapt to their own systems.
