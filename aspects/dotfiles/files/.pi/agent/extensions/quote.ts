import { execFileSync } from 'node:child_process'
import { createRequire } from 'node:module'
import { dirname, join } from 'node:path'
import type { ExtensionAPI, ExtensionContext } from '@earendil-works/pi-coding-agent'
import { getNativeClipboard } from '@earendil-works/pi-tui'

const requireLocal = createRequire(import.meta.url)

function loadSelectionHookModule(): unknown {
  const loaders = [requireLocal]
  try {
    loaders.push(
      createRequire(
        join(dirname(dirname(process.execPath)), 'lib/node_modules/selection-hook/package.json')
      )
    )
  } catch {
    // No selection-hook install beside this Node.
  }

  for (const load of loaders) {
    try {
      return load('selection-hook')
    } catch {
      // Try the next place.
    }
  }
}

export type QuoteSource = 'argument' | 'selection' | 'clipboard'
export type QuoteResult = { text: string; source: QuoteSource }

// Linux exposes no metadata that separates a live selection from one made an
// hour ago, so freshness is tracked by comparing against the last lookup.
let seenClipboard: string | undefined
let seenSelection = ''
let lastQuoted = ''

type SelectionHookInstance = {
  start(config?: {
    enableClipboard?: boolean
    selectionPassiveMode?: boolean
    debug?: boolean
  }): boolean
  stop(): boolean
  cleanup?(): void
  getCurrentSelection(): { text?: string } | null
}

type SelectionHookConstructor = new () => SelectionHookInstance

function readClipboardCommand(command: string, args: string[]): string {
  try {
    return execFileSync(command, args, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] })
  } catch {
    return ''
  }
}

async function readClipboard(): Promise<string> {
  // DISPLAY is set under XWayland, so the native helper reads the X11 selection.
  // tmux `clip` and Pi both write with wl-copy. That X11 read is empty, and an
  // empty string is still a result, so it used to hide the Wayland clipboard.
  if (process.env.WAYLAND_DISPLAY) {
    const text = readClipboardCommand('wl-paste', ['--no-newline', '--type', 'text'])
    if (text) return text
  }

  const native = getNativeClipboard()
  if (native) {
    try {
      const text = await native.getText()
      if (text) return text
    } catch {
      // Fall back to platform clipboard commands.
    }
  }

  const commands: Array<[string, string[]]> = [
    ['pbpaste', []],
    ['wl-paste', ['--no-newline', '--type', 'text']],
    ['xclip', ['-selection', 'clipboard', '-out']],
    ['xsel', ['--clipboard', '--output']],
    ['powershell.exe', ['-NoProfile', '-Command', 'Get-Clipboard -Raw']]
  ]

  for (const [command, args] of commands) {
    const text = readClipboardCommand(command, args)
    if (text) return text
  }

  return ''
}

function sleep(milliseconds: number): void {
  Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, milliseconds)
}

function readSelectionHook(): string | undefined {
  try {
    const mod = loadSelectionHookModule() as
      | SelectionHookConstructor
      | { default?: SelectionHookConstructor }
      | undefined
    const SelectionHook = typeof mod === 'function' ? mod : mod?.default
    if (!SelectionHook) return

    const hook = new SelectionHook()
    try {
      if (!hook.start({ enableClipboard: false, selectionPassiveMode: true, debug: false })) return
      sleep(30)
      const text = hook.getCurrentSelection()?.text?.trim()
      return text || undefined
    } finally {
      hook.stop()
      hook.cleanup?.()
    }
  } catch {
    return
  }
}

type LiveSelectionReader = {
  getActiveSelectionText?: () => string | undefined
}

/**
 * Fullscreen Pi keeps the drag highlight on the alt-screen and copies it
 * asynchronously. The clipboard is often still empty when the shortcut runs.
 * Reading the highlight is synchronous and does not show a dialog: done()
 * runs before the overlay is mounted.
 */
async function readLiveTuiSelection(ctx: ExtensionContext): Promise<QuoteResult | undefined> {
  if (!ctx.hasUI || ctx.mode !== 'tui') return

  try {
    const text = await ctx.ui.custom<string | undefined>((tui, _theme, _kb, done) => {
      const read = (tui as LiveSelectionReader).getActiveSelectionText?.()
      done(typeof read === 'string' ? read : undefined)
      return { render: () => [], invalidate: () => {} }
    }, { overlay: true })
    const trimmed = text?.trim()
    return trimmed ? { text: trimmed, source: 'selection' } : undefined
  } catch {
    return
  }
}

function remember(result: QuoteResult | undefined): QuoteResult | undefined {
  if (result) lastQuoted = result.text
  return result
}

/**
 * Freshness decides the source, not availability. A copy made since the last
 * lookup outranks the selection hook, because PRIMARY keeps advertising a
 * browser selection long after the highlight is gone, which would otherwise
 * shadow the text just copied from the transcript.
 */
async function readQuoteSource(ctx: ExtensionContext): Promise<QuoteResult | undefined> {
  const live = await readLiveTuiSelection(ctx)
  const clipboard = (await readClipboard()).trim()
  const selection = readSelectionHook() ?? ''
  const clipboardCopied = seenClipboard !== undefined && clipboard !== seenClipboard
  const selectionChanged = selection !== '' && selection !== seenSelection

  seenClipboard = clipboard
  seenSelection = selection

  if (live && live.text !== lastQuoted) return remember(live)

  if (clipboard && clipboardCopied && clipboard !== lastQuoted) {
    return remember({ text: clipboard, source: 'clipboard' })
  }

  if (selectionChanged && selection !== lastQuoted) {
    return remember({ text: selection, source: 'selection' })
  }
}

export function formatQuote(text: string): string {
  return text
    .replace(/\r\n/g, '\n')
    .replace(/\r/g, '\n')
    .trim()
    .split('\n')
    .map((line) => (line.length === 0 ? '>' : `> ${line}`))
    .join('\n')
}

export function appendQuote(current: string, quoted: string): string {
  const separator = current.trim().length === 0 ? '' : current.endsWith('\n') ? '\n' : '\n\n'
  return `${current}${separator}${quoted}\n\n`
}

function insertQuote(ctx: ExtensionContext, result: QuoteResult | undefined): void {
  const quoted = result ? formatQuote(result.text) : ''
  if (!result || !quoted) {
    ctx.ui.notify('No new selection or copied text', 'warning')
    return
  }

  ctx.ui.setEditorText(appendQuote(ctx.ui.getEditorText(), quoted))
}

export default function quoteExtension(pi: ExtensionAPI) {
  pi.registerCommand('quote', {
    description: 'Insert selected/copied text as email-style quote',
    async handler(args, ctx) {
      const text = args.trim()
      insertQuote(ctx, text ? { text, source: 'argument' } : await readQuoteSource(ctx))
    }
  })

  // The clipboard is primed here so a copy that predates the session cannot
  // outrank the first selection quoted after it.
  void readClipboard().then((text) => {
    seenClipboard ??= text.trim()
  })

  pi.registerShortcut('alt+q', {
    description: 'Quote current selection into editor',
    async handler(ctx) {
      if (!ctx.hasUI) return
      insertQuote(ctx, await readQuoteSource(ctx))
    }
  })
}
