#!/bin/bash
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"

sudo install -m 755 -o root -g root "$DIR/type-gate.sh" /usr/local/bin/type-gate.sh
sudo install -d /etc/systemd/system/getty@tty1.service.d
sudo install -m 644 "$DIR/getty-tty1-override.conf" /etc/systemd/system/getty@tty1.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart getty@tty1.service

echo "Installed. Switch to tty1 (Ctrl+Alt+F1) to see the gate. Undo with ./uninstall.sh"
