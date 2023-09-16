#!/usr/bin/env bash

grep -rh Exec ~/.config/autostart | while read -r line ; do 
   ${line:5} &
done

# grep -rh Exec /etc/xdg/autostart | while read -r line ; do 
#    ${line:5} &
# done
