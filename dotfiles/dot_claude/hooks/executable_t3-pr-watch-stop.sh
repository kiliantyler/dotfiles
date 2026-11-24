#!/usr/bin/env bash
# Claude Code Stop hook: in a T3 thread, refuse to end a turn once while an
# open PR linked to the thread is not watched. T3 drops watches silently and
# its wake text says "do not list it again", so the check has to be mechanical.
# It blocks once per stop; a deliberate hand-back (PR unwatched on purpose)
# just ends the turn again.
# As a UserPromptSubmit hook it tells the next turn about unwatched PRs instead:
# T3's Stop button on a watching thread sends watching:false for every watched
# PR (client-runtime commands.ts), so a Stop before a message drops the watch.
[ -n "$T3CODE_THREAD_ID" ] || exit 0
input=$(cat)
# The next message is too late after a Stop press: each turn end leaves a guard that re-arms on its own.
[ "$(jq -r '.hook_event_name // "Stop"' <<<"$input" 2>/dev/null)" = Stop ] && "$HOME/.claude/hooks/t3-pr-watch-guard.sh" start "$T3CODE_THREAD_ID"
[ "$(jq -r '.stop_hook_active // false' <<<"$input" 2>/dev/null)" = "true" ] && exit 0
event=$(jq -r '.hook_event_name // "Stop"' <<<"$input" 2>/dev/null)

t3=${T3CODE_CLI_PATH:-$(command -v t3)}
[ -x "$t3" ] || exit 0
show=$(timeout 20 "$t3" thread show "$T3CODE_THREAD_ID" --json --messages 0 2>/dev/null) || exit 0

# T3's PR snapshot lags a merge, so confirm each candidate is still open on GitHub.
unwatched=""
while IFS= read -r url; do
  [ -n "$url" ] || continue
  state=$(timeout 10 gh pr view "$url" --json state -q .state 2>/dev/null) || state=OPEN
  [ "$state" = OPEN ] && unwatched="${unwatched:+$unwatched, }$url"
done < <(jq -r '.thread.pullRequests[]? | select(.state == "open" and .watching != true) | .url' <<<"$show" 2>/dev/null)
[ -n "$unwatched" ] || exit 0

if [ "$event" = "UserPromptSubmit" ]; then
  jq -n --arg prs "$unwatched" '{hookSpecificOutput: {hookEventName: "UserPromptSubmit",
    additionalContext: ("T3 PR watch check: open PR " + $prs + " is linked to this thread but not watched (a T3 Stop press unwatches every PR on the thread). Before anything else this turn, unless the user asked to stop watching it: call mcp__t3-code__watch_pull_request (until: merged) for it, read its checks with pull_request_read, and act on what already finished.")}}'
  exit 0
fi
jq -n --arg prs "$unwatched" '{
  decision: "block",
  reason: ("T3 PR watch check: open PR " + $prs + " is linked to this thread but not watched, so no check failure, review or merge will wake you. If you are still waiting on it or will act on it, call mcp__t3-code__watch_pull_request (until: merged), read its checks with pull_request_read, and act on what is already finished. If you handed it back to the user on purpose, end the turn again.")
}'
