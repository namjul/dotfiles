# https://github.com/sxyazi/yazi/discussions/1034
# https://yazi-rs.github.io/docs/quick-start/#shell-wrapper

function yazicd
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
