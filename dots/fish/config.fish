
function setenv
  set -gx $argv
end

set yellow "#fabd2f"
set orange "#fe8019"
set red "#fb4934"
set blue "#83a598"
set green "#b8bb26"
set purple "#d3869b"
set aqua "#689d6a"

set command_color "#ebdbb2"
set autosuggestions_color "#665c54"

set -g fish_color_autosuggestion $autosuggestions_color # the color used for autosuggestions
set -g fish_color_cancel normal # the color for the '^C' indicator on a canceled command
set -g fish_color_command $command_color # the color for commands
set -g fish_color_comment $yellow # the color used for code comments
# set -g fish_color_cwd "#008000" # the color used for the current working directory in the default prompt
# set -g fish_color_cwd_root "#800000"
set -g fish_color_end $aqua # the color for process separators like ';' and '&'
set -g fish_color_error $red # the color used to highlight potential errors
set -g fish_color_escape $yellow # the color used to highlight character escapes like '\n' and '\x70'
set -g fish_color_history_current normal
set -g fish_color_host normal # the color used to print the current host system in some of fish default prompts
set -g fish_color_match $aqua # the color used to highlight matching parenthesis
set -g fish_color_normal normal # the default color
set -g fish_color_operator $yellow # the color for parameter expansion operators like '*' and '~'
set -g fish_color_param $blue # the color for regular command parameters
set -g fish_color_quote $yellow # the color for quoted blocks of text
set -g fish_color_redirection $aqua # the color for IO redirections
set -g fish_color_search_match $yellow # used to highlight history search matches and the selected pager item (must be a background)
set -g fish_color_selection "#c0c0c0" # the color used when selecting text (in vi visual mode)
set -g fish_color_user $green # the color used to print the current username in some of fish default prompts
set -g fish_color_valid_path normal

starship init fish | source
