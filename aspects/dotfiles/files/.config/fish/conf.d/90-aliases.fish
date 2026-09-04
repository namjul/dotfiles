if status is-interactive

# quick edits
alias e $EDITOR

# navigation
abbr d cd
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .... 'cd ../../..'
abbr ..... 'cd ../../../..'
abbr --add -- - 'cd -'

# quick switches to folders
abbr dd 'cd $HOME/.dotfiles'
abbr db 'cd ~/Dropbox'
abbr dc 'cd ~/code'
abbr dls 'cd ~/.local/share'

# shell
abbr h 'history'
abbr j 'jobs'
abbr x exit

# git
abbr g 'git'
abbr --command git grn 'git rebase -i HEAD~' # git interactive rebase to n
abbr --command git co checkout

# translation
abbr en 'trans :en'
abbr de 'trans :de'

# node
abbr repl 'NODE_PATH=(npm root -g) node'
abbr run 'nr' # expands so history stores dum run <script>
abbr nv 'ni -v'

# timewarrior
abbr tw timew
abbr twst timew start
abbr twsp timew stop
abbr twa timew annotate
abbr twc timew continue
abbr twd timew delete
abbr tws timew summary :annotation :ids :week

# zeit https://github.com/mrusme/zeit
abbr z zeit
abbr zst 'zeit start'
abbr zsp 'zeit end'
abbr zsw 'zeit switch'
abbr za 'zeit start with note'
abbr zc 'zeit resume'
abbr zs 'zeit blocks this week'
abbr zss 'zeit stats this week'

# todo
abbr T todo

# tmux
abbr tb "tmux new -s (pwd | sed 's/.*\///g')" # begin tmux session

# docker — stay out of the docker group; sudo for CLI, launch-lazydocker for TUI
abbr dcu "sudo docker compose up"
abbr dsa "sudo docker stop (sudo docker ps -a -q)"

# misc
abbr mv 'mv -i'
abbr cp 'cp -i -p'
abbr grep 'grep --color=auto'
abbr week 'date +%V' # Get week number
abbr path 'echo $PATH | tr -s " " "\n"' # Pretty print the path
alias cat="bat" # Drop-in replacement for cat TODO add  --theme=gruvbox-(set-colorscheme) but a fast implementation
abbr tmp ' cd (mktemp -d)'
abbr untar 'tar -xvf' # extract .tar.gz
abbr --add unset 'set --erase' # remove env variable
abbr mr 'mise run --all' # run mise tasks
abbr dspace 'du -cha --max-depth=1 . | grep -E "M|G"'
alias pass 'gopass'
abbr sb sandbox

# replicate pbcopy from macos (wl-clipboard on Wayland, xclip on X11)
if set -q WAYLAND_DISPLAY
  alias pbcopy wl-copy
  alias pbpaste wl-paste
else
  alias pbcopy 'xclip -selection clipboard'
  alias pbpaste 'xclip -selection clipboard -o'
end

# IP addresses
abbr globalip "dig +short myip.opendns.com @resolver1.opendns.com"
abbr localip 'ip -o route get to 8.8.8.8 | sed -n "s/.*src \([0-9.]\+\).*/\1/p"'

# ls
if type -q eza
  set TREE_IGNORE 'cache|log|logs|node_modules|vendor|.git'
  alias ls 'eza --icons --header --group --smart-group'
  abbr la 'ls -a'
  abbr ll 'ls -l --sort newest'
  abbr lla 'ls -l --sort newest -a'
  abbr lt 'ls --tree -D -L 2 -I $TREE_IGNORE'
  abbr ltt 'ls --tree -D -L 3 -I $TREE_IGNORE'
  abbr lttt 'ls --tree -D -L 4 -I $TREE_IGNORE'
end

# Mnemonic: [C]lip
abbr -a C --position anywhere --set-cursor "% | pbcopy"

# Mnemonic: [D]elta (Diff viewer)
abbr -a D --position anywhere --set-cursor "% | delta"

# Mnemonic: [G]rep (Cursor steht danach direkt für den Suchbegriff bereit)
abbr -a G --position anywhere --set-cursor "| grep %"

# Mnemonic: [H]ead
abbr -a H --position anywhere "| head"

# Mnemonic: [J]SON (Pretty-print)
abbr -a J --position anywhere "| python3 -m json.tool"

# Mnemonic: [L]ess
abbr -a L --position anywhere --set-cursor "% | less -R"

# Mnemonic: [W]c (Line count)
abbr -a W --position anywhere "| wc -l"

end
