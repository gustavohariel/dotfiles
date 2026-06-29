# Repository Guidelines

## Project Overview

Personal dotfiles for a CachyOS Linux workstation running fish, niri, Noctalia, Herdr, OMP, Neovim, Zed/Cursor, lazygit, Bluetooth/AirPods helpers, and Wake-on-LAN. This is not an application repo: most directories are deployable config packages, plus a few root-owned install scripts.

## Architecture & Data Flow

- Top-level directories are deploy units. Most mirror `$HOME` and are linked with GNU Stow; system packages under `bluetooth-fix/`, `airpods/`, and `wol/` install into `/etc` or user systemd and must be run explicitly.
- Runtime config is mostly declarative:
  - `niri/.config/niri/config.kdl` composes `cfg/*.kdl` plus `noctalia.kdl`.
  - `noctalia/.config/systemd/user/noctalia.service` owns Noctalia lifecycle; niri does not spawn it directly.
  - `airpods/home/.config/systemd/user/librepods.service` and `airpods-watch.service` own AirPods behavior.
  - `herdr/.config/herdr/config.toml` defines UI, worktree directory, keybindings, and custom shell commands.
- Imperative glue is intentionally small: `local-bin/.local/bin/display-desk`, `display-tv`, `herdr/.config/herdr/scripts/herdr-bun-start`, and `airpods/home/.local/bin/airpods-watch`.
- Theme direction is Titanium across tools: fish, Herdr, Neovim, lazygit, opencode, Noctalia palettes, and editor themes should stay visually aligned.

## Key Directories

- `fish/.config/fish/` — primary shell config on this machine; sources CachyOS fish config, activates mise, sets editor aliases, loads `private.fish` if present, and includes helper functions like `cwt`.
- `nvim/.config/nvim/` — LazyVim-based Neovim config. Custom behavior lives under `lua/config/` and `lua/plugins/`.
- `niri/.config/niri/` — niri compositor config split into `cfg/` includes for keybinds, layout, rules, display, input, autostart, animation, and misc.
- `noctalia/.config/noctalia/` and `noctalia/.config/systemd/user/` — Noctalia shell settings, palettes, and user service.
- `herdr/.config/herdr/` — Herdr UI/keybinding config, plugin config, and helper scripts.
- `omp/.omp/` — Oh My Pi agent config, MCP config, skills lock, and plugin manifests.
- `local-bin/.local/bin/` — user scripts linked into `~/.local/bin`.
- `bluetooth-fix/`, `airpods/`, `wol/` — root/user installers for hardware/system setup. Do not stow these.
- `zed/`, `cursor/`, `opencode/`, `lazygit/`, `superset/` — editor/tool UI preferences and themes.

## Development Commands

Run from repo root unless noted.

```fish
# Link/unlink a stow package
stow -t ~ <package>
stow -D -t ~ <package>
stow -R -t ~ <package>

# Typical first-machine stow set
for pkg in nvim zed cursor fish niri noctalia autostart local-bin screencast-nvidia omp
    stow -t ~ $pkg
end

# OMP plugin dependencies after stowing omp/
cd ~/.omp/plugins
npm install

# System packages; run only when the hardware feature applies
sudo sh bluetooth-fix/install.sh
sudo sh airpods/install.sh      # requires bluetooth-fix first
sudo sh wol/install.sh
```

No repo-wide build command exists. No repo-wide lint/test command exists.

## Code Conventions & Common Patterns

- Prefer editing the canonical file in this repo, not the generated/symlinked target under `$HOME`.
- Keep packages as `$HOME` mirrors when they are stow-managed. If a package touches `/etc`, use or extend an installer instead of forcing Stow.
- Fish config uses fish syntax: `set -gx`, `fish_add_path`, `if ...; end`, functions under `fish/.config/fish/functions/`.
- Installer scripts (`*/install.sh`) are POSIX `sh` with `set -eu`, idempotent operations, explicit checks, and clear post-install output.
- User helper scripts are Bash when shell strictness or process handling helps: `#!/usr/bin/env bash` with `set -euo pipefail` where safe.
- Lua uses Stylua settings from `nvim/.config/nvim/stylua.toml`: spaces, width 120, 2-space indentation.
- Neovim customization pattern: small LazyVim plugin specs returning tables from `lua/plugins/*.lua`; avoid broad rewrites of LazyVim defaults.
- Formatter policy in Neovim: `conform.lua` chooses Biome when `biome.json/jsonc` exists, Prettier when a Prettier config exists, otherwise Biome.
- Runtime state and secrets stay out of git: `fish_variables`, `private.fish`, OMP `node_modules/cache`, and Noctalia Hubstaff plugin are ignored.
- Do not add speculative abstraction. This repo favors direct config, short scripts, and comments only where operational context matters.

## Important Files

- `README.md` — deploy model and first-time setup commands.
- `.gitignore` — runtime state exclusions and package-specific ignore rules.
- `fish/.config/fish/config.fish` — shell entry point; activates mise and local conventions.
- `fish/.config/fish/functions/cwt.fish` — worktree navigation/deletion helper for seance/Claude workflows.
- `nvim/.config/nvim/init.lua` and `lua/config/lazy.lua` — Neovim/LazyVim bootstrap.
- `nvim/.config/nvim/lua/plugins/conform.lua` — editor formatting behavior.
- `niri/.config/niri/config.kdl` and `cfg/keybinds.kdl` — compositor entry point and keymap.
- `noctalia/.config/systemd/user/noctalia.service` — Noctalia lifecycle; keep it in systemd, not niri autostart.
- `herdr/.config/herdr/config.toml` — Herdr theme, keys, worktree root, custom commands.
- `herdr/.config/herdr/scripts/herdr-bun-start` — creates a Herdr `Dev` tab and runs `bun start` in the active pane cwd.
- `omp/.omp/agent/mcp.json` — OMP MCP servers; currently enables Argent via `argent mcp`.
- `omp/.omp/plugins/package.json` — OMP plugin deps (`pi-mono-figma`, `ponytail`, `@earendil-works/pi-tui`).
- `airpods/install.sh`, `bluetooth-fix/install.sh`, `wol/install.sh` — system-touching installers.
- `local-bin/.local/bin/display-desk` and `display-tv` — niri output switching scripts.

## Runtime/Tooling Preferences

- Primary interactive shell is fish on CachyOS. Write user-facing shell examples in fish unless editing an existing script with a different shebang.
- Language runtimes are mise-managed; do not install Node/Bun/etc. with pacman. `fish/config.fish` runs `~/.local/bin/mise activate fish`.
- Package manager for OS/AUR installs is `paru`; README installs Stow with `paru -S --needed stow`.
- OMP plugins use npm manifests under `omp/.omp/plugins/`; run `npm install` there after stowing.
- Herdr worktrees live under `~/.worktrees` per `herdr/.config/herdr/config.toml`.
- Noctalia v5 runtime settings may also exist outside this repo under `~/.local/state/noctalia/settings.toml`; verify current runtime state before assuming the checked-in TOML is live.
- `autostart/.config/autostart/` is currently empty; do not reintroduce duplicate desktop autostarts for services already handled by systemd.
- `zsh/.zshrc` is macOS-flavored and not the current host shell; confirm intent before removing Homebrew/proto paths because it may be cross-host config.

## Testing & QA

- There is no CI config, test framework, coverage target, or repo-wide QA command observed.
- For stow-managed config changes, validate the exact consumer when possible: reload the app, restow the package, or run the specific command the config feeds.
- For shell scripts, use the narrowest safe syntax check before behavioral testing:
  - `bash -n path/to/script` for Bash scripts.
  - `sh -n path/to/install.sh` for POSIX installers.
  - Avoid running installers unless the task is explicitly about applying system changes.
- For Neovim Lua, prefer opening Neovim or checking the changed Lua with project tooling if available; keep LazyVim plugin specs small and table-shaped.
- For niri/Noctalia changes, validate through `niri msg`/`noctalia msg` behavior on the live session only when the task requires runtime verification.
- For hardware/system changes, call out required manual checks: Bluetooth reconnect, AirPods audio profile, Wake-on-LAN state, display output switch, or portal/screencast behavior.
