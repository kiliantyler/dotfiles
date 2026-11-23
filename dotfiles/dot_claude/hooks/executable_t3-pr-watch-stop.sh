#!/usr/bin/env bash
# Claude Code Stop hook: in a T3 thread, refuse to end a turn once while an
# open PR linked to the thread is not watched. T3 drops watches silently and
# its wake text says "do not list it again", so the check has to be mechanical.
# It blocks once per stop; a deliberate hand-back (PR unwatched on purpose)
# just ends the turn again. While a watched open PR remains, it starts
# t3-pr-watch-guard.sh, which catches a watch T3 drops after the turn ends.
[ -n "$T3CODE_THREAD_ID" ] || exit 0
input=$(cat)

t3=${T3CODE_CLI_PATH:-$(command -v t3)}
[ -x "$t3" ] || exit 0
show=$(timeout 20 "$t3" thread show "$T3CODE_THREAD_ID" --json --messages 0 2>/dev/null) || exit 0

# One guard per thread: a newer stop replaces the older guard and its baseline.
if jq -e '[.thread.pullRequests[]? | select(.state == "open" and .watching == true)] | length > 0' <<<"$show" >/dev/null 2>&1; then
  state=${XDG_STATE_HOME:-$HOME/.local/state}/t3-pr-watch-guard
  mkdir -p "$state"
  pidfile=$state/$T3CODE_THREAD_ID.pid
  old=$(cat "$pidfile" 2>/dev/null)
  [ -n "$old" ] && ps -p "$old" -o command= 2>/dev/null | grep -q t3-pr-watch-guard && kill "$old" 2>/dev/null
  nohup "$HOME/.claude/hooks/t3-pr-watch-guard.sh" "$T3CODE_THREAD_ID" "$t3" >/dev/null 2>&1 </dev/null &
  echo $! >"$pidfile"
  disown
fi

[ "$(jq -r '.stop_hook_active // false' <<<"$input" 2>/dev/null)" = "true" ] && exit 0
unwatched=$(jq -r '[.thread.pullRequests[]? | select(.state == "open" and .watching != true) | "#\(.number) (\(.url))"] | join(", ")' <<<"$show" 2>/dev/null)
[ -n "$unwatched" ] || exit 0

jq -n --arg prs "$unwatched" '{
  decision: "block",
  reason: ("T3 PR watch check: open PR " + $prs + " is linked to this thread but not watched, so no check failure, review or merge will wake you. If you are still waiting on it or will act on it, call mcp__t3-code__watch_pull_request (until: merged), read its checks with pull_request_read, and act on what is already finished. If you handed it back to the user on purpose, end the turn again.")
}'
