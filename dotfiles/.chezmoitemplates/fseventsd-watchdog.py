"""Recover fseventsd and iOS simulator logd processes after sustained excessive memory use."""
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
# A simulator's logd can outlive its device and leak; one reached 78 GB in seven hours.
SIMULATOR_LOGD = re.compile(r'\.simruntime/Contents/Resources/RuntimeRoot/usr/libexec/logd$')


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


def simulator_logds():
    """Map each running simulator logd PID to its (uid, command) identity."""
    found = {}
    for line in output('/bin/ps', '-Ao', 'pid=,uid=,comm=').splitlines():
        fields = line.split(maxsplit=2)
        if len(fields) == 3 and SIMULATOR_LOGD.search(fields[2]):
            found[int(fields[0])] = (fields[1], fields[2])
    return found


def log(message):
    print(datetime.datetime.now().astimezone().isoformat(timespec='seconds'),
          message, flush=True)


class Watchdog:
    def __init__(self):
        self.pid = None
        self.over_limit = 0
        self.signalled_pid = None
        self.last_signal = -math.inf
        self.simulator_over_limit = {}

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

    def poll_simulators(self):
        counts = {}
        for pid, identity in simulator_logds().items():
            try:
                size = footprint(pid)
            except (ValueError, subprocess.SubprocessError):
                continue  # exited between ps and vmmap; its count starts over
            counts[pid] = self.simulator_over_limit.get(pid, 0) + 1 if size >= LIMIT_BYTES else 0
            if counts[pid] < 2:
                continue
            del counts[pid]
            # Recheck identity immediately before signalling: the PID may have been reused.
            if simulator_logds().get(pid) != identity:
                log(f'simulator logd PID {pid} changed identity; no recovery requested')
                continue
            os.kill(pid, signal.SIGTERM)
            log(f'sent SIGTERM to simulator logd PID {pid}: footprint {size / 1024**3:.2f} GiB '
                'exceeded 2 GiB on two consecutive checks')
        self.simulator_over_limit = counts


def main():
    watchdog = Watchdog()
    log('watching fseventsd and simulator logd every 60 seconds; 2 GiB limit, two checks, '
        '600-second fseventsd cooldown')
    while True:
        try:
            watchdog.poll()
        except (OSError, ValueError, subprocess.SubprocessError) as error:
            watchdog.over_limit = 0
            log(f'fseventsd check failed; no recovery requested: {error}')
        try:
            watchdog.poll_simulators()
        except (OSError, ValueError, subprocess.SubprocessError) as error:
            watchdog.simulator_over_limit = {}
            log(f'simulator logd check failed; no recovery requested: {error}')
        time.sleep(INTERVAL_SECONDS)


if __name__ == '__main__':
    main()
