{{- /* Global agent instructions, rendered per agent by dot_claude/CLAUDE.md, dot_codex/AGENTS.md and dot_gemini/GEMINI.md (Antigravity). */ -}}
{{- /* What each agent has: change it here when an agent gains or loses a tool. mcp = the kanvil, github-scheduler and t3-factory servers. */ -}}
{{- $mcp := dict "claude" true "codex" true "antigravity" true -}}
{{- if not (hasKey $mcp .agent) }}{{ fail (printf "agent-instructions.md: unknown agent %q" .agent) }}{{ end -}}
{{- $mcp = index $mcp .agent -}}
Apply applicable skills silently. Keep commentary focused on task progress, decisions, and results. Refer to a skill only when I ask, the skill blocks continuation, or it requires user action.

When I ask a follow-up such as "Did you open a ticket?", "Did you run the tests?", or "Why haven't you done X?", use the task context to recognize a request to correct an omitted step. Verify whether it was done; if missing, complete it in the same turn and report the result. For example, check for existing ticket coverage before creating the missing ticket. A bare "No" or an offer to do it later is insufficient. Treat a clear corrective question as authorization for that step, while preserving explicit approval gates and duplicate-ticket rules. If I explicitly ask only for status or explanation, answer without taking action. If a real blocker prevents completion, state the blocker and the specific input needed.

# Kanvil tickets in T3 Code

Link Kanvil tickets directly in chat. T3 Code's issue sidebar does not support Kanvil. Never pass a Kanvil key, ID, or URL to `link_issue` or another sidebar linking tool, even when T3 asks to link every issue. Skip the attempt silently, including retries and status notes.

# Shared lessons and skills

When Hindsight is available for the current project, use relevant memories as leads and check mutable facts against current evidence. Keep project-specific lessons in the project bank. Keep secrets and private user data out of lessons. Respect read-only requests.

When a correction or verified discovery changes a reusable procedure, search the canonical skills collection for its owner. Fix the existing skill where the advice belongs. Create a skill only for a repeatable workflow with a recognizable trigger, a verifiable outcome and no existing owner. Verify the change against a representative task and share it through the collection's normal workflow. Routine one-off work needs no skill.

# Effort reporting: never time-based

Never estimate or report work in hours, days, weeks, sprints, or any clock/calendar
unit. Agents do not experience time; "3 hours" is meaningless here. This overrides
any skill that asks for time estimates (e.g. i-have-adhd rule 6).

Report effort as **difficulty**, using the same three-tier scale as Kanvil tickets:

| Tier | Meaning |
|---|---|
| `low` | established approach, local deterministic validation, one or two files |
| `med` | analysis across components, nontrivial implementation or validation |
| `high` | difficult diagnosis, architecture, concurrency, or subtle interacting contracts |

Optionally add the concrete drivers, which are real measures: files touched,
call sites to update, external systems involved, and whether validation is
deterministic (tests exist) or manual. Example:

> difficulty: med — 4 files, 9 call sites, existing tests cover it.

# DRY: change the chokepoint, not the call sites

Keep code DRY. Before any plan, ticket, or edit that repeats a change across call sites, find the shared **chokepoint** (the one function, method, loop head, or helper every caller already passes through) and make the change there once. If none exists, add one helper and route the callers through it. A design that edits many call sites the same way needs a stated reason a chokepoint cannot cover them; report the call-site count only after that search.

# Reuse and extend existing components

Every new view, component, type, enum, or helper starts with a search for its nearest **sibling**: an existing one that shows the same kind of thing, in the same place or the same role (a chip, row, sheet, banner, badge, status, level or kind enum, formatter). This applies even when a ticket names a new type. When a sibling exists, extend it with a parameter, case, or slot and move both callers onto it. One component per concept. Its look, icon/tint table, and accessibility wording live in one place.

Introduce a new one only when the sibling cannot express the need without contorting its existing callers. State that reason in the plan or PR, naming the sibling you rejected. Before publishing, check the diff: each new type must name the sibling it extends or the reason none fits. A second copy of an existing layout or style table counts as a finding and is fixed in the same change.

# Tests: test-audit on every change

Every code change applies the `test-audit` skill (`/Users/kilian/git/kiliantyler/skills/skills/test-audit/SKILL.md`) before it is committed, and every code review applies it to the diff under review. Each added or changed test passes its authoring gate; one that fails is removed, or its assertion moves to the contract's owner test, in the same change. A change that adds no test names, in its PR or final report, the existing owner test that proves it or the reason no contract needs one. Pruning tests outside the change's own scope is an audit task of its own.

Fixing a bad test (flaky, over budget, oversized or proving nothing) **must** write its rule: the imperative clause in the skill's defect rules that would have stopped that test being written. Commit it to the skills repo in the same change or one the fix's PR links, and add a CI pattern when a diff can show the cause. Do this even when an existing rule's name already fits. A test fix without its rule is unfinished.

# Commits: commit-messages before every commit

Before every `git commit` (amend and reword included) and before creating or retitling a pull request, apply the `commit-messages` skill (`/Users/kilian/git/kiliantyler/skills/skills/commit-messages/SKILL.md`). A subject's type decides the next version: GitHub Scheduler suggests a major, minor or patch release from the subjects since the last one.

# Local validation

Run builds and tests directly with each repository's documented commands on the host. Prepare its pinned toolchain and required services locally. The macOS build VM and `macos-build` wrapper are retired. Repository publication, release signing, physical-device validation and human approval gates retain their existing workflows.

# Releases: tag last

A version tag marks a release that shipped. A release starts by dispatching the repository's release workflow on its default branch with the version and the commit (`tag`, `sha`). The commit is any commit on the default branch after the last release, and the release stays on it whatever is merged afterwards. The workflow verifies, publishes, then creates the `vX.Y.Z` tag as its last step. {{ if $mcp }}Start one through the `github-scheduler` skill, and only when I asked for that release.{{ else }}Cutting one needs the GitHub Scheduler MCP server, which this agent lacks: when I ask for a release, tell me to cut it from Claude Code or Codex.{{ end }} When a release fails, fix the cause and release the same version again.

A release accepts a check that already passed on its commit and runs it otherwise. It never waits on another workflow's run, and it adds no token, deploy key or App of its own. Pull request CI is not slowed down for a release's sake.

Shared release logic lives in the public `MaudeCode/.github` repository. When a release rule or step would apply to more than one repository, change it there and have each repository adopt it, not in one repository's workflow.

Build every new or changed release workflow to the contract in `RELEASES.md` of the public `MaudeCode/.github` repository, with its `release-preflight` and `release-tag` actions pinned to a commit. A new repository that publishes versions adopts the contract from its first release. A repository that still releases from a pushed tag moves to the contract in the change that next touches its release workflow.

# Dotfiles

Before creating or editing any file under `~`, or installing or removing a package or CLI tool, apply the `dotfiles` skill (`/Users/kilian/git/kiliantyler/skills/skills/dotfiles/SKILL.md`). chezmoi owns the home directory.

# 1Password

`op` in an agent shell reads and writes every 1Password vault without Touch ID. Hand secrets to processes by reference, `op://<vault>/<item>/<field>`, through `op run`, `op inject` or `$(op read ...)`, so values stay out of chat, logs and repositories. Reads are unlimited; writes, listings and `op item get` without `--format json` share a 1,000-request daily cap, so look items up with `op read` or `op item get --format json`.

# Webpages and web UI

Before building, editing, or reviewing a webpage or web UI, read `/Users/kilian/.codex/skills/codex-web-no-filler/SKILL.md` and apply it silently. It is the shared source for interface-copy and no-cards defaults. Skip it for backend-only work and prose outside an interface.

Before publishing any page or UI change that has a phone layout, apply the `foldable-web` skill (`/Users/kilian/git/kiliantyler/skills/skills/foldable-web/SKILL.md`): it holds the iPhone Duo viewports and the screenshot matrix to run. A phone layout is published only after every viewport in that matrix has been looked at.

Buttons are icons. Every action, the primary one and an empty state's included, is an icon button with a tooltip and an accessible name. A button holds words only when the words are information the icon cannot carry, such as the exact version a release button will cut, or a dialog's submit; when in doubt, use the icon and say which buttons kept text.

Every list filters through one small filter icon button. The pickers and the search box sit inside the popup it opens, active filters show as removable chips, and the filter is part of the page's address. A list whose rows belong to repositories, projects or owners filters by them.
