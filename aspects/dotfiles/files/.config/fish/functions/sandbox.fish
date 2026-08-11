function sandbox
  if not set -q SANDBOX_BLOCKED_FOLDERS
    echo "⚠️  SANDBOX_BLOCKED_FOLDERS is not set"
    return 1
  end

  for folder in (string split : $SANDBOX_BLOCKED_FOLDERS)
    if not test -d $folder
      echo "⚠️  Warnung: Zielordner $folder wurde auf dem Host nicht gefunden."
    end
  end

  set -l target_cmd $argv
  if test (count $argv) -eq 0
    set target_cmd fish
  end

  echo "🔒 Starte isolierte Sandbox-Umgebung..."
  echo "🚫 Maskiere: $SANDBOX_BLOCKED_FOLDERS (Erscheint für den Agenten komplett leer)"
  echo "🚫 SSH: ~/.ssh + gpg-agent sockets masked; SSH_AUTH_SOCK unset"

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
