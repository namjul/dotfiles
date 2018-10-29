## Installation

Clone dotfiles to home directory
```
git clone https://github.com/namjul/dotfiles
```

Run install script
```
./install
```

## Manual steps 
- Installa [alacritty](https://github.com/jwilm/alacritty)
- Install [xcape](https://github.com/alols/xcape) 
- Set caps lock to ctrl http://askubuntu.com/questions/363346/how-to-permanently-switch-caps-lock-and-escctrl:nocaps
- Run `setxkbmap -option ctrl:nocaps` && `xcape -e 'Control_L=Escape'` at startup
- Run `xset r rate 200 30` at startup
- Setup font https://github.com/nathco/Office-Code-Pro

## Todos
- [ ] vim filename should include folder
- [ ] Ag command on selected/highlighted word

