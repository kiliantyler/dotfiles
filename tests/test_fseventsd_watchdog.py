"""Recovery policy at the operating-system command and signal boundary."""
import importlib.util
from pathlib import Path
import signal
import subprocess
import unittest
from unittest.mock import patch

SOURCE = Path(__file__).resolve().parents[1] / 'dotfiles/.chezmoitemplates/fseventsd-watchdog.py'
spec = importlib.util.spec_from_file_location('watchdog', SOURCE)
watchdog = importlib.util.module_from_spec(spec)
spec.loader.exec_module(watchdog)


class WatchdogTests(unittest.TestCase):
    def setUp(self):
        self.pid = 12345
        self.size = '2G'
        self.identity = '0 ' + watchdog.DAEMON + '\n'
        self.now = 1000
        self.run = patch.object(watchdog.subprocess, 'run', side_effect=self.command).start()
        self.kill = patch.object(watchdog.os, 'kill').start()
        patch.object(watchdog.time, 'monotonic', side_effect=lambda: self.now).start()
        patch.object(watchdog, 'log').start()
        self.addCleanup(patch.stopall)
        self.guard = watchdog.Watchdog()

    def command(self, args, **kwargs):
        self.assertTrue(kwargs['check'])
        self.assertEqual(kwargs['timeout'], 15)
        if args[0] == '/bin/launchctl':
            text = f'system/com.apple.fseventsd = {{\n\tpid = {self.pid}\n}}\n'
        elif args[0] == '/usr/bin/vmmap':
            text = f'Physical footprint: {self.size}\nPhysical footprint (peak): 99G\n'
        elif args[0] == '/bin/ps':
            text = self.identity
        else:
            self.fail(f'unexpected command: {args}')
        return subprocess.CompletedProcess(args, 0, stdout=text)

    def test_sustained_limit_signals_current_daemon_once(self):
        self.guard.poll()
        self.kill.assert_not_called()
        self.guard.poll()
        self.kill.assert_called_once_with(self.pid, signal.SIGTERM)
        self.now += 10000
        self.guard.poll()
        self.kill.assert_called_once()

    def test_low_measurement_and_new_pid_require_fresh_confirmation(self):
        self.guard.poll()
        self.size = '2047M'
        self.guard.poll()
        self.size = '2G'
        self.guard.poll()
        self.kill.assert_not_called()
        self.pid += 1
        self.guard.poll()
        self.kill.assert_not_called()
        self.guard.poll()
        self.kill.assert_called_once_with(self.pid, signal.SIGTERM)

    def test_replacement_cannot_be_restarted_during_cooldown(self):
        self.guard.poll()
        self.guard.poll()
        self.pid += 1
        self.now += 60
        self.guard.poll()
        self.guard.poll()
        self.kill.assert_called_once()
        self.now += 540
        self.guard.poll()
        self.assertEqual(self.kill.call_args_list[-1].args, (self.pid, signal.SIGTERM))
        self.assertEqual(self.kill.call_count, 2)

    def test_stale_pid_or_wrong_identity_cannot_be_signalled(self):
        for identity in ['501 ' + watchdog.DAEMON, '0 /usr/bin/other-process']:
            with self.subTest(identity=identity):
                self.guard = watchdog.Watchdog()
                self.identity = identity
                self.guard.poll()
                with self.assertRaisesRegex(ValueError, 'identity changed'):
                    self.guard.poll()
                self.kill.assert_not_called()
        self.identity = '0 ' + watchdog.DAEMON
        self.guard = watchdog.Watchdog()
        self.guard.poll()
        original = self.command
        def changed_pid(args, **kwargs):
            if args[0] == '/bin/ps':
                self.pid += 1
            return original(args, **kwargs)
        self.run.side_effect = changed_pid
        with self.assertRaisesRegex(ValueError, 'identity changed'):
            self.guard.poll()
        self.kill.assert_not_called()

    def test_measurement_units_and_invalid_output(self):
        for text, expected in [('19.5M', 19.5 * 1024**2), ('2097152K', 2 * 1024**3),
                               ('2G', 2 * 1024**3), ('0.01T', .01 * 1024**4),
                               ('2048B', 2048)]:
            with self.subTest(text=text):
                self.size = text
                self.assertEqual(watchdog.footprint(self.pid), expected)
        for text in ['unknown', '-1G', 'NaN', '1P', '2G garbage']:
            with self.subTest(text=text):
                self.size = text
                with self.assertRaises(ValueError):
                    watchdog.footprint(self.pid)
        self.kill.assert_not_called()

    def test_failed_check_breaks_consecutive_measurements(self):
        samples = iter(['2G', 'unknown', '2G'])
        def sleep(_):
            self.size = next(samples)
        self.size = next(samples)
        with patch.object(watchdog.time, 'sleep', side_effect=sleep):
            with self.assertRaises(StopIteration):
                watchdog.main()
        self.kill.assert_not_called()


if __name__ == '__main__':
    unittest.main()
