---
name: website-rebuild-workflow
description: End-to-end workflow for rebuilding a client or friend's existing website — from crawling the live site through spec writing, Q&A alignment, PRD, folder structure, and full build with CMS and Vercel deployment. Use when user wants to rebuild/redesign a website from an existing URL, says "build me a website" with a reference site, or needs a portfolio/branding site built from scratch.
---

# Website Rebuild Workflow

## Process (in order — never skip or reorder)

### Phase 1 — Crawl & Understand
Fetch the live site. Click through all subpages. Extract:
- Site structure, navigation, URL map
- All content (copy, projects, services, clients)
- Visual identity (colors, typography, layout, logo, mascot)
- Brand voice (register, copy patterns, what to avoid)
- Contact / commission flow

### Phase 2 — Write `WEBSITE_SPEC.md`
Sections: Site Identity · Design System · Brand Voice & Visual Identity · Site Structure · Pages · Content Detail Template · Full Content Inventory · Category Reference · Asset Notes · External Links · Localization · Adjacent Possible (Primary / Secondary / Generative Constraints) · Closed Doors · Negative Space

Mark unknowns `⚠ UNKNOWN`. Never include source platform dependencies (CDN URLs, export files, template names).

See [REFERENCE.md](REFERENCE.md) for section definitions.

### Phase 3 — Q&A Alignment
**⛔ NEVER BUILD BEFORE THIS IS COMPLETE.**

Ask 3 targeted questions covering: font · grid type · header behavior · contact method (form vs email) · CMS needs · shop/e-commerce · deployment target.

Resolve all `⚠ UNKNOWN` markers after answers.

### Phase 4 — Folder Structure + Routing Files
Create folder skeleton. Each folder gets a `README.md` explaining purpose and rules. Create `AGENTS.md` at root with: stack summary · folder map · task routing table · non-negotiable design rules · brand asset locations.

Do NOT create implementation files yet.

### Phase 5 — PRD
Build PRD using UI/UX design skill set. Include: goals/non-goals · tech stack with rationale · v1 features (from Adjacent Possible §Primary) · resolved decisions · constraints.

### Phase 6 — Tech Stack Decision
- Client edits content? → Keystatic (git-based, free) or Sanity (hosted)
- Hosting budget? → Vercel free tier works with Astro + Keystatic
- Portfolio = static; Keystatic admin needs server routes

Standard working stack: Astro 5.x + @astrojs/react + Keystatic + @astrojs/vercel + Tailwind 4.1.x + DaisyUI 5.x

See [REFERENCE.md](REFERENCE.md) for compatibility matrix.

### Phase 7 — Build Sequence
1. Config files (astro.config.mjs, tsconfig.json, package.json, keystatic.config.ts)
2. Content schema (src/content/config.ts with Zod)
3. Styles (global.css — @font-face, theme tokens, utility classes)
4. Layouts (Base shell, content detail layout)
5. Components (Header, Footer, Grid, Card, Filter, Gallery, PrevNext, ProcessSection)
6. Pages (index, profile, legal, 404, dynamic [slug])
7. Content files (one .md per entry, all data in frontmatter)

See [REFERENCE.md](REFERENCE.md) for critical mistakes, Astro 5 gotchas, and Vercel deployment steps.
