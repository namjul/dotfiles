# ~/.bashrc: executed by bash(1) for non-login shells.

export LS_OPTIONS='--color=auto'

eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
function ..() {
    cd ..
}

log() {
    journalctl -u "$1.service" | vim -
}

export PATH="$HOME/.local/bin:$PATH"
