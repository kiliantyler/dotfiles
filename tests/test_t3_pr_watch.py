"""The T3 PR watch hook answers each agent's hook events in that agent's own format."""
from pathlib import Path
import json
import os
import shutil
import subprocess
import tempfile
import unittest

HOOKS = Path(__file__).resolve().parents[1] / 'dotfiles/dot_agents/hooks'
OPEN_UNWATCHED = [{'url': 'https://github.com/o/r/pull/1', 'number': 1, 'state': 'open', 'watching': False}]
OPEN_WATCHED = [{'url': 'https://github.com/o/r/pull/1', 'number': 1, 'state': 'open', 'watching': True}]


class T3PrWatchTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)
        for name in ('t3-pr-watch.sh', 't3-pr-watch-guard.sh'):
            shutil.copy(HOOKS / f'executable_{name}', self.dir / name)
            (self.dir / name).chmod(0o755)
        # Stand-ins for the T3 CLI (serves the thread from thread.json) and gh (every PR still open).
        self.t3 = self.dir / 't3'
        self.t3.write_text(f'#!/bin/sh\n[ "$2" = show ] && cat {self.dir}/thread.json\n')
        self.t3.chmod(0o755)
        bin_dir = self.dir / 'bin'
        bin_dir.mkdir()
        (bin_dir / 'gh').write_text('#!/bin/sh\necho OPEN\n')
        (bin_dir / 'gh').chmod(0o755)
        self.path = f'{bin_dir}:{os.environ["PATH"]}'
        self.addCleanup(self.stop_guard)

    def stop_guard(self):
        # A Stop starts a detached guard that polls the thread; end it with the test.
        pidfile = self.dir / 't3-pr-watch-guard/thread-1.pid'
        if pidfile.exists():
            subprocess.run(['kill', pidfile.read_text().strip()], capture_output=True)

    def hook(self, payload, prs):
        (self.dir / 'thread.json').write_text(json.dumps(
            {'thread': {'latestRunId': 'r1', 'settled': True, 'pullRequests': prs}}))
        out = subprocess.run([str(self.dir / 't3-pr-watch.sh')], input=json.dumps(payload), text=True,
                             capture_output=True, check=True,
                             env={'PATH': self.path, 'HOME': str(self.dir), 'XDG_STATE_HOME': str(self.dir),
                                  'T3CODE_THREAD_ID': 'thread-1', 'T3CODE_CLI_PATH': str(self.t3)}).stdout
        return json.loads(out) if out.strip() else None

    def test_stop_with_an_unwatched_pr_keeps_the_turn_going(self):
        claude = self.hook({'hook_event_name': 'Stop', 'stop_hook_active': False}, OPEN_UNWATCHED)
        self.assertEqual(claude['decision'], 'block')
        self.assertIn('https://github.com/o/r/pull/1', claude['reason'])
        agy = self.hook({'hookEventName': 'Stop', 'continuationActive': False, 'terminationReason': 'NO_TOOL_CALL'},
                        OPEN_UNWATCHED)
        self.assertEqual(agy['decision'], 'continue')
        self.assertIn('https://github.com/o/r/pull/1', agy['reason'])

    def test_stop_lets_the_turn_end(self):
        cases = {
            'already extended (Claude, Codex)': ({'hook_event_name': 'Stop', 'stop_hook_active': True}, OPEN_UNWATCHED),
            'already extended (Antigravity)': ({'hookEventName': 'Stop', 'continuationActive': False, 'executionNum': 1},
                                               OPEN_UNWATCHED),
            'cancelled by the user': ({'hookEventName': 'Stop', 'terminationReason': 'USER_CANCELED'}, OPEN_UNWATCHED),
            'every PR watched': ({'hook_event_name': 'Stop'}, OPEN_WATCHED),
        }
        for name, (payload, prs) in cases.items():
            with self.subTest(name):
                self.assertIsNone(self.hook(payload, prs))

    def test_prompt_submit_adds_context(self):
        out = self.hook({'hook_event_name': 'UserPromptSubmit'}, OPEN_UNWATCHED)
        self.assertEqual(out['hookSpecificOutput']['hookEventName'], 'UserPromptSubmit')
        self.assertIn('https://github.com/o/r/pull/1', out['hookSpecificOutput']['additionalContext'])

    def test_session_start_reminds_only_a_thread_with_open_prs(self):
        claude = self.hook({'hook_event_name': 'SessionStart', 'source': 'resume'}, OPEN_WATCHED)
        self.assertIn('list_thread_pull_requests', claude['hookSpecificOutput']['additionalContext'])
        agy = self.hook({'hookEventName': 'SessionStart'}, OPEN_WATCHED)
        self.assertIn('list_thread_pull_requests', agy['injectSteps'][0]['systemMessage']['systemMessage'])
        self.assertIsNone(self.hook({'hook_event_name': 'SessionStart'}, []))


if __name__ == '__main__':
    unittest.main()
