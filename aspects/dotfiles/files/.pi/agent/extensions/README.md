# Pi extensions

A small collection of [Pi](https://github.com/earendil-works/pi/tree/main/packages/coding-agent) extensions that are general enough to be portable across machines and users. Each extension is a self-contained TypeScript module with no dependencies outside of `@earendil-works/pi-coding-agent` and the Node standard library.

## Type-checking

Run `npm run typecheck` from this directory. It runs `tsc --noEmit`, and runs `bin/install-types` first when the type stubs are missing. Run `bin/install-types` again after a Pi upgrade.

Do not run `npm install` here. These extensions use the dependencies of the installed Pi, and this directory only needs their type declarations.

## Extensions

### `notify.ts`

When a turn ends and pi is waiting for input, this extension runs `notify --title pi --message "Ready for input"`. It does this only when pi has a UI. If `notify` is not on `PATH`, the spawn error is ignored.

### `sandbox.ts`

Shows `Sandbox ✔` in the TUI footer when `IN_SANDBOX` is non-empty. This is a launcher hint, not verification of sandbox enforcement.

### `web-search.ts`

Registers a `web_search` tool that queries the [Kagi Search API](https://help.kagi.com/kagi/api/search.html). It needs `KAGI_API_TOKEN` in the environment. Each query costs $12 per 1,000 searches. The tool takes a query and returns titles, URLs, and snippets.
