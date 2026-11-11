"""Recover the system FSEvents daemon after sustained excessive memory use."""
import datetime
import math
import os
import re
import signal
import subprocess
import time

DAEMON = '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/FSEvents.framework/Versions/A/Support/fseventsd'
LIMIT_BYTES = 2 * 1024**3
INTERVAL_SECONDS = 60
COOLDOWN_SECONDS = 600


def output(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True,
                          timeout=15, env={'PATH': '/usr/bin:/bin:/usr/sbin:/sbin',
                                           'LC_ALL': 'C'}).stdout


def current_pid():
    match = re.search(r'^\s*pid = ([0-9]+)\s*$',
                      output('/bin/launchctl', 'print', 'system/com.apple.fseventsd'),
                      re.MULTILINE)
    if not match or int(match[1]) <= 1:
        raise ValueError('launchd did not report a valid fseventsd PID')
    return int(match[1])


def footprint(pid):
    # RSS misses swapped-out allocations, which dominated the original leak.
    summary = output('/usr/bin/vmmap', '-summary', str(pid))
    match = re.search(r'^Physical footprint:\s*([0-9]+(?:\.[0-9]+)?)\s*([KMGT]?)B?\s*$',
                      summary, re.MULTILINE)
    if not match:
        raise ValueError('vmmap did not report a physical footprint')
    size = float(match[1]) * 1024**(' KMGT'.index(match[2]) if match[2] else 0)
    if not math.isfinite(size):
        raise ValueError('vmmap reported an invalid physical footprint')
    return size


def log(message):
    print(datetime.datetime.now().astimezone().isoformat(timespec='seconds'),
          message, flush=True)


class Watchdog:
    def __init__(self):
        self.pid = None
        self.over_limit = 0
        self.signalled_pid = None
        self.last_signal = -math.inf

    def poll(self):
        pid = current_pid()
        size = footprint(pid)
        if pid != self.pid:
            if self.signalled_pid is not None and self.signalled_pid == self.pid:
                log(f'launchd replaced fseventsd PID {self.pid} with PID {pid}')
            self.pid, self.over_limit = pid, 0
        self.over_limit = self.over_limit + 1 if size >= LIMIT_BYTES else 0
        if (self.over_limit < 2 or pid == self.signalled_pid or
                time.monotonic() - self.last_signal < COOLDOWN_SECONDS):
            return
        # Recheck launchd ownership and executable identity immediately before signalling.
        identity = output('/bin/ps', '-p', str(pid), '-o', 'uid=', '-o', 'comm=').strip().split(maxsplit=1)
        if current_pid() != pid or identity != ['0', DAEMON]:
            self.over_limit = 0
            raise ValueError('fseventsd identity changed before recovery')
        os.kill(pid, signal.SIGTERM)
        self.signalled_pid, self.last_signal = pid, time.monotonic()
        log(f'sent SIGTERM to fseventsd PID {pid}: footprint {size / 1024**3:.2f} GiB '
            'exceeded 2 GiB on two consecutive checks')


def main():
    watchdog = Watchdog()
    log('watching fseventsd every 60 seconds; 2 GiB limit, two checks, 600-second cooldown')
    while True:
        try:
            watchdog.poll()
        except (OSError, ValueError, subprocess.SubprocessError) as error:
            watchdog.over_limit = 0
            log(f'check failed; no recovery requested: {error}')
        time.sleep(INTERVAL_SECONDS)


if __name__ == '__main__':
    main()
