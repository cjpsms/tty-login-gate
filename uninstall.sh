#!/bin/bash
set -e

sudo rm -f /etc/systemd/system/getty@tty1.service.d/override.conf
sudo rmdir --ignore-fail-on-non-empty /etc/systemd/system/getty@tty1.service.d 2>/dev/null || true
sudo rm -f /usr/local/bin/type-gate.sh /etc/type-gate.conf
sudo systemctl daemon-reload
sudo systemctl restart getty@tty1.service

echo "Removed. tty1 is back to the normal login prompt."
