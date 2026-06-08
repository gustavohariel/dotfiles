source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting (disables fastfetch from cachyos-config.fish)
function fish_greeting
end
export PATH="$HOME/.local/bin:$PATH"

# Codex CLI
set -gx CODEX_CLI_PATH ~/.codex/packages/standalone/releases/0.136.0-x86_64-unknown-linux-musl/bin/codex

# mise (language version manager)
~/.local/bin/mise activate fish | source

# Aliases (ls/eza variants come from cachyos-config.fish)
alias vim='nvim'
alias c='clear'
alias oc='opencode'
alias lg='lazygit'

# Machine-local secrets (gitignore'd; not part of dotfiles)
if test -f ~/.config/fish/private.fish
    source ~/.config/fish/private.fish
end

# Android emulator's bundled Qt has no wayland platform plugin; force xcb so it
# uses XWayland instead of crashing on Niri sessions.
set -gx QT_QPA_PLATFORM xcb

# Shell integrations
if type -q fzf
    fzf --fish | source
end
if type -q zoxide
    zoxide init --cmd cd fish | source
end
