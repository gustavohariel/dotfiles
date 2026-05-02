source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
export PATH="$HOME/.local/bin:$PATH"

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

# Shell integrations
if type -q fzf
    fzf --fish | source
end
if type -q zoxide
    zoxide init --cmd cd fish | source
end
