# Dotfiles

Personal macOS setup managed with [chezmoi](https://www.chezmoi.io/). macOS only. The machine is set up for coding agents, not for a human at a terminal: bash is the login shell, there is no prompt framework, and nothing prompts 1Password during normal work.

## Layout

```
.
├── dotfiles/                      # chezmoi source (.chezmoiroot points here)
│   ├── .chezmoi.yaml.tmpl         # age encryption + editor; nothing else
│   ├── .chezmoiignore / .chezmoiremove
│   ├── .chezmoiscripts/
│   │   ├── run_once_before_decrypt-age-key.sh.tmpl   # unlocks key.txt.age once per machine
│   │   └── run_onchange_after_brew-bundle.sh.tmpl    # brew bundle install when the Brewfile changes
│   ├── dot_bashrc, dot_bash_profile                  # the shell config
│   ├── dot_zshenv                                    # shim: sources ~/.bashrc for stray zsh callers
│   ├── private_dot_gitconfig.tmpl                    # one file, ssh signing with ~/.ssh/id_ed25519
│   ├── private_dot_ssh/private_config                # Apple ssh-agent + Keychain; 1Password only for unifi-dm
│   ├── private_dot_config/
│   │   ├── homebrew/Brewfile                         # source of truth for brew formulae and casks
│   │   ├── mise/config.toml                          # source of truth for CLI tools
│   │   ├── git/{allowed-signers,ignore}
│   │   ├── gh/, ghostty/, topgrade/, sops/age/
│   ├── dot_claude/                                   # Claude Code settings + skills
│   └── private_Library/Application Support/Code/User/settings.json
├── cloudflare/                    # Worker behind install.dotfiles.wiki (generic, serves any GitHub user)
├── docs/                          # Astro Starlight wiki at dotfiles.wiki (bun)
├── install.sh                     # macOS bootstrap: Xcode CLT -> chezmoi -> init --apply
└── Taskfile.yaml                  # `task docs:serve`
```

## Conventions

- chezmoi naming: `dot_` = dotfile, `private_` = 0600/0700, `executable_` = +x, `.tmpl` = Go template, `.age` = age-encrypted.
- Templates may use `.chezmoi.homeDir`. There is no OS or work branching; if a template needs a condition, question the need first.
- Secrets never render from a template. Runtime secrets live in `~/.config/secrets.env` (untracked, 0600), sourced by `~/.bashrc`. Do not call `onepassword*` template functions; they prompt 1Password on every `chezmoi status`.
- Packages: edit `Brewfile` or `mise/config.toml`, then `chezmoi apply`. The brew script installs only; removals are `brew uninstall` by hand.
- Shell: bash 5 from Homebrew. PATH puts mise shims first so tools resolve in `bash -c` without `mise activate`.
- Git signing: ssh format, `~/.ssh/id_ed25519`, verified via `~/.config/git/allowed-signers`. GitHub access is https through `gh auth git-credential`.
- Edit configs that apps rewrite (VS Code, mise after `mise use`) in place, then `chezmoi re-add`.

## Docs wiki

`docs/` is a Starlight site deployed to https://dotfiles.wiki by `.github/workflows/docs-deploy.yaml`. Content is `.mdx` under `docs/src/content/docs/`; sidebar order is frontmatter `sidebar.order`; WIP pages use `StubComponent`; Dottie assets live in `docs/assets/Dottie/`. Content currently still describes the old Windows/Linux/ansible setup and needs a rewrite.
