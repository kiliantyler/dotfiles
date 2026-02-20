# Dotfiles Repository

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), supporting macOS, Linux, and Windows.

## Repository Structure

```
.
├── dotfiles/              # Chezmoi source directory (.chezmoiroot points here)
│   ├── .chezmoi.yaml.tmpl # Chezmoi config template (age encryption, 1Password, etc.)
│   ├── .chezmoidata/      # Template data files (YAML)
│   │   ├── windows.yaml   # Winget, scoop, chocolatey package lists
│   │   ├── homebrew.yaml  # Homebrew formulae/casks
│   │   ├── apt.yaml       # Debian/Ubuntu packages
│   │   ├── asdf.yaml      # Legacy asdf tool versions
│   │   ├── data.yaml      # Shared template variables
│   │   ├── dirs.yaml      # Directory creation list
│   │   ├── flatpak.yaml   # Flatpak packages (stub)
│   │   ├── gh-release.yaml # GitHub release binaries
│   │   └── snap.yaml      # Snap packages (stub)
│   ├── .chezmoiignore     # Platform-conditional ignores
│   ├── .chezmoiscripts/   # Lifecycle scripts
│   │   ├── onChange/      # Run when data changes (winget, scoop, homebrew, etc.)
│   │   └── runOnce/       # Run once per machine (bloatware removal, age key, ansible)
│   ├── .chezmoisymlinks/  # Symlink targets for externally-edited files
│   ├── private_dot_config/ # ~/.config/ contents
│   │   ├── private_dot_gitconfig/ # Git config (templates + includes)
│   │   ├── mise/          # mise tool version manager config
│   │   ├── ssh/           # SSH config fragments
│   │   ├── fish/          # Fish shell config
│   │   └── starship.toml  # Starship prompt config
│   ├── private_dot_ssh/   # ~/.ssh/ contents
│   └── Documents/         # PowerShell profiles (Windows)
├── ansible/               # Ansible playbooks for macOS/Linux system setup
├── cloudflare/            # Cloudflare Worker for install.dotfiles.wiki
├── docs/                  # Documentation wiki (Astro/Starlight site at dotfiles.wiki)
│   └── src/content/docs/  # Wiki content pages (MDX)
├── memory-bank/           # Legacy Cline memory bank (deprecated, ignore)
├── .taskfiles/            # Task runner definitions
└── Taskfile.yaml          # Task runner entry point
```

## Key Conventions

### Chezmoi naming
- `dot_` → dotfile, `private_` → restricted perms, `executable_` → +x
- `.tmpl` suffix → Go template, rendered with chezmoi data
- `run_once_before_` → runs once before apply, `run_onchange_before_` → runs when template data changes
- `symlink_` → chezmoi-managed symlink

### Platform targeting
- Templates use `{{ .chezmoi.os }}` — values: `darwin`, `linux`, `windows`
- `.chezmoiignore` excludes platform-specific files (e.g., `**/*.ps1` on non-Windows)
- `.chezmoidata/windows.yaml` drives Windows-only package scripts
- mise config uses `os` option for platform-conditional tools: `eza = { version = "latest", os = ["macos", "linux"] }`

### Tool management (Windows)
1. **mise** — Cross-platform CLI tools shared across all OSes via `~/.config/mise/config.toml`
2. **Scoop** — Windows-only CLI tools (mise itself, eza, topgrade). Real executables, no symlink issues.
3. **Winget** — GUI applications only. AppExecution Aliases break over SSH.
4. **Chocolatey** — Legacy, minimal use (nvidia-app only)

### Tool management (macOS)
- **Homebrew** — System packages, casks, GUI apps
- **mise** — CLI tool versions (same config as Windows/Linux)

### Scripts
- Windows scripts: `.ps1.tmpl` (PowerShell), `.bat` (batch)
- Unix scripts: `.sh.tmpl` (bash/zsh)
- Scripts iterate over lists from `.chezmoidata/*.yaml`
- Idempotent: check if already installed before acting

### Git config
- Signing via 1Password SSH keys (platform-conditional paths in template)
- Delta as pager with Dracula theme
- Includes chain: `default.gitconfig.tmpl` → `themes.delta`, `personal.gitconfig`

## Documentation Wiki

The wiki at `docs/` is an [Astro Starlight](https://starlight.astro.build/) site deployed to https://dotfiles.wiki.

- Content lives in `docs/src/content/docs/` as `.mdx` files
- Uses bun as package manager (`bun run start` to dev)
- Task runner: `task docs:serve`
- Sidebar order controlled by frontmatter `sidebar.order`
- WIP pages use a `StubComponent` React component
- Dottie is the mascot (assets in `docs/assets/Dottie/`)

### Current wiki pages
| Page | Status | Path |
|------|--------|------|
| Home | Complete | `index.mdx` |
| Overview | Complete | `intro.mdx` |
| Installation | Complete | `installation.mdx` |
| FAQ | Complete | `faq.mdx` |
| Chezmoi | Complete | `Management Tools/Chezmoi.mdx` |
| Age | Complete | `Management Tools/Age.mdx` |
| Cloudflare | Complete | `Management Tools/Cloudflare.mdx` |
| Repo Layout | WIP stub | `RepoLayout.mdx` |
| Troubleshooting | WIP stub | `Troubleshooting.mdx` |
| Management Tools index | WIP stub | `Management Tools/index.mdx` |
| Ansible | WIP stub | `Management Tools/Ansible.mdx` |
| Managed Dotfiles index | WIP stub | `Managed Dotfiles/index.mdx` |

## Development

- **Task runner**: [Taskfile](https://taskfile.dev/) — `task -l` to list tasks
- **Commitlint**: Conventional commits enforced via `commitlint.config.mjs`
- **Editor**: VS Code / Cursor (settings in `.vscode/`)
- **CI**: GitHub Actions for docs deploy and Cloudflare Worker deploy
