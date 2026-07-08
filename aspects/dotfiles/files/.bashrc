#
#     ██████╗  █████╗ ███████╗██╗  ██╗██████╗  ██████╗
#     ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔════╝
#     ██████╔╝███████║███████╗███████║██████╔╝██║
#     ██╔══██╗██╔══██║╚════██║██╔══██║██╔══██╗██║
#  ██╗██████╔╝██║  ██║███████║██║  ██║██║  ██║╚██████╗
#  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
#
# Interactive bash shim: hand off to fish, or stay in bash when nested.
# Login chain: .bash_profile → .profile → .bashrc (interactive login only)

# If not running interactively, don't do anything (leave this at the top)
[[ $- != *i* ]] && return

# Auto-launch fish for top-level interactive bash (not when bash is run from fish)
if command -v fish &>/dev/null; then
  if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" \
    && -z ${BASH_EXECUTION_STRING} \
    && ${SHLVL} == 1 ]]; then
    shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    exec fish $LOGIN_OPTION
  fi
fi

# Intentional bash session (nested shell, `bash` from fish, scripts that spawn bash)
[[ -f "${HOME}/.config/bash/rc" ]] && source "${HOME}/.config/bash/rc"
