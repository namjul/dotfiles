#!/bin/sh

set -eu

gui_user=${GUI_AUTH%%:*}
gui_password=${GUI_AUTH#*:}

if [ "$gui_user" = "$GUI_AUTH" ] || [ -z "$gui_user" ] || [ -z "$gui_password" ]; then
  echo "GUI_AUTH must contain a username and password separated by a colon" >&2
  exit 1
fi

run_as_syncthing() {
  su-exec "${PUID}:${PGID}" "$@"
}

run_as_syncthing /bin/syncthing generate \
  --gui-user="$gui_user" \
  --gui-password="$gui_password" \
  --no-port-probing

wait_for_gui() {
  until curl -fsS http://127.0.0.1:8384/rest/noauth/health >/dev/null; do
    sleep 1
  done
}

run_cli() {
  until STGUIAPIKEY="$gui_api_key" /bin/syncthing cli \
    --gui-address=http://127.0.0.1:8384 \
    "$@"; do
    wait_for_gui
  done
}

apply_policy() {
  wait_for_gui
  gui_api_key=$(sed -n 's:.*<apikey>\([^<]*\)</apikey>.*:\1:p' "$STCONFDIR/config.xml")
  if [ -z "$gui_api_key" ]; then
    echo "Syncthing API key is missing from $STCONFDIR/config.xml" >&2
    return 1
  fi

  # Keep device discovery on the tailnet instead of public discovery servers.
  run_cli config options global-ann-enabled set false
  # Avoid multicast and broadcast discovery on the local network.
  run_cli config options local-ann-enabled set false
  # Require direct connections instead of falling back to public relays.
  run_cli config options relays-enabled set false
  # Prevent Syncthing from asking the router to expose its sync port.
  run_cli config options natenabled set false
  # Decline anonymous usage reporting so the GUI does not ask on first login.
  run_cli config options uraccepted set -- -1

  current_addresses=$(run_cli config options raw-listen-addresses list)
  desired_addresses=$(printf '%s\n%s' tcp://0.0.0.0:22000 quic://0.0.0.0:22000)

  if [ "$current_addresses" != "$desired_addresses" ]; then
    for address in $current_addresses; do
      run_cli config options raw-listen-addresses "$address" delete
    done

    # Offer both supported direct sync transports on the host-published port.
    run_cli config options raw-listen-addresses add tcp://0.0.0.0:22000
    run_cli config options raw-listen-addresses add quic://0.0.0.0:22000
  fi
}

apply_policy &

exec /bin/entrypoint.sh /bin/syncthing serve \
  --no-browser \
  --no-upgrade \
  --gui-address=http://0.0.0.0:8384
