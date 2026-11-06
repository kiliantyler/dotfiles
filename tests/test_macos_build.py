"""CLI contract tests; the fake Tart executes guest commands in disposable fixtures."""
import fcntl
import json
import os
import signal
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

RUNNER = Path(__file__).resolve().parents[1] / 'dotfiles/private_dot_local/bin/executable_macos-build'

FAKE_TART = '''#!/usr/bin/env python3
import json,os,pathlib,signal,subprocess,sys,time
state=pathlib.Path(os.environ['FAKE_TART_STATE'])
args=sys.argv[1:]
if args[0]=='list':
    mode=os.environ.get('FAKE_TART_MODE','')
    print(json.dumps([] if mode=='missing' else [{'Name':'t3-macos-build','Running':mode=='running'}]))
elif args[0]=='run':
    state.write_text(str(os.getpid()))
    signal.signal(signal.SIGTERM,lambda *_:sys.exit(0))
    while True:time.sleep(1)
elif args[0]=='stop':
    os.kill(int(state.read_text()),signal.SIGTERM);state.unlink()
elif args[0]=='exec':
    deadline=time.monotonic()+5
    while not state.exists() and time.monotonic()<deadline:time.sleep(.01)
    if not state.exists():sys.exit(1)
    offset=3 if args[1]=='-i' else 2
    if os.environ.get('FAKE_TART_FAIL_CLEANUP') and args[offset]=='/bin/rm':sys.exit(1)
    child=subprocess.Popen(args[offset:])
    def stop(signum,frame):
        child.terminate();sys.exit(128+signum)
    signal.signal(signal.SIGTERM,stop)
    try:sys.exit(child.wait())
    except SystemExit:
        child.wait();raise
else:sys.exit(2)
'''


class MacosBuildTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='macos-build-test-')
        self.addCleanup(self.temporary.cleanup)
        self.base = Path(self.temporary.name)
        self.repo = self.base / 'source with spaces'
        self.repo.mkdir()
        self.home = self.base / 'home'
        self.home.mkdir()
        binary = self.base / 'bin'
        binary.mkdir()
        (binary / 'tart').write_text(FAKE_TART)
        (binary / 'tart').chmod(0o755)
        self.env = {**os.environ, 'HOME': str(self.home), 'PATH': str(binary) + os.pathsep + os.environ['PATH'], 'FAKE_TART_STATE': str(self.base / 'vm.pid')}
        self.addCleanup(self.stop_fixture_vm)
        self.git('init', '-q')
        self.git('config', 'user.email', 'fixture@example.invalid')
        self.git('config', 'user.name', 'Fixture')
        self.git('config', 'filter.fixture.clean', 'sed s/working/stored/g')
        self.git('config', 'filter.fixture.smudge', 'sed s/stored/working/g')
        (self.repo / '.gitattributes').write_text('asset.txt filter=fixture\n')
        (self.repo / 'asset.txt').write_text('working bytes')
        (self.repo / '.gitignore').write_text('build/\nsecret.env\n')
        (self.repo / 'tracked.txt').write_text('before')
        (self.repo / 'deleted.txt').write_text('remove this')
        (self.repo / 'src').mkdir()
        (self.repo / 'src/marker').write_text('fixture')
        self.git('add', '.')
        self.git('commit', '-qm', 'fixture')

    def git(self, *args):
        return subprocess.check_output(['git', '-C', str(self.repo), *args], env=self.env, text=True).strip()

    def stop_fixture_vm(self):
        state = self.base / 'vm.pid'
        if state.exists():
            try:
                os.kill(int(state.read_text()), signal.SIGTERM)
            except ProcessLookupError:
                pass

    def invoke(self, *args, bootstrap=None):
        bootstrap = bootstrap or '''import shutil,runpy,sys
original=shutil.disk_usage
shutil.disk_usage=lambda path:original(path)._replace(free=40*1024**3)
sys.argv=sys.argv[1:]
runpy.run_path(sys.argv[0],run_name='__main__')
'''
        prefix = [sys.executable, '-c', bootstrap]
        return subprocess.run([*prefix, str(RUNNER), *args], cwd=self.repo / 'src', env=self.env, capture_output=True, text=True, timeout=30)

    def test_snapshot_artifact_and_guest_exit_status(self):
        (self.repo / 'tracked.txt').write_text('after')
        (self.repo / 'deleted.txt').unlink()
        (self.repo / 'new.txt').write_text('untracked source')
        (self.repo / 'secret.env').write_text('ignored fixture value')
        head = self.git('rev-parse', 'HEAD')
        command = '''import json,pathlib,subprocess
p=pathlib.Path('..');(p/'build').mkdir()
(p/'build/proof.json').write_text(json.dumps({'head':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'tracked':(p/'tracked.txt').read_text(),'asset':(p/'asset.txt').read_text(),'new':(p/'new.txt').read_text(),'deleted':(p/'deleted.txt').exists(),'secret':(p/'secret.env').exists()}))'''
        result = self.invoke('--artifact', 'build/proof.json', '--', sys.executable, '-c', command)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads((self.repo / 'build/proof.json').read_text()), {'head': head, 'tracked': 'after', 'asset': 'working bytes', 'new': 'untracked source', 'deleted': False, 'secret': False})
        self.assertFalse((self.base / 'vm.pid').exists(), 'a completed job stops its VM')
        self.assertEqual((self.repo / 'tracked.txt').read_text(), 'after', 'source changes stay on the host')
        failure = self.invoke('--artifact', 'build/absent.json', '--', sys.executable, '-c', 'raise SystemExit(7)')
        self.assertEqual(failure.returncode, 7, failure.stderr)
        self.assertFalse((self.base / 'vm.pid').exists(), 'a failed job also stops its VM')

    def test_preflight_refusals_never_run_on_the_host(self):
        for mode in ['missing', 'running', 'busy', 'submodule']:
            with self.subTest(mode=mode):
                self.env['FAKE_TART_MODE'] = mode
                if mode == 'submodule':
                    self.git('update-index', '--add', '--cacheinfo', '160000,' + self.git('rev-parse', 'HEAD') + ',nested')
                state = self.home / '.local/state/macos-build'
                state.mkdir(parents=True, exist_ok=True)
                with (state / 'lease').open('a') as lease:
                    if mode == 'busy':
                        fcntl.flock(lease, fcntl.LOCK_EX | fcntl.LOCK_NB)
                    result = self.invoke('--', sys.executable, '-c', "open('host-command-ran','w').write('bad')")
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse((self.repo / 'src/host-command-ran').exists())
                self.assertFalse((self.base / 'vm.pid').exists())

    def test_disk_pressure_stops_the_owned_job(self):
        pressure = self.base / 'pressure'
        cancelled = self.base / 'cancelled'
        bootstrap = '''import os,pathlib,shutil,runpy,sys
original=shutil.disk_usage
def usage(path):
    result=original(path)
    return result._replace(free=(10 if pathlib.Path(os.environ['FAKE_DISK_PRESSURE']).exists() else 40)*1024**3)
shutil.disk_usage=usage
sys.argv=sys.argv[1:]
runpy.run_path(sys.argv[0],run_name='__main__')
'''
        self.env['FAKE_DISK_PRESSURE'] = str(pressure)
        self.env['FAKE_TART_FAIL_CLEANUP'] = '1'
        command = f'''import pathlib,signal,time
def stop(*_):
    pathlib.Path({str(cancelled)!r}).touch();raise SystemExit(143)
signal.signal(signal.SIGTERM,stop)
pathlib.Path({str(pressure)!r}).touch()
time.sleep(60)
'''
        result = self.invoke('--', sys.executable, '-c', command, bootstrap=bootstrap)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('20 GiB', result.stderr)
        self.assertTrue(cancelled.exists(), 'disk pressure cancels the command that this invocation started')
        self.assertFalse((self.base / 'vm.pid').exists(), 'disk pressure also stops the owned VM')
        pending = self.home / '.local/state/macos-build/pending-job'
        previous = Path(pending.read_text())
        self.assertTrue(previous.exists(), 'a racing cleanup retains its owned guest path')
        self.env.pop('FAKE_TART_FAIL_CLEANUP')
        pressure.unlink()
        command = f'''import pathlib
p=pathlib.Path('../build');p.mkdir();(p/'budget.bin').write_bytes(b'x'*8192)
pathlib.Path({str(pressure)!r}).touch()
'''
        result = self.invoke('--artifact', 'build/budget.bin', '--', sys.executable, '-c', command, bootstrap=bootstrap)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('20 GiB', result.stderr)
        self.assertFalse((self.repo / 'build/budget.bin').exists(), 'an export cannot consume the host reserve')
        self.assertFalse((self.base / 'vm.pid').exists())
        self.assertFalse(previous.exists(), 'the next fresh boot reaps the recorded previous job')
        self.assertFalse(pending.exists())


if __name__ == '__main__':
    unittest.main()
