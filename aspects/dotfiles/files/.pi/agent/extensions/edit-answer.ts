/**
 * Edit Answer Extension
 *
 * Opens an assistant answer in $EDITOR and installs the edited result into the
 * composer.
 *
 * Based on: https://github.com/wincent/wincent-agent-plugins/blob/f918925c155dd4079622cbdc0474eaa685d00fcd/pi/extensions/edit-answer.ts
 */

import type {
  ExtensionAPI,
  ExtensionContext,
  SessionEntry,
} from '@earendil-works/pi-coding-agent';
import {getShellConfig} from '@earendil-works/pi-coding-agent';
import {spawn} from 'node:child_process';
import {mkdtempSync, readFileSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';

import {queueDialog} from './lib/dialog.js';

const MAX_RECENT = 20;
const PREVIEW_CHARS = 80;

type CtxWithIdle = ExtensionContext & {waitForIdle?: () => Promise<void>};

interface AssistantAnswer {
  entry: SessionEntry & {type: 'message'};
  text: string;
}

function extractAssistantText(entry: SessionEntry): string | undefined {
  if (entry.type !== 'message') {
    return;
  }
  const message = entry.message;
  if (message.role !== 'assistant' || !Array.isArray(message.content)) {
    return;
  }

  const text = message.content
    .filter(
      (block: any): block is {type: 'text'; text: string} =>
        block?.type === 'text' && typeof block.text === 'string',
    )
    .map((block) => block.text)
    .join('\n\n')
    .trim();

  return text || undefined;
}

/**
 * Walk the current branch newest-first, returning up to MAX_RECENT
 * assistant messages that have any user-visible text content.
 */
function recentAssistantAnswers(ctx: ExtensionContext): AssistantAnswer[] {
  const branch = ctx.sessionManager.getBranch();
  const out: AssistantAnswer[] = [];

  for (let i = branch.length - 1; i >= 0 && out.length < MAX_RECENT; i--) {
    const entry = branch[i];
    const text = extractAssistantText(entry);
    if (text) {
      out.push({entry: entry as AssistantAnswer['entry'], text});
    }
  }

  return out;
}

function relativeTime(iso: string): string {
  const then = new Date(iso).getTime();
  if (!Number.isFinite(then)) {
    return '?';
  }

  const seconds = Math.max(0, Math.round((Date.now() - then) / 1000));
  if (seconds < 5) {
    return 'just now';
  }
  if (seconds < 60) {
    return `${seconds}s ago`;
  }

  const minutes = Math.round(seconds / 60);
  if (minutes < 60) {
    return `${minutes}m ago`;
  }

  const hours = Math.round(minutes / 60);
  if (hours < 24) {
    return `${hours}h ago`;
  }

  const days = Math.round(hours / 24);
  return `${days}d ago`;
}

function preview(text: string, max = PREVIEW_CHARS): string {
  const collapsed = text.replace(/\s+/g, ' ').trim();
  return collapsed.length <= max
    ? collapsed
    : `${collapsed.slice(0, max - 1)}…`;
}

/** Open a trusted $EDITOR command while temporarily releasing Pi's terminal. */
async function openInEditor(
  initial: string,
  ctx: ExtensionContext,
): Promise<void> {
  // Retain the slot until the edited draft is installed: another custom UI
  // snapshots the current editor text and restores it when that UI closes.
  await queueDialog(ctx.ui, async () => {
    let dir: string | undefined;
    const configuredEditor = process.env.EDITOR;
    const editor = configuredEditor?.trim() ? configuredEditor : 'vim';
    try {
      const {shell, args, commandTransport} = getShellConfig();
      if (commandTransport === 'stdin') {
        throw new Error(
          'The configured shell cannot share stdin with an interactive editor.',
        );
      }
      dir = mkdtempSync(join(tmpdir(), 'pi-edit-answer-'));
      const file = join(dir, 'answer.md');
      const seed = initial.endsWith('\n') ? initial : `${initial}\n`;
      writeFileSync(file, seed, 'utf8');

      const status = await ctx.ui.custom<number | null>(
        async (tui, _theme, _kb, done) => {
          tui.stop();
          let status: number | null;
          try {
            // EDITOR is shell syntax, but the path is data: never interpolate it.
            // Async spawn also avoids competing console reads on Windows.
            status = await new Promise<number | null>((resolve, reject) => {
              const child = spawn(
                shell,
                [...args, `${editor} "$1"`, 'pi-edit-answer', file],
                {stdio: 'inherit', cwd: ctx.cwd},
              );
              child.once('error', reject);
              child.once('close', resolve);
            });
          } finally {
            tui.start();
            tui.requestRender(true);
          }
          done(status);
          return {render: () => [], invalidate: () => {}};
        },
      );
      if (status !== 0) {
        throw new Error(
          status === null
            ? 'Editor terminated by a signal.'
            : `Editor exited with status ${status}.`,
        );
      }
      ctx.ui.setEditorText(readFileSync(file, 'utf8'));
    } catch (error) {
      ctx.ui.notify(
        `Failed to edit with ${editor}: ${
          error instanceof Error ? error.message : String(error)
        }`,
        'error',
      );
      return;
    } finally {
      if (dir) {
        try {
          rmSync(dir, {recursive: true, force: true});
        } catch {
          // Cleanup is best effort; do not discard a successful edit.
        }
      }
    }
  });
}

async function editLatest(ctx: CtxWithIdle) {
  await ctx.waitForIdle?.();

  const [latest] = recentAssistantAnswers(ctx);
  if (!latest) {
    ctx.ui.notify('No assistant answer found.', 'warning');
    return;
  }

  await openInEditor(latest.text, ctx);
}

async function editPicked(ctx: CtxWithIdle) {
  await ctx.waitForIdle?.();

  const candidates = recentAssistantAnswers(ctx);
  if (candidates.length === 0) {
    ctx.ui.notify('No assistant answers to pick from.', 'warning');
    return;
  }

  const byLabel = new Map<string, AssistantAnswer>();
  const labels = candidates.map((candidate, idx) => {
    const ordinal = String(idx + 1).padStart(2, ' ');
    const label = `${ordinal}. ${relativeTime(candidate.entry.timestamp)} - ${
      preview(candidate.text)
    }`;
    // Disambiguate the rare case of identical labels (same time, same preview).
    const unique = byLabel.has(label)
      ? `${label} [${candidate.entry.id}]`
      : label;
    byLabel.set(unique, candidate);
    return unique;
  });

  const choice = await queueDialog(
    ctx.ui,
    () => ctx.ui.select('Pick an answer to edit:', labels),
  );
  if (!choice) {
    return;
  }

  const picked = byLabel.get(choice);
  if (!picked) {
    return;
  }

  await openInEditor(picked.text, ctx);
}

function isPickArg(args: string): boolean {
  const trimmed = args.trim();
  return trimmed === 'pick' || trimmed === '--pick';
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand('edit-answer', {
    description:
      "Open an assistant answer in $EDITOR (append 'pick' to choose from recent answers)",
    getArgumentCompletions: (prefix: string) => {
      const items = [{
        value: 'pick',
        label: 'pick',
        description: 'Choose from recent assistant answers',
      }];
      const filtered = items.filter((item) => item.value.startsWith(prefix));
      return filtered.length > 0 ? filtered : null;
    },
    handler: async (args, ctx) => {
      if (ctx.mode !== 'tui') {
        if (ctx.hasUI) {
          ctx.ui.notify(
            'Editing an answer requires the interactive TUI.',
            'warning',
          );
        }
        return;
      }
      if (isPickArg(args)) {
        await editPicked(ctx);
      } else {
        await editLatest(ctx);
      }
    },
  });

  // pi.registerShortcut("ctrl+v", {
  //   description: "Open latest assistant answer in $EDITOR",
  //   handler: async (ctx) => editLatest(ctx as CtxWithIdle),
  // });
}
