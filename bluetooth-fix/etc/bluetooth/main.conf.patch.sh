#!/bin/sh
# target: applied in-place to /etc/bluetooth/main.conf (package-owned by bluez)
#
# We don't ship a replacement main.conf because bluez ships a 13 KB template
# whose defaults change between versions; replacing it would mask .pacnew
# updates. Instead, idempotently uncomment four keys.
#
# Re-run after a bluez upgrade if pacman drops a main.conf.pacnew.
set -e
f=/etc/bluetooth/main.conf
sed -i 's/^#FastConnectable = false$/FastConnectable = true/'       "$f"
sed -i 's/^#Experimental = false$/Experimental = true/'             "$f"
sed -i 's/^#KernelExperimental = false$/KernelExperimental = true/' "$f"
sed -i 's/^#AutoEnable=true$/AutoEnable=true/'                      "$f"
echo "main.conf effective:"
grep -E '^(FastConnectable|Experimental|KernelExperimental|AutoEnable)' "$f"
