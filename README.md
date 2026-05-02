# Dotfiles

Personal configuration files.

| Path | Tool | Deploy target |
| --- | --- | --- |
| `zsh/zshrc` | zsh | `~/.zshrc` |
| `.zed/` | Zed editor | `~/.config/zed/` |
| `.cursor/` | Cursor editor | `~/.config/Cursor/User/` (Linux) or `~/Library/Application Support/Cursor/User/` (macOS) |
| `superset/themes/` | [superset.sh](https://superset.sh) | loaded inside the app, no filesystem deploy |

No install script — symlink by hand:

```bash
ln -sfn "$PWD/zsh/zshrc" ~/.zshrc
# ...etc.
```

## License
MIT
