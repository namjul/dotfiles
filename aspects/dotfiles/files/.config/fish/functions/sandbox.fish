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

  set -l tmpfs_args
  for folder in (string split : $SANDBOX_BLOCKED_FOLDERS)
    set -a tmpfs_args --tmpfs $folder
  end

  bwrap --dev-bind / / \
        $tmpfs_args \
        --unshare-all \
        --share-net \
        --setenv IN_SANDBOX 1 \
        $target_cmd
end
