function sandbox
  if not set -q SANDBOX_BLOCKED_FOLDERS
    echo sandbox: SANDBOX_BLOCKED_FOLDERS unset >&2
    return 1
  end

  for folder in (string split : $SANDBOX_BLOCKED_FOLDERS)
    if not test -d $folder
      echo sandbox: missing $folder >&2
    end
  end

  set -l target_cmd $argv
  if test (count $argv) -eq 0
    set target_cmd fish
  end

  echo sandbox: masked $SANDBOX_BLOCKED_FOLDERS

  set -l tmpfs_args
  for folder in (string split : $SANDBOX_BLOCKED_FOLDERS)
    set -a tmpfs_args --tmpfs $folder
  end

  # Kill SSH material (keys + agent). Keep full / and --share-net for tooling/HTTPS.
  set -a tmpfs_args --tmpfs $HOME/.ssh
  set -a tmpfs_args --tmpfs /run/user/(id -u)/gnupg

  bwrap --dev-bind / / \
        $tmpfs_args \
        --unshare-all \
        --share-net \
        --unsetenv SSH_AUTH_SOCK \
        --unsetenv SSH_AGENT_PID \
        --unsetenv GPG_AGENT_INFO \
        --setenv IN_SANDBOX 1 \
        $target_cmd
end
