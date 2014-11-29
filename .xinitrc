# ma caps lock to escape
setxkbmap -option ctrl:nocaps
xcape -e 'Control_L=Escape'

# load .Xresources
xrdb -merge $HOME/.Xresources

# add in fonts
xset +fp /usr/share/fonts/local  

#start dropbox daemon
#dropboxd &

# enable restart X
setxkbmap -option terminate:ctrl_alt_bksp

# set background-color
xsetroot -solid "#222222"

# set keyboard speed
xset r rate 200 30

# ---- window manager ----
# launch dwm
while true; do
		$HOME/scripts/dwm-statusbar
    	sleep 2
done &

while true; do
	# dwm >/dev/null
	# to log stderrors to a file
	dwm 2> ~/dwm.log
done
