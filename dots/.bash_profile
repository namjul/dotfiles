# bash/dot.bash_profile
#
# Sourced on login shells only
# macOS always starts a login shell.
# @see http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html
#

# In an graphical mode `.profile` is run (e.g. lightDM)
[[ -f "${HOME}/.profile" ]] && source "${HOME}/.profile"

 # if source as interactive-shell
[[ -f "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"
