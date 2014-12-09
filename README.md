## Setup

### 1. Run software update
Make sure everything is up to date.
### 2. Install Xcode and/or "Command Line Tools"

"Command Line Tools" can be downloaded separate from Xcode at
https://developer.apple.com/downloads/ - 

More info on [how to download Command Line Tools inside XCode can be found on StackOverflow](http://stackoverflow.com/questions/9329243/xcode-4-4-and-later-install-command-line-tools)

### 3. Install homebrew and Git
```sh
# install homebrew
ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
# install git
brew install git
```

### 4. Setup dotfiles

1. Clone dotfiles repo - git clone https://github.com/namjul/dotfiles.git
2. Setup dotfiles - source .sync.sh
3. Create .extra file with git credentials
```
# Git credentials
GIT_AUTHOR_NAME="nam"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="nam@mailinator.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

### 5. Setup osx and install softwares
```sh
# setup osx settings
~/.osx
# install brew formulas
~/.brew
# install cask softwares
~/.cask
```

### 6. Configure Vim Plugins
1. Install powerline font - https://github.com/Lokaltog/powerline-fonts
2. Vunble plugin install - :PluginInstall
3. Set iTerm2 Kontrast to 1/3
4. Setup YouCompleteMe & Tern
```sh
cd ~/.vim/bundle/YouCompleteMe
./install.sh

cd ~/.vim/bundle/tern_for_vim && npm install
```

### 7. Generate SSH keys for github

[generate SSH keys for github](https://help.github.com/articles/generating-ssh-keys)

### 8. Download IE test VMs for VirtualBox

http://www.modern.ie/en-us/virtualization-tools

```sh
# IE8 XP
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_XP/IE8.XP.For.MacVirtualBox.ova"

# IE9 Win7
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar,5.rar}"

# IE10 Win8
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part{1.sfx,2.rar,3.rar}"
```

### 10. End
1. Restart
2. Update OS X stuff

#### Credits

https://github.com/mathiasbynens/dotfiles
https://github.com/paulirish/dotfiles
https://gist.github.com/millermedeiros/6615994
