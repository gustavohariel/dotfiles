#!/usr/bin/env bash
set -euo pipefail

# Resolve the dotfiles dir from this script's location, so the repo can live
# anywhere (e.g. ~/sandbox/dotfiles, not just ~/dotfiles).
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

echo "Linking from $DOTFILES"

# zsh
link "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"

# Zed (~/.config/zed is the user config dir on both Linux and macOS)
link "$DOTFILES/.zed/settings.json" "$HOME/.config/zed/settings.json"
link "$DOTFILES/.zed/keymap.json"   "$HOME/.config/zed/keymap.json"
link "$DOTFILES/.zed/tasks.json"    "$HOME/.config/zed/tasks.json"

# Not auto-deployed:
#   .cursor/      — file naming (keybinds.json vs Cursor's keybindings.json) and
#                   target path (~/.config/Cursor/User on Linux,
#                   ~/Library/Application Support/Cursor/User on macOS) need a
#                   human decision. Deploy by hand.
#   superset/themes/ — loaded inside the Superset app, no filesystem symlink.

echo "Done."
