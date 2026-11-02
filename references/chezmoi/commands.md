# Commands by task

| Task | Command |
|---|---|
| Is this file managed? Where is its source? | `chezmoi source-path <target>` (fails if unmanaged) |
| Everything managed | `chezmoi managed` (`--include=files,symlinks,scripts,externals`) |
| Files in a folder chezmoi does not manage | `chezmoi unmanaged <dir>` |
| What would apply change? | `chezmoi status` (one line per pending change), `chezmoi diff [target]` (full diff), `chezmoi apply --dry-run --verbose` |
| Does `~` match the source? | `chezmoi verify` exits non-zero on any difference |
| What would apply write for one file? | `chezmoi cat <target>` |
| Pull a live edit into the source | `chezmoi re-add <target>` (keeps encryption, skips templates) |
| Track a new file | `chezmoi add <target>`; `--encrypt` for private content, `--template` to start a `.tmpl` |
| Write the source to `~` | `chezmoi apply [target]` |
| Stop managing, keep the file | `chezmoi forget <target>` |
| Stop managing and delete the file | `chezmoi destroy <target>`, which also deletes the target; prefer `forget` and remove by hand |
| Change a prefix | `chezmoi chattr <+attr\|-attr> <target>` |
| Check the install | `chezmoi doctor` |
| Script or external history | `chezmoi state get-bucket --bucket=entryState\|scriptState\|gitRepoExternalState` |

`chezmoi status` columns: the first compares `~` with what chezmoi last wrote, the second compares `~` with the source. `A` added, `D` deleted, `M` modified, `R` a script that will run.

Most commands take `--include`/`--exclude` with entry types (`files`, `dirs`, `symlinks`, `scripts`, `externals`, `encrypted`, `templates`, `always`).

`chezmoi edit` opens VS Code (`code --wait` in this repo's config) and blocks until a human closes it. Edit files directly instead. `chezmoi update` pulls this repo and applies in one step; run `git pull` and `chezmoi apply` separately so you see what arrived first.
