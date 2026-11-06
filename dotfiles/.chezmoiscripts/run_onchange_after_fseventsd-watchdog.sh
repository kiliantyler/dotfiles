#!/bin/sh
set -eu

# Reviewed upstream revision; launchd runs an embedded copy from a root-owned plist.
revision=ecb4d777a68e80c305c83a2485d7a7ba2adc815c
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT
base="https://raw.githubusercontent.com/Hixie/contraptions/$revision/fseventsd-watchdog"
for name in fseventsd-watchdog.sh local.fseventsd-watchdog.plist.template; do
    curl -fsSL "$base/$name" -o "$temporary/$name"
done
printf '%s  %s\n' \
    a370adc1d43a0f6ee1d6976c2cc12d51e7a72cb75cf150f07ab1df5fcc26d886 "$temporary/fseventsd-watchdog.sh" \
    6b8da195bb229ec99780e996b1141e98c77bbeb6bc49b5d527479ccbef8a48e3 "$temporary/local.fseventsd-watchdog.plist.template" | shasum -a 256 -c -
/usr/bin/plutil -insert ProgramArguments.2 -string "$(cat "$temporary/fseventsd-watchdog.sh")" \
    -o "$temporary/watchdog.plist" "$temporary/local.fseventsd-watchdog.plist.template"
/usr/bin/plutil -lint "$temporary/watchdog.plist"
target=/Library/LaunchDaemons/local.fseventsd-watchdog.plist
sudo -n /usr/bin/install -o root -g wheel -m 644 "$temporary/watchdog.plist" "$target"
sudo -n /bin/launchctl bootout system/local.fseventsd-watchdog 2>/dev/null || true
sudo -n /bin/launchctl bootstrap system "$target"
