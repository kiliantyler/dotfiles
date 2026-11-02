# Templates

A source file ending in `.tmpl` is rendered with Go `text/template` plus chezmoi's functions before it is written. Template only when the content really varies; this repo has one Mac and no OS branching, so most files stay plain.

## Preview

- `chezmoi execute-template < <source file>` renders a source file to stdout.
- `chezmoi execute-template '{{ .chezmoi.homeDir }}'` evaluates an expression.
- `chezmoi cat <target>` prints exactly what apply would write.
- `chezmoi data` lists every variable.

## Variables used here

- `.chezmoi.homeDir`: the home directory. Prefer it to `$HOME` inside rendered paths.
- `.chezmoi.sourceDir`: `~/.local/share/chezmoi/dotfiles` (the root after `.chezmoiroot`).
- `.chezmoi.os`, `.chezmoi.arch`, `.chezmoi.hostname`, `.chezmoi.username`: available, but unused because the repo targets one Mac.

## Functions worth knowing

| Function | Use |
|---|---|
| `joinPath a b …` | Build a path. |
| `include "path"` | Raw contents of a file; relative paths start at the source root. Pair with `sha256sum` for script triggers. |
| `includeTemplate "path"` | Render another file as a template. |
| `stat "path"` | File info, or a false value if missing. `stat … \| not \| not` yields `true`/`false`. |
| `glob "pattern"` | Matching paths (`**` allowed); relative patterns start at `~`. |
| `lookPath "tool"` | Path of an executable on `PATH`, or empty. |
| `output "cmd" "arg"…` / `exec …` | Run a command at render time. Avoid them: they run on every `status`, `diff` and `apply`, and a failure breaks rendering. |
| `encrypt` / `decrypt` | age, using this repo's config. |
| `quote`, `squote`, `shellQuote` | Quote values inserted into config or shell. |
| `fromJson`, `fromYaml`, `fromToml`, `toYaml`, `toToml`, `jq` | Read or write structured data. |
| `gitHubLatestRelease "owner/repo"` and friends | Network calls on every render. Avoid them for the same reason. |

Sprig's string, list and dict helpers (`join`, `split`, `default`, `trim`, `has`, `dict`, …) are also available.

## Rules for this repo

- Never call a password-manager function (`onepassword*`, `bitwarden*` and the rest). They run on every `chezmoi status`, which turns a read-only command into a 1Password prompt. Secrets go in `~/.config/secrets.env`.
- The config sets `missingkey=error`, so a typo in a variable name fails loudly. Keep that.
- `chezmoi re-add` never overwrites a template. Edit the `.tmpl` source, then `chezmoi apply <target>`.
