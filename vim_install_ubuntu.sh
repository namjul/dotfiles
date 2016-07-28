# ubuntu install

sudo apt-get install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install build-essential cmake neovim xsel
sudo apt-get install python-dev python-pip python3-dev python3-pip
sudo pip2 install neovim
sudo pip3 install neovim

# make symlink
./makesymlinks.sh

# link file to nvim
mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
ln -s ~/.vim $XDG_CONFIG_HOME/nvim
ln -s ~/.vimrc $XDG_CONFIG_HOME/nvim/init.vim

# install vundle
git clone https://github.com/VundleVim/Vundle.Vim ~/.vim/bundle/Vundle.vim
nvim +PluginInstall

# WARN: from here on its manual
echo "Please continue manually (see vim_install_ubuntu.sh)"
exit

# install https://github.com/creationix/nvm

# install xcape
git clone https://github.com/alols/xcape.git 
cd xcape
make
sudo make install
xcape -e 'Control_L=Escape'
