"""CLI contract tests; the fake Tart executes guest commands in disposable fixtures."""
import fcntl
import json
import os
import signal
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest

RUNNER = Path(__file__).resolve().parents[1] / 'dotfiles/private_dot_local/bin/executable_macos-build'

FAKE_TART = '''#!/usr/bin/env python3
import json,os,pathlib,signal,subprocess,sys,time,tempfile,shutil
state=pathlib.Path(os.environ['FAKE_TART_STATE'])
registry=state.with_name('clones');registry.mkdir(exist_ok=True)
running=state.with_name('running-name')
args=sys.argv[1:]
if args[0]=='list':
    mode=os.environ.get('FAKE_TART_MODE','')
    items=[] if mode=='missing' else [{'Name':'t3-macos-build','Running':mode=='running'}]
    items += [{'Name':p.name,'Running':state.exists() and running.exists() and running.read_text()==p.name} for p in registry.iterdir()]
    print(json.dumps(items))
elif args[0]=='clone':
    assert args[1]=='t3-macos-build' and args[2].startswith('t3-macos-build-run-')
    (registry/args[2]).mkdir()
    if os.environ.get('FAKE_TART_MODE')=='clone-fails':
        (registry/args[2]/'unowned').touch();sys.exit(1)
elif args[0]=='delete':
    assert args[1].startswith('t3-macos-build-run-'),'the prepared base must never be deleted'
    if os.environ.get('FAKE_TART_FAIL_CLEANUP'):sys.exit(1)
    shutil.rmtree(registry/args[1])
elif args[0]=='run':
    assert args[-1].startswith('t3-macos-build-run-'),'the prepared base must never boot for a job'
    state.write_text(str(os.getpid()));running.write_text(args[-1])
    signal.signal(signal.SIGTERM,lambda *_:sys.exit(0))
    while True:time.sleep(1)
elif args[0]=='stop':
    if os.environ.get('FAKE_TART_FAIL_STOP'):sys.exit(1)
    assert running.read_text()==args[1]
    os.kill(int(state.read_text()),signal.SIGTERM);state.unlink();running.unlink()
elif args[0]=='exec':
    deadline=time.monotonic()+5
    while not state.exists() and time.monotonic()<deadline:time.sleep(.01)
    if not state.exists():sys.exit(1)
    offset=3 if args[1]=='-i' else 2
    vm=args[offset-1]
    if args[offset]=='/usr/bin/mktemp':
        print(tempfile.mkdtemp(prefix='job-',dir=registry/vm));sys.exit(0)
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
        (binary / 'tmutil').write_text('#!/bin/sh\nexit 0\n')
        (binary / 'tmutil').chmod(0o755)
        (binary / 'brew').write_text('#!/bin/sh\nprintf "%s\\n" "$FAKE_POSTGRES_PREFIX"\n')
        (binary / 'brew').chmod(0o755)
        postgres = self.base / 'postgres-tools' / 'bin'
        postgres.mkdir(parents=True)
        for name in ['initdb', 'pg_ctl']:
            (postgres / name).write_text('''#!/usr/bin/env python3
import os,pathlib,sys
assert os.environ.get('LC_ALL')=='en_US.UTF-8','PostgreSQL needs an explicit valid guest locale'
data=pathlib.Path(sys.argv[sys.argv.index('-D')+1])
if os.environ.get('FAKE_POSTGRES_FAIL')==pathlib.Path(sys.argv[0]).name:
    (data.parent/'postgres.log').write_text('fixture PostgreSQL startup failed')
    sys.exit(8)
if pathlib.Path(sys.argv[0]).name=='initdb':data.mkdir()
else:(data/'started').touch()
''')
            (postgres / name).chmod(0o755)
        self.env = {**os.environ, 'HOME': str(self.home), 'PATH': str(binary) + os.pathsep + os.environ['PATH'], 'FAKE_TART_STATE': str(self.base / 'vm.pid')}
        self.env['FAKE_POSTGRES_PREFIX'] = str(postgres.parent)
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

    def invoke(self, *args, bootstrap=None, start=False):
        bootstrap = bootstrap or '''import shutil,runpy,sys
original=shutil.disk_usage
shutil.disk_usage=lambda path:original(path)._replace(free=40*1024**3)
sys.argv=sys.argv[1:]
runpy.run_path(sys.argv[0],run_name='__main__')
'''
        prefix = [sys.executable, '-c', bootstrap]
        if start:
            return subprocess.Popen([*prefix, str(RUNNER), *args], cwd=self.repo / 'src', env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
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
        self.env['FAKE_TART_FAIL_STOP'] = '1'
        failure = self.invoke('--', sys.executable, '-c', 'raise SystemExit(7)')
        self.assertEqual(failure.returncode, 7, 'shutdown failure must retain the guest failure')
        self.assertIn('shutdown deferred', failure.stderr)
        self.assertTrue((self.base / 'vm.pid').exists(), 'a failed shutdown retains the live owner')
        pending = self.home / '.local/state/macos-build/pending-vm'
        self.assertTrue((self.base / 'clones' / pending.read_text()).exists(), 'a live clone must not be deleted')

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

    def test_postgres_service_precedes_the_command_and_stays_in_its_clone(self):
        self.env['TEST_DATABASE_URL'] = 'host-value-must-not-be-reused'
        command = '''import json,os,pathlib
p=pathlib.Path('../build');p.mkdir()
(p/'postgres.json').write_text(json.dumps({'url':os.environ['TEST_DATABASE_URL'],'started':(pathlib.Path.cwd().parents[1]/'postgres/started').exists()}))
'''
        result = self.invoke('--postgres', '--artifact', 'build/postgres.json', '--', sys.executable, '-c', command)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads((self.repo / 'build/postgres.json').read_text()), {'url': 'postgres://build@127.0.0.1:5432/postgres', 'started': True})
        self.assertEqual(list((self.base / 'clones').iterdir()), [], 'service data is discarded with the owned VM')
        for stage in ['initdb', 'pg_ctl']:
            with self.subTest(stage=stage):
                self.env['FAKE_POSTGRES_FAIL'] = stage
                result = self.invoke('--postgres', '--', sys.executable, '-c', "open('service-failure-command-ran','w').close()")
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse((self.repo / 'src/service-failure-command-ran').exists())
                self.assertFalse((self.base / 'vm.pid').exists())
                if stage == 'pg_ctl':
                    self.assertIn('fixture PostgreSQL startup failed', result.stdout)

    def test_a_running_deferred_clone_keeps_its_owner_and_disk(self):
        owner = subprocess.Popen(['/bin/sleep', '30'])
        self.addCleanup(owner.wait)
        self.addCleanup(owner.kill)
        name = 't3-macos-build-run-12345'
        clone = self.base / 'clones' / name
        clone.mkdir(parents=True)
        (self.base / 'vm.pid').write_text(str(owner.pid))
        (self.base / 'running-name').write_text(name)
        state = self.home / '.local/state/macos-build'
        state.mkdir(parents=True)
        pending = state / 'pending-vm'
        pending.write_text(name)
        result = self.invoke('--', sys.executable, '-c', 'raise SystemExit(0)')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('is still running', result.stderr)
        self.assertIsNone(owner.poll(), 'a deferred record never grants permission to stop a live owner')
        self.assertTrue(clone.exists())
        self.assertEqual(pending.read_text(), name)

    def test_failed_clone_does_not_grant_deletion_ownership(self):
        self.env['FAKE_TART_MODE'] = 'clone-fails'
        result = self.invoke('--', sys.executable, '-c', 'raise SystemExit(0)')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(list((self.base / 'clones').glob('*/unowned'))), 1)
        self.assertFalse((self.home / '.local/state/macos-build/pending-vm').exists())

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
        pending = self.home / '.local/state/macos-build/pending-vm'
        previous = self.base / 'clones' / pending.read_text()
        self.assertTrue(previous.exists(), 'a failed clone cleanup retains only its owned VM')
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
        self.assertFalse(previous.exists(), 'the next admission reaps the recorded stopped clone')
        self.assertFalse(pending.exists())

    def test_waiting_jobs_preserve_the_current_owner_and_can_be_cancelled(self):
        ready, release = self.base / 'ready', self.base / 'release'
        cancelled = self.base / 'cancelled-waiter-ran'
        order = self.base / 'order'
        command = f'''import pathlib,time
pathlib.Path({str(ready)!r}).touch()
while not pathlib.Path({str(release)!r}).exists():time.sleep(.01)
pathlib.Path({str(order)!r}).write_text('first\\n')
'''
        processes = [self.invoke('--', sys.executable, '-c', command, start=True)]
        try:
            deadline = time.monotonic() + 10
            while not ready.exists():
                self.assertIsNone(processes[0].poll())
                self.assertLess(time.monotonic(), deadline)
                time.sleep(.01)
            waiter = self.invoke('--wait', '--', sys.executable, '-c', f"open({str(cancelled)!r},'w').close()", start=True)
            processes.append(waiter)
            self.assertTrue(waiter.stderr.readline().startswith('Waiting:'))
            waiter.terminate(); waiter.communicate(timeout=5)
            self.assertFalse(cancelled.exists())
            self.assertIsNone(processes[0].poll(), 'cancelling a waiter leaves the owner alive')
            second = self.invoke('--wait', '--', sys.executable, '-c', f"open({str(order)!r},'a').write('second\\n')", start=True)
            processes.append(second)
            self.assertTrue(second.stderr.readline().startswith('Waiting:'))
            release.touch()
            for process in [processes[0], second]:
                _, stderr = process.communicate(timeout=30)
                self.assertEqual(process.returncode, 0, stderr)
            self.assertEqual(order.read_text().splitlines(), ['first', 'second'])
            self.assertFalse((self.base / 'vm.pid').exists())
        finally:
            release.touch()
            for process in processes:
                if process.poll() is None:
                    process.terminate()
                process.communicate(timeout=10)


if __name__ == '__main__':
    unittest.main()
