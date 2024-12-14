# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

[[ -f /opt/vultr/vultr_app.sh ]] && . /opt/vultr/vultr_app.sh

export LS_OPTIONS='--color=auto'

eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias cs='cd /home/square'
alias ca='cd /home/square/aspects'

function ..() {
    cd ..
}

log() {
    journalctl -u "$1.service" | vim -
}

export PATH="$HOME/.local/bin:$PATH"
