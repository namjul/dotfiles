# dotfiles [⛰ ](screenshot.png)

## Parts

- list of [software i use](scripts/brew)
- globally installed [npm packages](dots/default-npm-packages)
- [neovim](dots/.config/nvim/init.lua)
- [tmux config](dots/tmux.conf)
- [alacritty](dots/alacritty.yml)
- [gitconfig](dots/gitconfig)
- [fish configuration](dots/.config/fish/config.fish)
- [aliases](dots/.config/fish/alias.fish), [functions](dots/.config/fish/functions.fish)
- [starship](dots/starship)
- [espanso](dots/.config/espanso/default.yml)
- [zathura](dots/.config/zathura/zathurarc)
- [ripgrep](dots/.ripgreprc)

## Dependencies

### Homebrew

Homebrew needs to be setup for scripts to work.
This can be done by adding the following to `~/.profile`:

```sh
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
```

## Installation

Clone dotfiles to home directory

```
git clone --recursive https://github.com/namjul/dotfiles ~/.dotfiles
```

cd and run `install`

### git

```bash
export GIT_AUTHOR_NAME="name"
export GIT_AUTHOR_EMAIL="email"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

# Set the credentials (modifies ~/.gitconfig)
git config --global user.name "$GIT_AUTHOR_NAME"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

# Others

- https://github.com/necolas/dotfiles
- https://github.com/sarrost/dotfiles
- https://github.com/simonsmith/dotfiles
- https://github.com/nicknisi/dotfiles
- https://github.com/wincent/wincent
