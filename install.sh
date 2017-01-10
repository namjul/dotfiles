#!/bin/bash

# Set directory
export DOTFILES=${1:-"$HOME/.dotfiles"}

# Ask for password
sudo -v

# Preinstall
if ! hash git 2>/dev/null ; then
  if [ `uname` == 'Darwin' ]; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    # Install Git
    brew install git
  elif [ "$(uname -a | grep -i Ubuntu)" ]; then
    # Install Git with apt-get
    sudo apt-get install git xclip
  else
    error "Error: Git is required."
    exit
  fi
fi

# Clone dotfiles and make symlinks
echo "Installing dotfiles..."

if [ ! -d $DOTFILES ]; then
  git clone git@github.com:namjul/dotfiles.git $DOTFILES
  if [ -d $DOTFILES ]; then
    cd $DOTFILES && ./sync.sh && cd -
  else
    error "Error: Dotfiles weren't installed into $DOTFILES."
    exit
  fi
fi
