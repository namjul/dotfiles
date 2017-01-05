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
