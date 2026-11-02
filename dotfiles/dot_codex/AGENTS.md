Apply applicable skills silently. Keep commentary focused on task progress, decisions, and results. Refer to a skill only when I ask, the skill blocks continuation, or it requires user action.

When I ask a follow-up such as "Did you open a ticket?", "Did you run the tests?", or "Why haven't you done X?", use the task context to recognize a request to correct an omitted step. Verify whether it was done; if missing, complete it in the same turn and report the result. For example, check for existing ticket coverage before creating the missing ticket. A bare "No" or an offer to do it later is insufficient. Treat a clear corrective question as authorization for that step, while preserving explicit approval gates and duplicate-ticket rules. If I explicitly ask only for status or explanation, answer without taking action. If a real blocker prevents completion, state the blocker and the specific input needed.


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

# Webpages and web UI

Before building, editing, or reviewing a webpage or web UI, read `/Users/kilian/.codex/skills/codex-web-no-filler/SKILL.md` and apply it silently. It is the shared source for interface-copy and no-cards defaults. Skip it for backend-only work and prose outside an interface.
