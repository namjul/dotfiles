if status is-interactive
  if type -q shellfirm
    function checkShellFirm --on-event fish_preexec
      stty sane
      shellfirm pre-command --command "$argv"
      commandline -f execute
    end
  else
    # show this message to the user and don't register to terminal hook
    # we want to show the user that he not protected with `shellfirm`
    echo "`shellfirm` binary is missing. see installation guide: https://github.com/kaplanelad/shellfirm"
  end
end
