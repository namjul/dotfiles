#!/usr/bin/env bash

# Get current dir (so run this script from anywhere)

export DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export EXTRA_DIR="$HOME/.extra"

# Update dotfiles itself first

[ -d "$DOTFILES_DIR/.git" ] && git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master

# Bunch of symlinks

# (n)vim
ln -sfv "$DOTFILES_DIR/vim" ~/.vim
ln -sfv "$DOTFILES_DIR/vim/vimrc" ~/.vimrc
ln -sfv "$DOTFILES_DIR/vim" ~/.config/nvim

ln -sfv "$DOTFILES_DIR/git/dot.gitconfig" ~/.gitconfig
ln -sfv "$DOTFILES_DIR/git/got.gitignore" ~/.gitignore_global
ln -sfv "$DOTFILES_DIR/shell/dot.inputrc" ~/.inputrc
ln -sfv "$DOTFILES_DIR/todo/dot.todo.cfg" ~/.todo.cfg
ln -sfv "$DOTFILES_DIR/tmux/tmux.conf" ~/.tmux.conf

# default tern-project
ln -sfv "$DOTFILES_DIR/ternjs/dot.tern-project" ~/.tern-project

# symlink shells
ln -sfv "$DOTFILES_DIR/bash/dot.bashrc" ~/.bashrc
ln -sfv "$DOTFILES_DIR/bash/dot.bash_profile" ~/.bash_profile

# symlink xmonad % xmobar
ln -sfv "$DOTFILES_DIR/xmonad/dot.xmonad.hs" ~/.xmonad/xmonad.hs
ln -sfv "$DOTFILES_DIR/xmonad/dot.xmobarrc" ~/.xmobarrc

# Package managers & packages

# . "$DOTFILES_DIR/install/brew.sh"
# . "$DOTFILES_DIR/install/bash.sh"
# . "$DOTFILES_DIR/install/npm.sh"
# . "$DOTFILES_DIR/install/pip.sh"

# if [ "$(uname)" == "Darwin" ]; then
  # . "$DOTFILES_DIR/install/brew-cask.sh"
  # . "$DOTFILES_DIR/install/gem.sh"
  # ln -sfv "$DOTFILES_DIR/etc/mackup/.mackup.cfg" ~
# fi

# Run tests

# bats test/*.bats

# Install extra stuff

# if [ -d "$EXTRA_DIR" -a -f "$EXTRA_DIR/install.sh" ]; then
  # . "$EXTRA_DIR/install.sh"
# fi
