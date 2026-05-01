# Dotfiles

Personal configuration files for:
- zsh (`zsh/zshrc`)
- Zed editor (`.zed/`)

Also tracked but not auto-deployed by `install.sh`:
- Cursor editor settings (`.cursor/`) — file naming and target path differ by OS; deploy by hand.
- Apache Superset themes (`superset/themes/`) — loaded inside the Superset app, no filesystem symlink.

## Installation

```bash
git clone <repo-url> ~/sandbox/dotfiles
cd ~/sandbox/dotfiles
./scripts/install.sh
```

The script symlinks tracked files to their expected locations under `$HOME`, overwriting whatever is there. Back up existing files first if you want to keep them.

## License
MIT
