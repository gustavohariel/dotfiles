#!/bin/sh
# target: applied in-place to /etc/bluetooth/main.conf (package-owned by bluez)
#
# AirPods-specific bluez tunables. Layered on top of bluetooth-fix's patches:
# bluetooth-fix sets FastConnectable / Experimental / KernelExperimental.
# Here we add what AirPods need on top:
#
#   ControllerMode = bredr        AirPods only pair over classic BR/EDR, never LE.
#                                 Forcing the controller to bredr avoids confused
#                                 pairing attempts and speeds up reconnect.
#   AutoEnable = true             Power the controller back on at boot even if
#                                 the user toggled it off.
#   ReconnectAttempts/Intervals   Make bluez retry on its own when AirPods come
#                                 back into range; the airpods-watch service is
#                                 the proactive layer, these are the passive one.
#   JustWorksRepairing = always   AirPods reset (or being re-paired with a phone)
#                                 can invalidate the bond; let bluez re-trust
#                                 silently instead of prompting.
#
# Idempotent — safe to re-run. Re-run after a bluez upgrade if pacman drops
# a main.conf.pacnew.
set -e
f=/etc/bluetooth/main.conf

# ControllerMode: bluez 5.86 ships it commented as `#ControllerMode = dual`.
# Force to bredr. Two cases: line is the default-commented form, or it was
# previously set to something else.
if grep -qE '^#ControllerMode = dual$' "$f"; then
    sed -i 's/^#ControllerMode = dual$/ControllerMode = bredr/' "$f"
elif grep -qE '^ControllerMode = ' "$f"; then
    sed -i 's/^ControllerMode = .*/ControllerMode = bredr/' "$f"
else
    # No matching line at all — append under the [General] section.
    sed -i '/^\[General\]/a ControllerMode = bredr' "$f"
fi

# AutoEnable: bluez ships `#AutoEnable=true` (no spaces around =). Just uncomment.
sed -i 's/^#AutoEnable=true$/AutoEnable=true/' "$f"

# JustWorksRepairing: bluez ships `#JustWorksRepairing = never`. Set to always.
if grep -qE '^#JustWorksRepairing = never$' "$f"; then
    sed -i 's/^#JustWorksRepairing = never$/JustWorksRepairing = always/' "$f"
elif grep -qE '^JustWorksRepairing = ' "$f"; then
    sed -i 's/^JustWorksRepairing = .*/JustWorksRepairing = always/' "$f"
fi

# ReconnectAttempts: bluez ships `#ReconnectAttempts=7` under [Policy].
if grep -qE '^#ReconnectAttempts=7$' "$f"; then
    sed -i 's/^#ReconnectAttempts=7$/ReconnectAttempts=7/' "$f"
fi

# ReconnectIntervals: bluez ships `#ReconnectIntervals=1,2,4,8,16,32,64`.
if grep -qE '^#ReconnectIntervals=1,2,4,8,16,32,64$' "$f"; then
    sed -i 's/^#ReconnectIntervals=1,2,4,8,16,32,64$/ReconnectIntervals=1,2,4,8,16,32,64/' "$f"
fi

echo "main.conf effective (airpods overlay):"
grep -E '^(ControllerMode|AutoEnable|JustWorksRepairing|ReconnectAttempts|ReconnectIntervals|FastConnectable|Experimental|KernelExperimental)' "$f"
