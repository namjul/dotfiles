

##############################################################################
# 02. ALIASES                                                                #
##############################################################################

# quick switches to folders
abbr cdd 'cd $HOME/.dotfiles'
abbr d 'cd ~/Dropbox'

# quick edits to dot files
abbr vr 'nvim ~/.vimrc'
abbr vd 'nvim ~/.dotfiles/dots'
abbr vf 'nvim ~/.config/fish/config.fish'

abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .... 'cd ../../..'
abbr ..... 'cd ../../../..'
abbr --add -- - 'cd -'

abbr h 'history'
abbr j 'jobs'
abbr l 'less'

abbr mv 'mv -i'
abbr cp 'cp -i -p'
abbr grep 'grep --color=auto'
abbr g 'git'
abbr gs 'git status'
abbr week 'date +%V' # Get week number
abbr path 'echo $PATH | tr -s " " "\n"' # Pretty print the path
alias cat 'bat' # Drop-in replacement for cat
abbr tms "$HOME/.dotfiles/scripts/tmux-setup.sh" # tmux setup
abbr tmp ' cd (mktemp -d)'
abbr pbcopy 'xclip -selection clipboard' # replicate pbcopy from macos
abbr pbpaste 'xclip -selection clipboard -o'
abbr x exit
abbr t tmux
abbr en 'trans :en'
abbr de 'trans :de'

# ls
set TREE_IGNORE 'cache|log|logs|node_modules|vendor'
alias ls 'exa --group-directories-first'
abbr la 'ls -a'
abbr ll 'ls --git -l'
abbr lt 'ls --tree -D -L 2 -I $TREE_IGNORE'
abbr ltt 'ls --tree -D -L 3 -I $TREE_IGNORE'
abbr lttt 'ls --tree -D -L 4 -I $TREE_IGNORE'
abbr ltttt 'ls --tree -D -L 5 -I $TREE_IGNORE'

# vim
if command -v nvim &> /dev/null
  abbr v nvim
  abbr vim nvim # Use `\vim` or `command vim` to get the real vim.
end
