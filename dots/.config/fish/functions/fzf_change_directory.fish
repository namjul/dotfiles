
# inspiration from https://youtu.be/KKxhf50FIPI?t=754
# https://github.com/craftzdog/dotfiles-public/blob/master/.config/fish/functions/peco_change_directory.fish
# https://gist.github.com/tsub/4448666a276b088bce3f19005f512c15
function fzf_change_directory -d "Change directory"
  begin 
    echo $HOME/.config
    echo $HOME/.dotfiles
    ghq list -p
    command rg --files --follow --no-ignore-vcs --max-depth 3 ~/code . --null 2> /dev/null | xargs -0 dirname | grep -vxF '.'
  end | sed -e 's/\/$//' | sort | uniq | fzf | read foo -l

  if [ $foo ]
    builtin cd $foo
    commandline -r ''
    commandline -f repaint
  else
    commandline ''
  end
end
