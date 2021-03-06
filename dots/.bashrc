#
#     ██████╗  █████╗ ███████╗██╗  ██╗██████╗  ██████╗
#     ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔════╝
#     ██████╔╝███████║███████╗███████║██████╔╝██║
#     ██╔══██╗██╔══██║╚════██║██╔══██║██╔══██╗██║
#  ██╗██████╔╝██║  ██║███████║██║  ██║██║  ██║╚██████╗
#  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
#
# sourced on interactive/TTY
# sourced on login shells via .bash_profile
# symlinked to ~/.bashrc
#

# This allows enter in to bash by invoking `bash` command without losing ~/.bashrc configuration:
if [[ $(ps --no-header --pid=$PPID --format=cmd) != "fish" ]]
then
	if ! type brew >/dev/null 2>&1
	# if ! command -v brew >/dev/null 2>&1
	then
		echo "Make sure \`brew\` command is available."
	else
		# Run fish interactive-shell.
		exec fish
	fi
fi
