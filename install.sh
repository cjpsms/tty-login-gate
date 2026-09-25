#!/bin/bash
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"

sudo install -m 755 -o root -g root "$DIR/type-gate.sh" /usr/local/bin/type-gate.sh
sudo install -d /etc/systemd/system/getty@tty1.service.d
sudo install -m 644 "$DIR/getty-tty1-override.conf" /etc/systemd/system/getty@tty1.service.d/override.conf
sudo systemctl daemon-reload
# Restarting getty@tty1 kills whatever session is logged in there (e.g. a desktop started from tty1),
# so only restart it while tty1 is still sitting at the gate. Otherwise the new script is used next time.
if ps -t tty1 -o user= | grep -qv '^root$'; then
    echo "tty1 has a logged-in session, not restarting it. The new gate shows up after you log out of tty1."
else
    sudo systemctl restart getty@tty1.service
fi

echo "Installed. Switch to tty1 (Ctrl+Alt+F1) to see the gate. Undo with ./uninstall.sh"
