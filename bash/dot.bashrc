# dot.bashrc
#
# sourced on interactive/TTY
# sourced on login shells via .bash_profile
# symlinked to ~/.bashrc
#

source "${HOME}/.dotfiles/shell/vars.sh"

# Source the dotfiles (order matters)
source "${SHELL_DOTFILES}/functions.sh"
source "${SHELL_DOTFILES}/path.sh"
source "${SHELL_DOTFILES}/alias.sh"

# Options
shopt -s nocaseglob # Case-insensitive globbing (used in pathname expansion)
shopt -s histappend # Append to the Bash history file, rather than overwriting it
shopt -s cdspell # Autocorrect typos in path names when using `cd`
shopt -s dotglob # expand filenames starting with dots too

# Plugins
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null
done

# completion
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# Enable tab completion for `g` by marking it as an alias for `git`
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
  __git_complete g _git # http://stackoverflow.com/a/10707579
fi

# https://askubuntu.com/questions/591937/no-value-for-term-and-no-t-specified
if [[ $- == *i* ]]; then 
  source "${BASH_DOTFILES}/prompt.bash"
fi

if [[ -a ~/.localrc ]]; then
    source ~/.localrc
fi
