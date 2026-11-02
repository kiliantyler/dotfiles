# Externals

`dotfiles/.chezmoiexternal.toml` (rendered as a template) fetches content from a URL into `~`. This repo has none today.

| `type` | Fetches |
|---|---|
| `file` | one file (`decompress` for `.gz`/`.bz2`/`.xz`/`.zstd`) |
| `archive` | a tarball or zip unpacked into a directory (`stripComponents`, `include`, `exclude`, `exact`) |
| `archive-file` | one member of an archive (`path` names it) |
| `git-repo` | a clone, updated with `git pull` (`clone.args`, `pull.args`) |

Keys are target paths relative to `~`, for example `["git/someone/tool"]`. Other fields: `url`, `refreshPeriod`, `executable`, `private`, `checksum.sha256`, `targetPath`, `filter.command`.

## Refresh

`refreshPeriod` defaults to `0`: fetched once, then left alone. `chezmoi apply --refresh-externals` (`-R`) forces a refetch. One exception seen on this Mac: declaring a `git-repo` external over a checkout that already existed made the next apply run `git pull` once.

`chezmoi managed --include=externals` lists them. Their fetch history is in the `gitRepoExternalState` state bucket.

## Ordering trap

Externals are part of the target state, so apply fetches them before any `run_after_` script runs. On a fresh Mac that is before Homebrew installs `gh` and before `gh auth login`. A private `git-repo` external fails there and stops the whole apply.

Use an external only for public URLs. Clone a private repo from a `run_onchange_after_` script that warns and exits 0 until sign-in, as `run_onchange_after_link-skills` does for `kiliantyler/skills`. See [scripts.md](scripts.md).
