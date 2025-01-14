#!/bin/bash

DOTFILES="$HOME/dotfiles"

# Neovim setup
mkdir -p ~/.config/nvim
ln -sf $DOTFILES/nvim/init.lua ~/.config/nvim/init.lua
ln -sf $DOTFILES/nvim/lua ~/.config/nvim/lua

# tmux setup
ln -sf $DOTFILES/tmux/tmux.conf ~/.tmux.conf

# Ghostty setup
# ln -sf $DOTFILES/ghostty/config ~/.config/ghostty/conig

# zsh setup
ln -sf $DOTFILES/zsh/zshrc ~/.zshrc

echo "Dotfiles installation complete!"
