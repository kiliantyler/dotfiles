#!/usr/bin/env bash
# T3 PR watch hook for every agent T3 runs. Claude Code and Codex call it with Claude's hook format,
# Antigravity with its own (camelCase fields, different outputs); it answers each in its own format.
# In a T3 thread:
# - Stop: refuse to end a turn once while an open PR linked to the thread is not watched. T3 drops
#   watches silently and its wake text says "do not list it again", so the check has to be mechanical.
#   A deliberate hand-back (PR unwatched on purpose) just ends the turn again. Each Stop also starts
#   t3-pr-watch-guard.sh, which re-arms a watch that a Stop press drops while the thread is idle.
# - UserPromptSubmit: tell the turn about unwatched PRs. T3's Stop button on a watching thread sends
#   watching:false for every watched PR (client-runtime commands.ts).
# - SessionStart (resume, compaction): a summary saying a PR is watched is no proof, so re-check.
[ -n "${T3CODE_THREAD_ID:-}" ] || exit 0
IFS=$'\t' read -r event active why agy < <(jq -r '[.hook_event_name // .hookEventName // "Stop",
  # Antigravity documents continuationActive but leaves it false; executionNum > 0 marks an extended turn.
  (.stop_hook_active or .continuationActive or ((.executionNum // 0) > 0)), (.terminationReason // "NO_TOOL_CALL"),
  has("hookEventName")] | @tsv' 2>/dev/null)
[ -n "$event" ] || exit 0

# The next message is too late after a Stop press: each turn end leaves a guard that re-arms on its own.
[ "$event" = Stop ] && "$(dirname "$0")/t3-pr-watch-guard.sh" start "$T3CODE_THREAD_ID"
# A turn a Stop hook already extended, or one the user cancelled or an error ended, stops as asked.
[ "$active" = true ] && exit 0
[ "$event" = Stop ] && [ "$why" != NO_TOOL_CALL ] && exit 0

t3=${T3CODE_CLI_PATH:-$(command -v t3)}
[ -x "$t3" ] || exit 0
show=$(timeout 20 "$t3" thread show "$T3CODE_THREAD_ID" --json --messages 0 2>/dev/null) || exit 0

# say TEXT: hand TEXT to the agent in its own format; on Stop it also keeps the turn going.
say() {
  case "$event:$agy" in
    Stop:true) jq -n --arg r "$1" '{decision: "continue", reason: $r}' ;;
    Stop:false) jq -n --arg r "$1" '{decision: "block", reason: $r}' ;;
    *:true) jq -n --arg r "$1" '{injectSteps: [{systemMessage: {systemMessage: $r}}]}' ;;
    *) jq -n --arg e "$event" --arg r "$1" '{hookSpecificOutput: {hookEventName: $e, additionalContext: $r}}' ;;
  esac
}

if [ "$event" = SessionStart ]; then
  jq -e '[.thread.pullRequests[]? | select(.state == "open")] | length > 0' <<<"$show" >/dev/null || exit 0
  say "T3 PR watch check: a T3 PR watch can drop silently, a dropped watch never wakes you, and a summary saying a PR is watched is not proof. Before anything else this turn, call T3's list_thread_pull_requests (load T3's tools first if they are deferred), and for every open PR you still wait on that shows watching: false, call watch_pull_request with until: merged. Then read the checks on each such head yourself instead of treating silence as pending."
  exit 0
fi

# T3's PR snapshot lags a merge, so confirm each candidate is still open on GitHub.
unwatched=""
while IFS= read -r url; do
  [ -n "$url" ] || continue
  state=$(timeout 10 gh pr view "$url" --json state -q .state 2>/dev/null) || state=OPEN
  [ "$state" = OPEN ] && unwatched="${unwatched:+$unwatched, }$url"
done < <(jq -r '.thread.pullRequests[]? | select(.state == "open" and .watching != true) | .url' <<<"$show" 2>/dev/null)
[ -n "$unwatched" ] || exit 0

if [ "$event" = Stop ]; then
  say "T3 PR watch check: open PR $unwatched is linked to this thread but not watched, so no check failure, review or merge will wake you. If you are still waiting on it or will act on it, call T3's watch_pull_request (until: merged), read its checks with pull_request_read, and act on what is already finished. If you handed it back to the user on purpose, end the turn again."
else
  say "T3 PR watch check: open PR $unwatched is linked to this thread but not watched (a T3 Stop press unwatches every PR on the thread). Before anything else this turn, unless the user asked to stop watching it: call T3's watch_pull_request (until: merged) for it, read its checks with pull_request_read, and act on what already finished."
fi
