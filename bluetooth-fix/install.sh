#!/bin/sh
# Install the bluetooth-fix bundle. Run with sudo.
#
#   sudo sh ~/sandbox/dotfiles-staging/bluetooth-fix/install.sh
#
# Idempotent — safe to re-run.
set -eu
here=$(cd "$(dirname "$0")" && pwd)

install -m 0644 "$here/etc/modprobe.d/btusb.conf"                          /etc/modprobe.d/btusb.conf
install -m 0644 "$here/etc/udev/rules.d/50-bluetooth-no-autosuspend.rules" /etc/udev/rules.d/50-bluetooth-no-autosuspend.rules
sh "$here/etc/bluetooth/main.conf.patch.sh"

udevadm control --reload-rules
udevadm trigger --subsystem-match=usb --attr-match=idVendor=0bda

systemctl restart bluetooth

echo
echo "System bits installed. Still to do (as your user, not root):"
echo "  systemctl --user restart wireplumber"
echo "  sudo modprobe -r btusb && sudo modprobe btusb   # or reboot"
