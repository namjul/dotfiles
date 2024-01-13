#!/bin/bash

set -euxo pipefail # https://github.com/guettli/programming-guidelines#shell-scripts-are-ok-if-

xset r rate 200 30
setxkbmap -option 'caps:ctrl_modifier'
xcape -e 'Control_L=Escape'
