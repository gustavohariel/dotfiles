#!/bin/sh
# Enable Wake-on-LAN (magic packet) on the primary ethernet interface.
#
#   sudo sh ~/sandbox/dotfiles/wol/install.sh
#
# Auto-detects the ethernet interface carrying the default route and its
# NetworkManager connection profile, then sets wake-on-lan=magic.
# Idempotent — safe to re-run.
#
# Caveats:
#   - BIOS must have "Wake on LAN" / "Power on by PCIe" enabled and
#     "ErP Ready" / "Deep Sleep" disabled.
#   - If booted from a Limine btrfs snapshot (OverlayFS root), the nmcli
#     change is ephemeral. Promote the snapshot via btrfs-assistant and
#     re-run this script.
set -eu

iface=$(ip -o route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')
if [ -z "${iface:-}" ]; then
    echo "Could not detect primary interface via default route." >&2
    exit 1
fi
case "$iface" in
    en*|eth*) ;;
    *) echo "Primary interface '$iface' is not ethernet — WoL skipped." >&2; exit 1 ;;
esac

conn=$(nmcli -t -f NAME,DEVICE con show --active | awk -F: -v d="$iface" '$2==d {print $1; exit}')
if [ -z "${conn:-}" ]; then
    echo "No active NetworkManager connection for $iface." >&2
    exit 1
fi

echo "Interface: $iface"
echo "Connection: $conn"

nmcli con modify "$conn" 802-3-ethernet.wake-on-lan magic
nmcli con down "$conn" >/dev/null
nmcli con up   "$conn" >/dev/null

state=$(ethtool "$iface" | awk '/Wake-on:/ {print $2; exit}')
echo "ethtool Wake-on: $state (want 'g')"
[ "$state" = "g" ] || { echo "WoL not armed — check NIC support / driver." >&2; exit 1; }
