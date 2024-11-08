# bash/dot.bash_profile
#
# Sourced on login shells only
# macOS always starts a login shell.
# @see http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html
#

# Because ~/.profile isn't invoked if this files exists,
# we must source ~/.profile to get its settings:
[[ -f "${HOME}/.profile" ]] && source "${HOME}/.profile"

# The following sources ~/.bashrc in the interactive login case,
# because .bashrc isn't sourced for interactive login shells:
case "$-" in
  *i*)
    [[ -f "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"
    ;;
esac
