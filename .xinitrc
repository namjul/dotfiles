
#Statusbar loop
while true; do
	xsetroot -name "$( date + "%F %R" )"
	sleep 1m # Update time every minute
done &

# Autostart section
#pcmanfm &

# ma caps lock to escape
setxkbmap -option ctrl:nocaps
xcape -e 'Control_L=Escape'

# load Xresources
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# set keyboard speed
xset r rate 200 30

exec startdwm
