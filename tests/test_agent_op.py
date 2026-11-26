"""The agent `op` wrapper sends each command to Connect or the service account."""
from pathlib import Path
import os
import subprocess
import tempfile
import unittest

WRAPPER = Path(__file__).resolve().parents[1] / 'dotfiles/private_dot_local/agent-bin/executable_op'
BASHRC = Path(__file__).resolve().parents[1] / 'dotfiles/dot_bashrc'
TOKENS = ('OP_CONNECT_HOST', 'OP_CONNECT_TOKEN', 'OP_SERVICE_ACCOUNT_TOKEN')


class AgentOpTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.home = Path(tmp.name)
        bin_dir = self.home / 'bin'
        bin_dir.mkdir()
        # Stands in for the real `op`: prints which credentials it was handed.
        fake = bin_dir / 'op'
        fake.write_text('#!/bin/sh\n' + ''.join(f'echo {t}=${{{t}:-}}\n' for t in TOKENS))
        fake.chmod(0o755)
        self.path = f'{bin_dir}:/usr/bin:/bin'

    def write_config(self):
        config = self.home / '.config/op/agent.env'
        config.parent.mkdir(parents=True)
        config.write_text('OP_AGENT_CONNECT_HOST=https://connect.test\n'
                          'OP_AGENT_CONNECT_TOKEN=connect-token\n'
                          'OP_AGENT_SA_TOKEN=sa-token\n')

    def op(self, *args, **env):
        out = subprocess.run(['bash', str(WRAPPER), *args], capture_output=True, text=True, check=True,
                             env={'HOME': str(self.home), 'PATH': self.path, **env}).stdout
        return dict(line.split('=', 1) for line in out.splitlines())

    def test_reads_use_connect(self):
        self.write_config()
        for args in (['read', 'op://v/i/f'], ['inject', '-i', 'x'], ['run', '--', 'true'],
                     ['item', 'get', 'x', '--format', 'json'], ['item', 'get', 'x', '--format=json']):
            with self.subTest(args=args):
                self.assertEqual(self.op(*args), {'OP_CONNECT_HOST': 'https://connect.test',
                                                  'OP_CONNECT_TOKEN': 'connect-token',
                                                  'OP_SERVICE_ACCOUNT_TOKEN': ''})

    def test_other_commands_use_the_service_account(self):
        self.write_config()
        for args in (['item', 'create'], ['item', 'list'], ['vault', 'list'], ['document', 'get', 'x'],
                     ['item', 'get', 'x']):
            with self.subTest(args=args):
                self.assertEqual(self.op(*args), {'OP_CONNECT_HOST': '', 'OP_CONNECT_TOKEN': '',
                                                  'OP_SERVICE_ACCOUNT_TOKEN': 'sa-token'})

    def test_a_write_inside_op_run_drops_the_connect_credentials_it_inherited(self):
        self.write_config()
        inherited = {'OP_CONNECT_HOST': 'https://connect.test', 'OP_CONNECT_TOKEN': 'connect-token'}
        self.assertEqual(self.op('item', 'edit', 'x', **inherited),
                         {'OP_CONNECT_HOST': '', 'OP_CONNECT_TOKEN': '', 'OP_SERVICE_ACCOUNT_TOKEN': 'sa-token'})

    def test_without_config_the_real_op_runs_untouched(self):
        self.assertEqual(self.op('vault', 'list'), dict.fromkeys(TOKENS, ''))


class AgentShellTests(unittest.TestCase):
    """`~/.bashrc` puts the wrapper's folder first on PATH for an agent, and nowhere for a person."""

    def path(self, **marker):
        with tempfile.TemporaryDirectory() as home:
            env = {'HOME': home, 'PATH': '/usr/bin:/bin', **marker}
            out = subprocess.run(['bash', '--noprofile', '--norc', '-c', f'. "{BASHRC}"; echo "$PATH"'],
                                 env=env, capture_output=True, text=True, check=True)
            return out.stdout.strip().replace(home, '~').split(':')

    def test_each_agent_marker_puts_the_wrapper_first(self):
        # CLAUDE_CODE_ENTRYPOINT is all Claude Code has set when it reads the profile to fix its tool shells' PATH;
        # CLAUDECODE only appears in the tool shells themselves, which do not read the profile again.
        for marker in ('CLAUDECODE', 'CLAUDE_CODE_ENTRYPOINT', 'CODEX_THREAD_ID', 'ANTIGRAVITY_AGENT'):
            with self.subTest(marker=marker):
                self.assertEqual(self.path(**{marker: '1'})[0], '~/.local/agent-bin')

    def test_a_shell_with_no_marker_keeps_the_real_op(self):
        self.assertNotIn('~/.local/agent-bin', self.path())


if __name__ == '__main__':
    unittest.main()
