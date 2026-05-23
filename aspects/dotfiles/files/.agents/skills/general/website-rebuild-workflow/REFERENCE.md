# Website Rebuild — Reference

## WEBSITE_SPEC.md Section Definitions

| Section | What goes in it |
|---|---|
| Adjacent Possible — Primary | v1 feature ideas grounded in what already exists; high value, close to current state |
| Adjacent Possible — Secondary | v2/v3 ideas; mark explicitly as "later iterations" |
| Generative Constraints | Limitations that produce something better than their absence — worth keeping deliberately |
| Closed Doors | Genuine blockers: assets to gather manually, legal requirements, structural/business gaps |
| Negative Space | Load-bearing absences — things deliberately not there that do positive work (e.g. "no hero banner", "no credentials listed") |

## Compatibility Matrix (2026-05)

| Package | Working version | Notes |
|---|---|---|
| astro | ^5.18.1 | @keystatic/astro peer dep caps at Astro 5; Astro 6 blocked |
| @keystatic/astro | ^5.0.6 | |
| @keystatic/core | ^0.5.50 | |
| @astrojs/vercel | ^8.2.11 | v10+ requires Astro 6 |
| @astrojs/react | ^5.0.4 | Required for Keystatic admin UI |
| react + react-dom | ^19.x | |
| @tailwindcss/vite | ^4.1.18 | ⚠ NOT 4.2.x — see mistakes below |
| tailwindcss | ^4.1.18 | Match vite plugin version |
| daisyui | ^5.5.19 | |

## Critical Mistakes to Avoid

**Building before Q&A is complete**
Always finish alignment before creating any files. "NEVER DO PREMATURE."

**Source platform dependencies in spec**
No Squarespace CDN URLs, export files, or template names. Spec must be independent.

**`output: 'hybrid'` in Astro 5**
Removed. Use `output: 'static'` — same behavior, pages prerender by default, opt-out per route with `export const prerender = false`.

**Missing React renderer for Keystatic**
Keystatic admin UI is React-based. `@astrojs/react` is required even if the portfolio uses zero React. Without it: `NoMatchingRenderer` error on `/keystatic`.

**`@tailwindcss/vite@4.2.x` breaks dev**
4.2.x enables Rolldown experimentally. Rolldown requires `moduleType` field in plugins; Vite's built-in `vite-react-refresh-wrapper` doesn't include it → `Missing field moduleType` error → dev server 500s. Pin to `4.1.x`.

**Keystatic format not set**
Without `format: { frontmatter: 'yaml' }`, Keystatic defaults to `.yaml` files and ignores `.md` files. Always set explicitly.

**Keystatic `contentField` vs Astro schema conflict**
`format: { contentField: 'fieldName' }` writes that field to the markdown body (not frontmatter). Astro's Zod schema only reads frontmatter. Either: remove `contentField` (all data in frontmatter) or remove the field from Zod schema and read via `entry.body`.

**Astro 5 content collection entry IDs include `.md`**
`entry.id` = `'gurkerl.md'` (with extension). Strip for route params:
```js
params: { slug: p.id.replace(/\.md$/, '') }
```
`getEntry('collection', 'gurkerl')` — lookup uses slug WITHOUT extension.

**README.md in content collections or pages dirs**
Astro treats every `.md` in those dirs as a real entry/page. Rename to `_README.md` (underscore prefix = ignored by Astro).

**`sharp` unavailable**
Often can't compile from source on Linux. If not using Astro's `<Image>` component (plain `<img>` tags only), use:
```js
import { passthroughImageService } from 'astro/config';
image: { service: passthroughImageService() }
```

**OAuth redirect URI mismatch**
Keystatic constructs redirect URI from the request host — breaks on Vercel preview URLs. Fix:
```js
// astro.config.mjs
site: 'https://your-domain.vercel.app'
```

## Vercel + Keystatic Deployment

### Prerequisites
1. Push repo to GitHub
2. Create **GitHub OAuth App** (Settings → Developer settings → **OAuth Apps** — NOT GitHub Apps):
   - Homepage URL: `https://your-domain.vercel.app`
   - Callback URL: `https://your-domain.vercel.app/api/keystatic/github/oauth/callback`
   - Exact match required — no trailing slash, no `www.`
3. Generate secret: `openssl rand -hex 32`

### Vercel Environment Variables
| Key | Value |
|---|---|
| `KEYSTATIC_GITHUB_CLIENT_ID` | from OAuth App |
| `KEYSTATIC_GITHUB_CLIENT_SECRET` | from OAuth App |
| `KEYSTATIC_SECRET` | 32-char random string |

### keystatic.config.ts (production)
```ts
storage: {
  kind: 'github',
  repo: { owner: 'github-username', name: 'repo-name' },
},
```

### astro.config.mjs (production)
```js
site: 'https://your-domain.vercel.app',
output: 'static',
adapter: vercel(),
integrations: [react(), keystatic()],
image: { service: passthroughImageService() },
```

### Verify
`https://your-domain.vercel.app/keystatic` → GitHub OAuth login → admin UI with all collections visible.

## DaisyUI Token Override Pattern

To make DaisyUI not look like DaisyUI — override in global.css:
```css
@plugin "daisyui" {
  themes: false;
}

[data-theme="custom"] {
  --radius-selector: 0;
  --radius-field: 0;
  --radius-box: 0;
  --depth: 0;
  --noise: 0;
  /* white/near-black palette */
  --color-base-100: oklch(100% 0 0);
  --color-base-content: oklch(10% 0 0);
}
```
Apply with `data-theme="custom"` on `<html>`.
