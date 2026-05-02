# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles. No build/lint/test pipeline and **no install script** — deploy is manual symlinking. The user's global `~/.claude/CLAUDE.md` notes this repo is the canonical place for dotfiles edits, so changes to tracked files should land here, not in `$HOME`.

## Layout

- `zsh/zshrc` — zsh config (zinit + powerlevel10k + plugins, fzf, zoxide). See platform note below.
- `nvim/` — Neovim config (lazy.nvim plugins, custom colors, snippets, spell). Deploys to `~/.config/nvim/`.
- `.zed/` — Zed editor settings, keymap, tasks. Deploys to `~/.config/zed/` on both Linux and macOS.
- `.cursor/` — Cursor editor settings + keybinds. **Not** `.cursor/rules/` AI rules — these are GUI editor settings. Two gotchas if you wire it up: (1) the file is `keybinds.json` here but Cursor reads `keybindings.json`, and (2) the user config dir is `~/.config/Cursor/User/` on Linux vs. `~/Library/Application Support/Cursor/User/` on macOS.
- `superset/themes/` — themes for [superset.sh](https://superset.sh) (the dev tool, **not** Apache Superset). Loaded inside the app, no filesystem deploy.
- `README.md` — short, user-facing description with a deploy-target table.

## Platform mismatch in `zsh/zshrc`

`zsh/zshrc` was written for macOS and is **not** a config that runs cleanly on the current host:

- Sources `/opt/homebrew/bin/brew` if present.
- Prepends `/opt/homebrew/opt/libpq/bin` to PATH and exports Homebrew-libpq `LDFLAGS`/`CPPFLAGS`.
- Adds `proto` (`$HOME/.proto/shims`) to PATH.

Per the user's global CLAUDE.md, the current machine is CachyOS / Arch, the interactive shell is **fish** (not zsh), and the runtime version manager is **mise** (not proto). Treat `zshrc` as a portable starting point that may also need to work on macOS — confirm with the user before stripping the Homebrew/proto branches, since they may be intentional for cross-host portability.
