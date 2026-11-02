# Source names

A source file's name tells chezmoi what to create in `~` and how. `.chezmoiroot` holds `dotfiles`, so only entries under `dotfiles/` become targets; everything else at the repo root (this folder, `docs/`, `cloudflare/`) is never applied.

## Prefixes, in the order they must appear

| Target | Prefix order |
|---|---|
| file | `encrypted_` `private_` `readonly_` `empty_` `executable_` `dot_` |
| file created only if missing | `create_`, then the file prefixes |
| file edited by a script | `modify_` `encrypted_` `private_` `readonly_` `executable_` `dot_` |
| directory | `remove_` `external_` `exact_` `private_` `readonly_` `dot_` |
| symlink | `symlink_` `dot_` |
| script | `run_`, then `once_` or `onchange_`, then `before_` or `after_` |
| delete the target | `remove_` `dot_` |

What each one does:

- `dot_foo` → `.foo`. `private_` drops group and world permissions (0600 files, 0700 directories). `executable_` adds +x. `readonly_` drops write bits.
- `empty_` keeps a zero-byte file; without it chezmoi deletes empty targets.
- `encrypted_` plus the `.age` suffix: stored age-encrypted, decrypted on apply with `~/.config/chezmoi/key.txt`.
- `exact_` on a directory deletes anything inside it that the source does not list. Never use it on a folder other tools write into, such as `~/.claude/skills`.
- `symlink_name` holds the link target as its contents (a template if it ends in `.tmpl`).
- `create_` writes the file once and never overwrites later edits. `modify_` is a script that receives the current file on stdin and prints the new contents.
- `literal_` (prefix) or `.literal` (suffix) stops attribute parsing, for a filename that would otherwise read as a prefix.

## Suffixes

- `.tmpl`: render as a Go template first. See [templates.md](templates.md).
- `.age`: encrypted; removed from the target name.

## Special files under `dotfiles/`

| File | Purpose |
|---|---|
| `.chezmoi.yaml.tmpl` | Renders `~/.config/chezmoi/chezmoi.yaml` on `chezmoi init`. Re-render with `chezmoi init` or `--init` on apply. |
| `.chezmoiignore` | Target paths never applied (a template; patterns are target-relative). |
| `.chezmoiremove` | Target paths to delete on apply. Absent here until something needs retiring. |
| `.chezmoiversion` | Minimum chezmoi version; older binaries refuse to run. |
| `.chezmoiscripts/` | Scripts that run without creating a target directory. See [scripts.md](scripts.md). |
| `.chezmoiexternal.toml` | Files, archives or repos fetched into `~`. See [externals.md](externals.md). |
| `.chezmoidata.*`, `.chezmoitemplates/` | Static template data and shared template fragments. Unused here. |

Any other name starting with `.` at the source root is ignored, so a new special file must start with `.chezmoi`.

## Changing a prefix

Rename the source file, or run `chezmoi chattr <attribute> <target>` (for example `chezmoi chattr +private ~/.config/foo`, `-template`). Then `chezmoi apply <target>` and confirm `chezmoi diff` is empty.
