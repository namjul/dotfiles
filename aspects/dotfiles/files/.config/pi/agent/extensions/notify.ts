/**
 * Notify Extension
 *
 * Sends a desktop notification when pi finishes a turn and is waiting for input.
 *
 * Based on: https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/examples/extensions/notify.ts https://github.com/wincent/wincent/blob/e104d2efaf1bbf061d91cd2549d0a9efc390aa68/aspects/dotfiles/files/.pi/agent/extensions/notify.ts
 */

import type {ExtensionAPI} from '@mariozechner/pi-coding-agent';
import {execFile} from 'node:child_process';

function notify(title: string, body: string): void {
  const child = execFile('notify-send', [title, body]);
  // Swallow spawn errors (eg. `notify-send` not on $PATH).
  child.on('error', () => {});
}

export default function (pi: ExtensionAPI) {
  pi.on('turn_end', async (_event, ctx) => {
    if (!ctx.hasUI) return;
    notify('pi', 'Ready for input');
  });
}
