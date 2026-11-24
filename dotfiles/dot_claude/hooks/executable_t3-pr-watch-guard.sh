#!/usr/bin/env bash
# T3 PR watch guard. A Stop press on an idle T3 thread sends watching:false for every PR it watches
# (client-runtime commands.ts), and no hook runs until the next message, so the PR sits unwatched.
# `start THREAD` (from t3-pr-watch-stop.sh at each turn end) replaces the thread's guard with a detached
# `run`. The run polls the thread: when a PR it saw watched is still open but unwatched and no turn has run
# since, it messages the thread to re-arm it. An unwatch the agent makes happens inside a turn, which
# changes the run and ends the guard. It also exits when the thread settles or archives, nothing open
# stays watched, or after 24 hours.
set -u
mode=${1:-} thread=${2:-}
[ -n "$thread" ] || exit 0
t3=${T3CODE_CLI_PATH:-$(command -v t3)}
[ -x "$t3" ] || exit 0
show() { timeout 20 "$t3" thread show "$thread" --json --messages 0 2>/dev/null; }

if [ "$mode" = start ]; then
  state=${XDG_STATE_HOME:-$HOME/.local/state}/t3-pr-watch-guard
  mkdir -p "$state"
  pidfile=$state/$thread.pid
  old=$(cat "$pidfile" 2>/dev/null)
  [ -n "$old" ] && ps -p "$old" -o command= 2>/dev/null | grep -q t3-pr-watch-guard && kill "$old" 2>/dev/null
  nohup "$0" run "$thread" >/dev/null 2>&1 </dev/null &
  echo $! >"$pidfile"
  exit 0
fi
[ "$mode" = run ] || exit 0

interval=${T3_PR_WATCH_GUARD_INTERVAL:-30}
deadline=$(($(date +%s) + 86400))
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
    "$t3" thread send "$thread" "T3 PR watch guard: T3 stopped watching $dropped while this thread was idle (a Stop press on an idle thread unwatches every PR); this thread did not unwatch it. Call watch_pull_request (until: merged), read the head's checks and reviews with pull_request_read, and continue the work that was waiting on it." >/dev/null 2>&1
    exit 0
  fi
  jq -e '[.thread.pullRequests[]? | select(.state == "open" and .watching == true)] | length > 0' <<<"$s" >/dev/null || exit 0
done
