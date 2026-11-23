#!/usr/bin/env bash
# T3 PR watch guard. t3-pr-watch-stop.sh starts one, detached, when a turn ends in a T3 Code thread that
# watches an open PR. T3 can drop a watch while the thread sits idle (Talaria PR #2183, 2026-11-23), and a
# dropped watch never wakes the thread, so no in-turn hook can see it. The guard polls the thread: when a PR
# it saw watched is still open but unwatched and no turn has run since, it messages the thread to re-arm.
# An unwatch the agent made on purpose happens inside a turn, which changes the run and ends the guard.
# It also exits when the thread settles or archives, nothing open stays watched, or after 24 hours.
set -u
thread=$1 t3=$2
interval=${T3_PR_WATCH_GUARD_INTERVAL:-60}
deadline=$(($(date +%s) + 86400))

show() { timeout 20 "$t3" thread show "$thread" --json --messages 0 2>/dev/null; }

s=$(show) || exit 0
run=$(jq -r '.thread.latestRunId // ""' <<<"$s")
watched=$(jq -c '[.thread.pullRequests[]? | select(.state == "open" and .watching == true) | .url]' <<<"$s")
[ "$watched" != "[]" ] || exit 0

while [ "$(date +%s)" -lt "$deadline" ]; do
  sleep "$interval"
  s=$(show) || continue
  jq -e '.thread.settled != true and .thread.archived != true' <<<"$s" >/dev/null || exit 0
  # A new run means a wake or a message reached the thread; that turn's stop starts a fresh guard.
  [ "$(jq -r '.thread.latestRunId // ""' <<<"$s")" = "$run" ] || exit 0
  dropped=$(jq -r --argjson w "$watched" '[.thread.pullRequests[]?
    | select(.state == "open" and .watching != true and (.url as $u | $w | index($u)))
    | "#\(.number) (\(.url))"] | join(", ")' <<<"$s")
  if [ -n "$dropped" ]; then
    "$t3" thread send "$thread" "T3 PR watch guard: T3 stopped watching $dropped while this thread was idle; this thread did not unwatch it. Call watch_pull_request (until: merged), read the head's checks and reviews with pull_request_read, and act on whatever already finished." >/dev/null 2>&1
    exit 0
  fi
  jq -e '[.thread.pullRequests[]? | select(.state == "open" and .watching == true)] | length > 0' <<<"$s" >/dev/null || exit 0
done
