---
description: Check for pi updates, review changelog and local resources, then offer a safe upgrade.
argument-hint: "[instructions]"
---

> Source: https://github.com/wincent/wincent/blob/7483d5d76c1eefd1a4a63d3ed2ad57c88d6c7ac3/aspects/dotfiles/files/.pi/agent/prompts/pi-update.md
> Imported from commit: `7483d5d76c1eefd1a4a63d3ed2ad57c88d6c7ac3`
> License: Public domain, Copyright waived by the author

# Update pi

You are helping the user understand what upgrading pi (`@earendil-works/pi-coding-agent`) will entail: what version they are on, what version is available, what breaking changes are in between, and whether any of their locally installed extensions, skills, or prompt templates will need adjustment to remain compatible. Then offer to run the upgrade for them and, if they accept, run it.

User request: $ARGUMENTS

## Step 1: Determine the current installed version

Try these in order until one yields a version string:

1. `pi --version`
2. `npm list -g --depth=0 @earendil-works/pi-coding-agent 2>/dev/null`
3. Read `package.json` under `$(npm root -g)/@earendil-works/pi-coding-agent/`.

Record this as `CURRENT`.

## Step 2: Determine the latest released version and detect any install cooldown

Run:

```bash
npm view @earendil-works/pi-coding-agent version
```

Record this as `LATEST`, the absolute latest published version.

Determine the active npm release cooldown without reading any `.npmrc` file:

```bash
npm config get min-release-age
```

Record the result as `COOLDOWN_DAYS`. If npm returns a non-negative number, use that many days. If it returns `null`, an empty value, or `undefined`, treat the cooldown as disabled and set `COOLDOWN_DAYS = 0`. If the command fails or returns a non-numeric value, report that the cooldown could not be determined and stop before recommending an unpinned upgrade. Do **not** read `~/.npmrc`: it may contain authentication tokens that must not leak into session context.

Now compute the version that a plain `npm install -g @earendil-works/pi-coding-agent` would actually install today. Fetch publish timestamps:

```bash
npm view @earendil-works/pi-coding-agent time --json
```

This returns a JSON object mapping version strings to ISO publish times, plus bookkeeping keys `created` and `modified` that you should ignore. Let `CUTOFF = now - COOLDOWN_DAYS`. Set `COOLDOWN_LATEST` to the highest semver version whose publish time is less than or equal to `CUTOFF`. Stable versions should win over pre-releases unless the user explicitly asked for pre-releases.

Classify the situation using `CURRENT`, `COOLDOWN_LATEST`, and `LATEST`:

1. **Up to date**: `CURRENT == LATEST`. Tell the user and stop unless they explicitly want to see recent changes anyway.
2. **No cooldown, or cooldown already cleared**: `COOLDOWN_LATEST == LATEST`. Single-block report using Step 6 Scenario A.
3. **Cooldown blocks part of the upgrade**: `CURRENT <= COOLDOWN_LATEST < LATEST`. Two-block report using Step 6 Scenario B.
4. **Silent downgrade hazard**: `COOLDOWN_LATEST < CURRENT`. A plain `npm install -g @earendil-works/pi-coding-agent` will **downgrade** the user from `CURRENT` to `COOLDOWN_LATEST`, because npm resolves to the newest version the cooldown allows without comparing against what is already installed. Two-block report with a prominent warning in Block 1 using Step 6 Scenario C. This is a real footgun: the installed package's runtime dependencies can shrink on downgrade, which can break existing extensions that relied on newer transitive deps, for example an extension importing `typebox` 1.x when the downgraded pi only ships `@sinclair/typebox` 0.34.x.

## Step 3: Fetch the changelog

Fetch the raw changelog via `curl`:

```bash
curl -sSL https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/CHANGELOG.md
```

The human-readable URL is <https://github.com/earendil-works/pi/blob/main/packages/coding-agent/CHANGELOG.md>.

Extract the entries for every version strictly greater than `CURRENT` and less than or equal to `LATEST`. Pay particular attention to:

- Sections or bullets labeled **Breaking**, **BREAKING CHANGE**, **Migration**, **Removed**, or **Deprecated**.
- Changes to extension APIs, event names, `ExtensionContext` or `pi.*` method signatures, tool registration, skill loading, prompt template loading or interpolation, or session format.
- Changes to CLI flags, config file locations, or default behaviors.

Summarize these for the user, grouped by version, with the breaking ones called out first.

## Step 4: Inventory the user's extensions, skills, and prompt templates

The goal of this step is to discover every extension, skill, and prompt template that pi will load for this user, so that the impact analysis in Step 5 covers all of them. Missing a configured root and then declaring all resources compatible based on a partial sample is a serious failure mode of this prompt; treat completeness as a hard requirement.

### Step 4a: Always read `settings.json` first

Before enumerating anything, read `~/.pi/agent/settings.json` if it exists. Three top-level keys matter:

- `"extensions"`: an array of directories pi loads extensions from. Each entry is a directory; pi loads every `*.ts` file directly inside it, plus any subdirectory containing an `index.ts`, such as `subagent/` packages. Tilde-expand `~` against `$HOME`.
- `"skills"`: an array of directories pi loads skills from. Each entry is a directory; pi loads direct `.md` files in it and `*/SKILL.md` from immediate subdirectories. Tilde-expand `~` against `$HOME`.
- `"prompts"`: an array of files or directories pi loads prompt templates from. For directory entries, pi discovers `*.md` files directly inside the directory and does not recurse. Tilde-expand `~` against `$HOME`.

If `settings.json` defines any of these arrays, treat the defined array as authoritative for that resource type and use it in place of any hard-coded defaults below. Do not silently fall back to defaults if a key is present but lists different paths; the user has explicitly opted into a different set of roots.

If `settings.json` is missing or does not set one of the keys, fall back to pi's built-in defaults for the missing key:

- Default extension roots: `~/.pi/agent/extensions`, and `.pi/extensions` in the current working directory and ancestors up to the repo root.
- Default skill roots: `~/.pi/agent/skills`, `~/.agents/skills`, and `.pi/skills` or `.agents/skills` in cwd and ancestors.
- Default prompt roots: `~/.pi/agent/prompts`, and `.pi/prompts` in the current working directory.

List the roots you ended up with explicitly in your scratch reasoning so it is obvious which extensions, skills, and prompts are in scope.

### Step 4b: Enumerate every item under every configured root

For each extension root, list:

- All `*.ts` files directly inside the root.
- All immediate subdirectories that contain an `index.ts`; these are packaged extensions, for example `subagent/index.ts`.

For each skill root, list:

- All `*.md` files directly inside the root.
- All immediate subdirectories containing a `SKILL.md`.

For each prompt entry, list:

- If the entry is a file, that file.
- If the entry is a directory, all `*.md` files directly inside that directory.

Resolve symlinks where helpful, but if two roots point at the same physical file or directory, analyze the underlying file only once and note that both names map to it.

### Step 4c: Record name and purpose for each discovered item

For every extension, skill, and prompt template you found, read the file header, frontmatter, README entry, or source-level registration call and briefly note its name and purpose. This list must be the input to Step 5: any item present here must appear in the per-item verdict table you produce in Step 5 or Step 6. If you skip an item because you judge it irrelevant, say so explicitly rather than dropping it silently.

### Step 4d: Sanity-check coverage before continuing

Before moving on, ask yourself: have I enumerated every entry in `settings.json`'s `extensions`, `skills`, and `prompts` arrays, plus defaults for any missing arrays? If the answer is anything other than yes, go back and finish. Do not start Step 5 until the inventory is complete.

## Step 5: Cross-reference against breaking changes

For every breaking change identified in Step 3, check each extension, skill, and prompt template discovered in Step 4 for usage of the affected API, flag, or convention. The search must span every configured root, not just default `~/.pi/agent/...` paths. Concretely:

- For API renames or removals: use `rg` for the old symbol across all configured extension roots simultaneously.
- For event name changes: search for the old event name across all extension roots.
- For skill, prompt, config, or frontmatter changes: inspect the relevant files directly.
- For prompt interpolation changes: inspect every prompt template for affected variables such as positional arguments, all-arguments placeholders, and argument slice placeholders.

Produce a per-item verdict, with one row per item enumerated in Step 4. Do not omit items just because they appear obviously fine; an explicit Compatible verdict tells the user you actually looked.

- **Compatible**: no action needed.
- **Needs update**: describe what must change and, where possible, propose the specific edit with file and diff-style snippet.
- **Uncertain**: explain what you could not verify and what the user should double-check manually.

When presenting the table in Step 6, organize rows by source root so the user can see at a glance that every root was covered.

## Step 6: Present findings and offer to run the upgrade

Choose one of the following scenarios based on Step 2's classification, present the findings, and end with an explicit prompt asking the user which of the available actions to take. Always include a **don't update** option. Do not start any install until the user has chosen.

The options offered depend on the scenario:

- **Scenario A**: two options: cooldown-respecting update with the plain command, or skip.
- **Scenarios B and C**: three options: cooldown-respecting update, cooldown-override update to `LATEST`, or skip. In Scenario C, mark the cooldown-respecting option as a **downgrade** and recommend against it; if `COOLDOWN_LATEST < CURRENT`, prefer a no-op pin to `CURRENT` instead of a downgrade.

When the user chooses to update, proceed to Step 7. When they decline, stop after acknowledging.

### Scenario A: no cooldown, single block

Structure the report as:

1. **Version summary**: `CURRENT` to `LATEST`, including how many versions that spans.
2. **Breaking changes**: bullet list, most impactful first.
3. **Other notable changes**: features, fixes, deprecations.
4. **Impact on your extensions, skills, and prompt templates**: the per-item verdicts from Step 5.
5. **Recommended action**: if nothing needs updating, offer the upgrade command. If updates are needed, list them and ask the user whether to apply the fixes now before running the upgrade, or to proceed without them.

The upgrade command is:

```bash
npm install -g @earendil-works/pi-coding-agent
```

### Scenarios B and C: cooldown active, two blocks

When `COOLDOWN_DAYS > 0`, a plain `npm install -g @earendil-works/pi-coding-agent` will resolve only to versions at least `COOLDOWN_DAYS` old. Present the findings as two blocks so the user can make an informed choice between respecting their cooldown and overriding it for this install.

Open the report with a short **Cooldown notice** stating the configured `min-release-age` value and naming both targets, `COOLDOWN_LATEST` and `LATEST`, with their publish dates. Then:

**Block 1: respect the cooldown, `CURRENT` to `COOLDOWN_LATEST`**

1. Version summary for that span.
2. Breaking changes in the span, or none.
3. Other notable changes in the span.
4. Impact on extensions, skills, and prompt templates restricted to changes in the span.
5. Command: if `COOLDOWN_LATEST > CURRENT`, `npm install -g @earendil-works/pi-coding-agent`; if `COOLDOWN_LATEST == CURRENT`, say this is a no-op under the current cooldown and omit the command; if `COOLDOWN_LATEST < CURRENT`, lead with a prominent warning that running the plain command will downgrade the user from `CURRENT` to `COOLDOWN_LATEST`, may break already-working extensions whose transitive deps came from the newer pi, and recommend against running it. Either suggest pinning with `npm install -g @earendil-works/pi-coding-agent@<CURRENT>` to stay put, or skipping Block 1 entirely and going straight to Block 2.

**Block 2: override the cooldown, `CURRENT` to `LATEST`**

1. Version summary for that span.
2. Breaking changes in the span, or none.
3. Other notable changes in the span.
4. Impact on extensions, skills, and prompt templates across the full span. Where a change is already covered in Block 1, note that; focus the block on the additional changes only Block 2 brings in.
5. Command:

```bash
npm install -g @earendil-works/pi-coding-agent@<LATEST> --min-release-age=0
```

Include the explicit `@<LATEST>` pin so the resolver cannot choose anything older, and use `--min-release-age=0` as a one-shot override that leaves the user's global cooldown policy intact. `NPM_CONFIG_MIN_RELEASE_AGE=0 npm install -g @earendil-works/pi-coding-agent@latest` is an equivalent alternative and fine to mention.

## Step 7: Run the chosen upgrade command

Only run this step once the user has explicitly chosen one of the update options offered in Step 6. Echo back which option you are about to execute before running anything, so there is no ambiguity.

Use the command corresponding to the user's choice:

- Cooldown-respecting for Scenarios A and B: `npm install -g @earendil-works/pi-coding-agent`
- Cooldown-override for Scenarios B and C: `npm install -g @earendil-works/pi-coding-agent@<LATEST> --min-release-age=0`, with `<LATEST>` replaced by the literal version string from Step 2.

Run the command via `bash`, capturing both stdout and stderr, and surface the result to the user. If the install fails with a non-zero exit or no `pi` binary on the resulting PATH, report the failure. If the install succeeds, report the new version to the user.

After a successful upgrade, remind the user to run the `bin/install-types` helper script in each repository where they keep pi extensions, so the bundled pi extension API type definitions are regenerated to match the newly installed version. At the time of writing, those repositories are:

## Notes

- Run the install command in Step 7 only after the user has explicitly chosen one of the update options offered in Step 6. Never auto-run an install just because the user invoked this prompt.
- If the changelog cannot be fetched because of offline mode or rate limiting, say so and fall back to `npm view @earendil-works/pi-coding-agent` for whatever release notes are embedded in the package metadata.
- Pre-release or beta versions such as `-next` or `-rc` should be mentioned but not recommended unless the user asked for them explicitly.
- If `CURRENT` is many versions behind, warn the user that the impact assessment is best-effort and that a staged upgrade or careful manual review may be wiser than a single jump.
- `min-release-age` in npm 11+ makes `npm install` resolve to the newest version older than the cooldown, and npm does not protect against downgrades: if every version newer than `CURRENT` is inside the cooldown window, a plain install will silently move the user to a lower version. Always check Step 2's classification before recommending the plain command.
- The cooldown is read from npm's effective configuration with `npm config get min-release-age`; do not infer it from a hard-coded value or read `.npmrc` files.
- When a breaking change landed inside the cooldown window, extensions authored against the newer API may work on `LATEST` but not on `COOLDOWN_LATEST`, or vice versa on downgrade. Call this out in the per-block impact analysis.
