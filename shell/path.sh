
# Add custom bin path
[ -d ~/.dotfiles/bin ] && prepend-path ~/.dotfiles/bin
[ -d ~/bin ] && prepend-path ~/bin
[ -d ~/.local/bin ] && prepend-path ~/.local/bin
[ -d ~/.cargo/bin ] && prepend-path ~/.cargo/bin
[ -d /home/linuxbrew/.linuxbrew ] && prepend-path /home/linuxbrew/.linuxbrew/bin
