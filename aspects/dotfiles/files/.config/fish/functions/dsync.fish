function dsync --description="All dendron sync in current director"
  if type -q dendron
    repos
    read -l -P 'Do you want to continue? [y/N] ' confirm
    switch $confirm
      case Y y
        dendron workspace --wsRoot . sync
      case '' N n
        return 1
    end
  else
    echo "Make sure \`dendron\` command is available."
  end
end
