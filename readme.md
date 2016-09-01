## Setup


### Ubuntu

1. ./vim_install_ubuntu.sh

2. install https://github.com/namjul/dwm

#### sources
- Set caps lock to ctrl http://askubuntu.com/questions/363346/how-to-permanently-switch-caps-lock-and-escctrl:nocaps

### OSX

1. Run software update
2. Install Xcode and/or "Command Line Tools"
  "Command Line Tools" can be downloaded separate from Xcode at
  https://developer.apple.com/downloads/ - 

  More info on [how to download Command Line Tools inside XCode can be found on StackOverflow](http://stackoverflow.com/questions/9329243/xcode-4-4-and-later-install-command-line-tools)

3. Install homebrew and Git
  ```sh
# install homebrew
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
# install git
  brew install git
  ```

4. Setup dotfiles


5. Setup osx and install softwares
  ```sh
  # setup osx settings
  https://gist.github.com/MatthewMueller/e22d9840f9ea2fee4716

  # install brew formulas
  ~/.brew

  # install cask softwares
  ~/.cask
  ```

6. Configure Vim Plugins

7. Generate SSH keys for github
[generate SSH keys for github](https://help.github.com/articles/generating-ssh-keys)

8. Download IE test VMs for VirtualBox
http://www.modern.ie/en-us/virtualization-tools

```sh
# IE8 XP
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_XP/IE8.XP.For.MacVirtualBox.ova"

# IE9 Win7
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar,5.rar}"

# IE10 Win8
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part{1.sfx,2.rar,3.rar}"
```
