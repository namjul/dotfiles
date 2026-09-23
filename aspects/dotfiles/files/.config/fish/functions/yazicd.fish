# https://github.com/sxyazi/yazi/discussions/1034
# https://yazi-rs.github.io/docs/quick-start/#shell-wrapper

function yazicd
	# --- Before yazi: snapshot TTY, then known-good interactive mode ---
	set -l old_tty (stty -g 2>/dev/null) # stty -g: printable settings string for later `stty $old_tty`
	stty sane 2>/dev/null # reset line discipline so the full-screen TUI starts from a normal terminal

	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"

	# --- After yazi: undo full-screen TUI, then put the shell's TTY back ---
	printf '\033[?1049l\033[?25h' 2>/dev/null # leave alt screen; show cursor (TUI may leave these off)
	stty sane 2>/dev/null
	if test -n "$old_tty"
		stty $old_tty 2>/dev/null # restore fish's pre-yazi driver settings
	end

	# --- Shell wrapper: cd to directory yazi had open when it exited ---
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
