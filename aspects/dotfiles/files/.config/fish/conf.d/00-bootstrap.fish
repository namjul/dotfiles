# Login shells may not have ~/.local/bin yet; add it while mise lives there
if not command -q mise; and test -x $HOME/.local/bin/mise
  fish_add_path $HOME/.local/bin
end
