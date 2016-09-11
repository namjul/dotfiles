#!/bin/bash

# Install Neovim
echo "Installing Neovim..."

if [ "$(uname)" == "Darwin" ]; then
  brew install neovim/neovim/neovim
elif [ "$(uname -a | grep -i Ubuntu)" ]; then
  sudo apt-get install software-properties-common
  sudo add-apt-repository ppa:neovim-ppa/unstable
  sudo apt-get update
  sudo apt-get install neovim
  
  # install prerequisits for python modules
  sudo apt-get install python-dev python-pip python3-dev python3-pip

  # install neovim python packages
  sudo pip2 install neovim
  sudo pip3 install neovim
else
  echo "Error: Could not install Neovim for your OS."
  exit 1
fi

# Change dir to Dotfiles
cd "$HOME/Dotfiles"

# Create .vim dir
mkdir -p "$HOME/.vim/backups"
mkdir -p "$HOME/.vim/swaps"
mkdir -p "$HOME/.vim/bundle"
mkdir -p "$HOME/.vim/undo"

# Install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# link file to nvim
mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
ln -s ~/.vim $XDG_CONFIG_HOME/nvim
ln -s ~/.vimrc $XDG_CONFIG_HOME/nvim/init.vim

# Install plugins
git clone https://github.com/VundleVim/Vundle.Vim ~/.vim/bundle/Vundle.vim
nvim +PlugInstall

# Come back to previous dir
cd -
