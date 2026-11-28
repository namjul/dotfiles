/**
 * Notify Extension
 *
 * On agent_end, name the tmux pane and pi session captured from this process.
 * A click selects that pane and focuses the terminal that owns it.
 */

import type {ExtensionAPI} from '@earendil-works/pi-coding-agent';
import {execFile} from 'node:child_process';

// The pane process is a child of the tmux server, not of the terminal.
// Switch the client onto the pane, then walk from that client up to the window niri knows.
const focusPane = `
pane=$1

client_pid=$(tmux display-message -t "$pane" -p '#{client_pid}') || exit 0
client_tty=$(tmux list-clients -F '#{client_pid} #{client_tty}' | awk -v pid="$client_pid" '$1 == pid { print $2; exit }')
if [ -n "$client_tty" ]; then
  tmux switch-client -c "$client_tty" -t "$pane"
fi

window_for_pid() {
  niri msg windows | awk -v want="$1" '
    /^Window ID / { id = $3; sub(/:$/, "", id) }
    $1 == "PID:" && $2 == want { print id; exit }
  '
}

parent_of() {
  awk '/^PPid:/ { print $2 }' "/proc/$1/status" 2>/dev/null
}

pid=$client_pid
win=
i=0
while [ "$i" -lt 12 ] && [ -n "$pid" ] && [ "$pid" != 0 ] && [ "$pid" != 1 ]; do
  win=$(window_for_pid "$pid")
  if [ -n "$win" ]; then
    break
  fi
  pid=$(parent_of "$pid") || break
  i=$((i + 1))
done

if [ -n "$win" ]; then
  niri msg action focus-window --id "$win"
fi
`;

function placeOf(pane: string): Promise<string> {
  return new Promise((resolve) => {
    execFile('tmux', ['display-message', '-t', pane, '-p', '#S:#W.#P'], (error, stdout) => {
      resolve(error ? pane : stdout.trim());
    });
  });
}

function notify(summary: string, pane: string | undefined): void {
  const args = pane
    ? ['-a', 'pi', '-t', '0', '-A', 'default=Focus', '-w', summary, 'Ready for input']
    : ['-a', 'pi', summary, 'Ready for input'];
  const child = execFile('notify-send', args);
  child.on('error', () => {});
  if (!pane) return;
  child.stdout?.on('data', (chunk: Buffer) => {
    if (String(chunk).trim() !== 'default') return;
    execFile('sh', ['-c', focusPane, 'sh', pane]).on('error', () => {});
  });
}

export default function (pi: ExtensionAPI): void {
  pi.on('agent_end', async (_event, ctx) => {
    if (!ctx.hasUI) return;
    const pane = process.env.TMUX_PANE;
    const session = ctx.sessionManager.getSessionName() || ctx.sessionManager.getSessionId();
    const place = pane ? await placeOf(pane) : '';
    const summary = ['pi', place, session].filter(Boolean).join(' ');
    notify(summary, pane);
  });
}
