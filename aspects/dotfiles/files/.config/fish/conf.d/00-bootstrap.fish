# Login shells may not have ~/.local/bin yet; conf.d/20-path.fish loads later
if not command -q mise; and test -x $HOME/.local/bin/mise
  fish_add_path $HOME/.local/bin
end
