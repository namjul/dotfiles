/**
 * Notify Extension
 *
 * On agent_end, name the place this process runs in and send a notification
 * unless that place is already on screen. A click focuses it.
 *
 * Inside tmux the place is the pane, and the terminal is reached through the
 * tmux client. Outside tmux pi itself sits under the terminal.
 */

import type {ExtensionAPI} from '@earendil-works/pi-coding-agent';
import {execFile} from 'node:child_process';
import {readFile} from 'node:fs/promises';

// An empty pane means pi runs outside tmux. The window was resolved in TypeScript.
const focusPlace = `
pane=$1
window=$2

if [ -n "$pane" ]; then
  client_pid=$(tmux display-message -t "$pane" -p '#{client_pid}' 2>/dev/null)
  client_tty=$(tmux list-clients -F '#{client_pid} #{client_tty}' | awk -v pid="$client_pid" '$1 == pid { print $2; exit }')
  if [ -n "$client_tty" ]; then
    tmux switch-client -c "$client_tty" -t "$pane"
  fi
fi

if [ -n "$window" ]; then
  niri msg action focus-window --id "$window"
fi
`;

interface NiriWindow {
  readonly id: number;
  readonly pid: number;
  readonly appId: string;
  readonly focused: boolean;
}

interface Place {
  readonly pane: string | undefined;
  readonly drawn: boolean;
  readonly owner: string;
}

interface TmuxPane {
  readonly drawn: boolean;
  readonly clientPid: string | undefined;
}

function run(file: string, args: ReadonlyArray<string>): Promise<string | undefined> {
  return new Promise((resolve) => {
    execFile(file, [...args], (error, stdout) => {
      resolve(error ? undefined : stdout.trim());
    });
  });
}

// The tmux client is a child of the terminal process, which is what niri knows as a window.
async function ancestorPids(pid: string): Promise<ReadonlyArray<string>> {
  const chain: string[] = [];
  let current = pid;
  while (current && current !== '0' && current !== '1' && chain.length < 16) {
    chain.push(current);
    const status = await readFile(`/proc/${current}/status`, 'utf8').catch(() => '');
    const parent = /^PPid:\s+(\d+)/m.exec(status)?.[1];
    if (!parent) break;
    current = parent;
  }
  return chain;
}

async function niriWindows(): Promise<ReadonlyArray<NiriWindow>> {
  const output = await run('niri', ['msg', '--json', 'windows']);
  if (!output) return [];
  try {
    const parsed: unknown = JSON.parse(output);
    if (!Array.isArray(parsed)) return [];
    const windows: NiriWindow[] = [];
    for (const entry of parsed as ReadonlyArray<Record<string, unknown>>) {
      if (typeof entry.id !== 'number' || typeof entry.pid !== 'number') continue;
      windows.push({
        id: entry.id,
        pid: entry.pid,
        appId: typeof entry.app_id === 'string' ? entry.app_id : '',
        focused: entry.is_focused === true,
      });
    }
    return windows;
  } catch {
    return [];
  }
}

async function niriWindowOf(
  pid: string,
  windows: ReadonlyArray<NiriWindow>,
): Promise<NiriWindow | undefined> {
  const chain = await ancestorPids(pid);
  return windows.find((window) => chain.includes(String(window.pid)));
}

async function tmuxPane(pane: string): Promise<TmuxPane | undefined> {
  const format =
    '#{session_attached} #{window_active} #{client_pid} #{pane_id} #{window_visible_layout}';
  const probe = await run('tmux', ['display-message', '-t', pane, '-p', format]);
  if (!probe) return undefined;
  const [attached, active, clientPid, id, ...layout] = probe.split(' ');
  return {
    clientPid,
    drawn: Number(attached) > 0 && active === '1' && layout.join(' ').includes(`"${id}"`),
  };
}

// The sandbox puts pi in its own pid namespace while /proc shows host pids, so
// process.pid cannot be looked up. /proc/self/stat carries the pid the host sees.
async function placePid(): Promise<string> {
  const stat = await readFile('/proc/self/stat', 'utf8').catch(() => '');
  return /^(\d+) /.exec(stat)?.[1] ?? String(process.pid);
}

async function resolvePlace(): Promise<Place> {
  const pane = process.env.TMUX_PANE;
  const probe = pane ? await tmuxPane(pane) : undefined;
  return {
    pane,
    drawn: probe?.drawn ?? true,
    owner: probe?.clientPid || (await placePid()),
  };
}

async function placeOf(place: Place): Promise<string | undefined> {
  if (!place.pane) return undefined;
  return (await run('tmux', ['display-message', '-t', place.pane, '-p', '#S:#W.#P'])) ?? place.pane;
}

async function inView(place: Place, windows: ReadonlyArray<NiriWindow>): Promise<boolean> {
  if (!place.drawn) return false;
  const focused = windows.find((window) => window.focused);
  if (!focused) return false;
  const chain = await ancestorPids(place.owner);
  return chain.includes(String(focused.pid));
}

function notify(summary: string, place: Place, window: NiriWindow | undefined): void {
  const clickable = Boolean(place.pane || window);
  const args = clickable
    ? ['-a', 'pi', '-t', '0', '-A', 'default=Focus', '-w', summary, 'Ready for input']
    : ['-a', 'pi', summary, 'Ready for input'];
  const child = execFile('notify-send', args);
  child.on('error', () => {});
  if (!clickable) return;
  child.stdout?.on('data', (chunk: Buffer) => {
    if (String(chunk).trim() !== 'default') return;
    const target = [place.pane ?? '', String(window?.id ?? '')];
    execFile('sh', ['-c', focusPlace, 'sh', ...target]).on('error', () => {});
  });
}

export default function (pi: ExtensionAPI): void {
  pi.on('agent_end', async (_event, ctx) => {
    if (!ctx.hasUI) return;
    const place = await resolvePlace();
    const windows = await niriWindows();
    if (await inView(place, windows)) return;

    const window = await niriWindowOf(place.owner, windows);
    const name = (await placeOf(place)) ?? window?.appId;
    const session = ctx.sessionManager.getSessionName() || ctx.sessionManager.getSessionId();
    const summary = ['pi', name, session].filter(Boolean).join(' ');
    notify(summary, place, window);
  });
}
