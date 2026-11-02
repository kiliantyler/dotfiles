# Scripts

Scripts live in `dotfiles/.chezmoiscripts/` and run during `chezmoi apply`. The name decides when:

| Name | Runs |
|---|---|
| `run_…` | on every apply |
| `run_once_…` | once per distinct content; editing the script makes it run again |
| `run_onchange_…` | whenever its content differs from the last successful run |
| `…before_…` / `…after_…` | before or after chezmoi writes files; without either, interleaved with files |

Within a phase, scripts run in alphabetical order of their target name (`brew-bundle.sh`, `link-skills.sh`, `set-login-shell.sh`). Rename with a numeric prefix to force an order.

A `.tmpl` script is rendered first, and chezmoi hashes the **rendered** text. A script that renders to nothing but whitespace is skipped.

## Choose `run_onchange_` with a trigger comment

Put the facts that should re-run the script into a comment, so the rendered text changes exactly when they do:

```sh
# Brewfile hash: {{ include "private_dot_config/homebrew/Brewfile" | sha256sum }}
# gh signed in: {{ stat (joinPath .chezmoi.homeDir ".config/gh/hosts.yml") | not | not }}
# skills: {{ glob (joinPath .chezmoi.homeDir "git/kiliantyler/skills/skills/*/SKILL.md") | join " " | sha256sum }}
```

The script then does nothing on an apply where nothing changed, and `chezmoi status` stays empty. A bare `run_` script shows `R` in `chezmoi status` permanently; `status.exclude: [scripts]` in the config would hide that line, but the script would still run every time.

A trigger has to be able to change after a failure. If a script exits 0 without doing its work (the skills clone before `gh auth login`), the facts in its comment must differ once the blocker clears, or it never runs again.

## Failure

A script that exits non-zero stops the apply, so scripts after it in the order do not run. Warn and exit 0 for a step that can wait (no network, not signed in); fail only when continuing would leave the machine broken.

## Re-running and inspecting

- Preview the rendered script: `chezmoi execute-template < dotfiles/.chezmoiscripts/<file>.tmpl`.
- Run only scripts: `chezmoi apply --include=scripts`. Skip them: `--exclude=scripts`.
- Force one `run_onchange_` script to run again: `chezmoi state delete --bucket=entryState --key="$HOME/.chezmoiscripts/<target-name>"` (for example `link-skills.sh`), then apply.
- `run_once_` history is in the `scriptState` bucket: `chezmoi state get-bucket --bucket=scriptState`. Deleting the whole bucket re-runs every `run_once_` script, including the age-key decrypt and login-shell change, so delete single keys instead.
