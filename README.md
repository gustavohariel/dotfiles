# Dotfiles

Personal configuration files for a CachyOS + niri + Noctalia setup, plus
cross-host editor configs (nvim/zed/cursor/zsh).

## Layout

Each top-level directory is a deploy unit ("package"). Two flavors:

**Stow packages** — mirror `$HOME` shape. Deploy with:

```fish
cd ~/sandbox/dotfiles
stow -t ~ <package>          # link
stow -D -t ~ <package>       # unlink
stow -R -t ~ <package>       # restow (refresh)
```

| Package | Targets | Notes |
| --- | --- | --- |
| `nvim/` | `~/.config/nvim/` | lazy.nvim, custom colors, snippets |
| `zed/` | `~/.config/zed/` | settings/keymap/tasks |
| `cursor/` | `~/.config/Cursor/User/` (Linux) | rename `keybinds.json` → `keybindings.json` if Cursor expects it |
| `zsh/` | `~/.zshrc` | macOS-flavored — see `CLAUDE.md` before deploying on Linux |
| `fish/` | `~/.config/fish/{config.fish,conf.d/,functions/,completions/}` | sources `~/.config/fish/private.fish` if present (gitignored) |
| `niri/` | `~/.config/niri/` | split into `cfg/*.kdl` includes |
| `noctalia/` | `~/.config/noctalia/` | excludes `plugins/hubstaff/` (own repo) |
| `autostart/` | `~/.config/autostart/` | bitwarden, electron, librepods .desktop entries |
| `local-bin/` | `~/.local/bin/` | `display-desk`, `display-tv` (niri output switching) |
| `screencast-nvidia/` | `~/.config/xdg-desktop-portal/`, `~/.config/systemd/user/xdg-desktop-portal-gnome.service.d/` | NVIDIA+Wayland screencast workaround (wlr portal + `GSK_RENDERER=gl`) |
| `omp/` | `~/.omp/agent/`, `~/.omp/agent/skills/`, `~/.omp/plugins/package*.json` | Oh My Pi config, OMP skills, plus plugin manifests; run `npm install` in `~/.omp/plugins` after stowing |

**Script-installed packages** — touch `/etc` too, so stow is the wrong tool. Deploy with `sudo sh <pkg>/install.sh`. Idempotent.

| Package | Notes |
| --- | --- |
| `bluetooth-fix/` | Realtek RTL8761BU autosuspend + `main.conf` baselines. Install first. |
| `airpods/` | librepods (AUR) + AirPods-specific `main.conf` + wireplumber + user systemd unit. Depends on `bluetooth-fix`. |
| `wol/` | Enables Wake-on-LAN (magic packet) on the primary ethernet NIC via NetworkManager. Used with iPhone "Wake Me Up". |

**Other**

- `superset/themes/` — themes for [superset.sh](https://superset.sh); loaded in-app, no filesystem deploy.

## First-time setup on a new machine

```fish
paru -S --needed stow
cd ~/sandbox/dotfiles
sudo sh bluetooth-fix/install.sh   # only if Realtek/AirPods bluetooth wanted
sudo sh airpods/install.sh         # depends on bluetooth-fix
sudo sh wol/install.sh             # only if Wake-on-LAN wanted
for pkg in nvim zed cursor fish niri noctalia autostart local-bin screencast-nvidia omp
    stow -t ~ $pkg
end
cd ~/.omp/plugins
npm install
```

Skip packages that don't apply (e.g. `screencast-nvidia` is only useful on NVIDIA+Wayland; `cursor` only if Cursor is installed).

## License
MIT
