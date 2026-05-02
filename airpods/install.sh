#!/bin/sh
# Install the airpods bundle. Run with sudo from your user shell — the script
# detects $SUDO_USER and drops privileges where needed (user systemd / config
# symlinks).
#
#   sudo sh ~/sandbox/dotfiles-staging/airpods/install.sh
#
# Depends on bluetooth-fix being installed first (Realtek autosuspend handling,
# baseline main.conf tweaks, mSBC/SBC-XQ wireplumber overrides). Aborts if the
# bluetooth-fix udev rule is not present.
#
# Idempotent — safe to re-run.
set -eu
here=$(cd "$(dirname "$0")" && pwd)

if [ -z "${SUDO_USER:-}" ]; then
    echo "ERROR: run with sudo from your user shell, not as root directly." >&2
    echo "       sudo sh $0" >&2
    exit 1
fi

user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)

# 1. Sanity check: bluetooth-fix must be installed first.
if [ ! -e /etc/udev/rules.d/50-bluetooth-no-autosuspend.rules ]; then
    echo "ERROR: bluetooth-fix not installed. Run that bundle first:" >&2
    echo "       sudo sh $here/../bluetooth-fix/install.sh" >&2
    exit 1
fi

# 2. Install librepods from AUR. The cachyos repo also ships librepods, but at
#    0.2.0alpha2-2 (months behind) — that build has a stale-cache bug after
#    disconnect/reconnect (UI shows Disconnected while internal state thinks
#    it's still connected). The AUR build (0.2.5+) handles the cycle cleanly.
#
#    Note: `paru -S librepods` would short-circuit on `--needed` because some
#    `librepods` (the cachyos one) is already installed — it never checks AUR.
#    `-a` (--aur) forces AUR-only resolution, bypassing the repo entry.
#    Run as $SUDO_USER (paru must not run as root); paru re-escalates via its
#    own sudo using the credential cache from this script's invocation.
echo "Installing/upgrading librepods (AUR forced)..."
sudo -u "$SUDO_USER" -H paru -S -a --needed --noconfirm librepods || {
    echo "ERROR: 'paru -S -a librepods' failed. Run manually as your user:" >&2
    echo "       paru -S -a librepods" >&2
    exit 1
}
echo "librepods version: $(pacman -Q librepods)"

# 3. Patch /etc/bluetooth/main.conf with AirPods-specific tunables.
sh "$here/etc/bluetooth/main.conf.patch.sh"

# 4. Create user-scope symlinks: wireplumber config, systemd-user unit, and the
#    airpods-watch script (now in ~/.local/bin for sudo-free iteration). All
#    symlinks point into the staging tree so `git pull` updates take effect
#    without re-running this installer. Symlinks created as root, then chown'd.
#    Both target dirs already exist (wireplumber / systemd / mise create them
#    at first login). mkdir -p is a no-op safety net.
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/wireplumber/wireplumber.conf.d"
sudo -u "$SUDO_USER" mkdir -p "$user_home/.config/systemd/user"
sudo -u "$SUDO_USER" mkdir -p "$user_home/.local/bin"

ln -snf "$here/home/.config/wireplumber/wireplumber.conf.d/52-bluez-avrcp.conf" \
        "$user_home/.config/wireplumber/wireplumber.conf.d/52-bluez-avrcp.conf"
chown -h "$SUDO_USER:$SUDO_USER" "$user_home/.config/wireplumber/wireplumber.conf.d/52-bluez-avrcp.conf"

ln -snf "$here/home/.config/systemd/user/airpods-watch.service" \
        "$user_home/.config/systemd/user/airpods-watch.service"
chown -h "$SUDO_USER:$SUDO_USER" "$user_home/.config/systemd/user/airpods-watch.service"

ln -snf "$here/home/.local/bin/airpods-watch" \
        "$user_home/.local/bin/airpods-watch"
chown -h "$SUDO_USER:$SUDO_USER" "$user_home/.local/bin/airpods-watch"

# 5. Clean up legacy /usr/local/bin/airpods-watch from earlier installs.
#    Detect if it's a regular file we own and remove it; anything else (symlink,
#    user-modified file) we leave alone with a warning.
if [ -f /usr/local/bin/airpods-watch ] && [ ! -L /usr/local/bin/airpods-watch ]; then
    echo "Cleaning up legacy /usr/local/bin/airpods-watch..."
    rm -f /usr/local/bin/airpods-watch
fi

# 6. Restart bluetooth so main.conf changes take effect.
systemctl restart bluetooth

cat <<EOF

✓ System bits installed (root scope).

What just happened:
  - librepods installed/upgraded from AUR (paru -S -a librepods).
  - /etc/bluetooth/main.conf patched (ControllerMode=bredr, AutoEnable, reconnect tunables).
  - ~/.local/bin/airpods-watch symlinked (script lives in staging; edit there).
  - ~/.config/wireplumber/wireplumber.conf.d/52-bluez-avrcp.conf symlinked.
  - ~/.config/systemd/user/airpods-watch.service symlinked.
  - Legacy /usr/local/bin/airpods-watch removed if present.
  - bluetooth.service restarted.

Still to do (as your user, NOT root) — same convention as bluetooth-fix:
  systemctl --user daemon-reload
  systemctl --user enable --now airpods-watch.service
  systemctl --user restart airpods-watch.service     # if already enabled
  systemctl --user restart wireplumber

Verify after that:
  systemctl --user status airpods-watch
  journalctl --user -u airpods-watch -f       # follow live
  bluetoothctl info 30:7A:D2:8F:E8:1A
  pactl list cards | grep -A 5 bluez_card

Then launch librepods (Qt UI) once to grant access, after which the daemon
takes over stem-press routing and ANC/Transparency control. Ear-detection
auto-pause needs MPRIS — start music in any player to test.

iOS gotcha: open Settings → Bluetooth → AirPods (i) → "Connect to This iPhone"
and set it to "When Last Connected to This iPhone" so the iPhone doesn't
snatch the AirPods every time you take them out of the case.
EOF
