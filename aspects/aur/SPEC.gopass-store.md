# Step 7 — gopass password store (GitHub)

**Parent plan:** [PLAN.sway.md](PLAN.sway.md) step 7  
**Status:** draft (agent-facilitated round 1 — needs human review before implementation)

Not Sway-specific — applies to every fresh Arch install where dotfiles secrets are needed.

## Story

On a new Arch machine, import the password store from its GitHub remote so `gopass` can decrypt entries. This unblocks fnox (`GITHUB_TOKEN`, API keys), passmenu (step 13), and any tool that reads secrets from pass/gopass.

## Context

| Piece | Location / today |
|---|---|
| Package | `gopass`, `gnupg` in `aspects/aur/packages` |
| GitHub git auth | `aspects/ssh/key.yml` (sops/age) → `mise r ssh:keys` installs `~/.ssh/id_rsa` |
| SSH config | `aspects/ssh/files/.ssh/config.encrypted` → `mise r ssh:config` |
| Age key (decrypt ssh + sops) | `~/.config/age/key.txt` — same bootstrap as `aspects:setup` / `arch:test-container` |
| Store path | `PASSWORD_STORE_DIR="$DROPBOX_DIR/.password-store"` in `aspects/dotfiles/files/.config/fish/conf.d/10-env.fish` |
| fnox | `aspects/dotfiles/files/.config/fnox/config.toml` — provider `password-store`, prefix `fnox/` |
| Alias | `pass` → `gopass` in fish |
| passmenu | `bin/passmenu` — needs populated store (step 13) |
| Test container | `.mise.toml` `arch:test-container` bind-mounts `fnox.local.toml` + age key — **not** the gopass store today |

On the main machine the store may arrive via Dropbox sync. On a **fresh VM or new hardware** there is no Dropbox copy yet — clone from GitHub instead.

**Two different keys:**

| Key | Purpose | In dotfiles? |
|---|---|---|
| **SSH** (`~/.ssh/id_rsa`) | `git clone` / `gopass clone` from private GitHub repo | Yes — `aspects/ssh/key.yml` |
| **GPG** | Decrypt entries inside the password store | No — must exist on machine separately |

Do not conflate them. SSH gets the repo; GPG reads the secrets inside it.

## Rules

### R0 — SSH key installed before clone

GitHub access uses the ssh aspect, not a one-off manual key copy.

**Examples:**
- Age identity at `~/.config/age/key.txt` (decrypts `key.yml`).
- `mise r ssh:keys` (or `mise r ssh`) writes `~/.ssh/id_rsa` + `.pub` from `aspects/ssh/key.yml`.
- `ssh -T git@github.com` succeeds (or clone works) before `gopass clone`.

### R1 — GPG key available for decryption

The machine must have the private **GPG** key that encrypts pass entries. SSH key in dotfiles does not replace this.

**Examples:**
- `gpg --list-secret-keys` shows the key id used by the store.
- `gopass show` on a known entry decrypts without "unknown key" errors.

**Questions:**
- GPG key transfer method — see parked Q2.

### R2 — Store cloned to `PASSWORD_STORE_DIR`

Import the git-backed store from GitHub into the path dotfiles expect. Use SSH remote URL (`git@github.com:…`) after R0.

**Examples:**
- `mise r ssh:keys` then `gopass clone git@github.com:USER/STORE.git "$PASSWORD_STORE_DIR"`.
- `gopass ls` lists expected top-level mounts/paths.
- Store is a git repo: `git -C "$PASSWORD_STORE_DIR" remote -v` shows GitHub origin.

**Questions:**
- Exact GitHub URL — see parked Q1.

### R3 — fnox can read at least one secret

Prove the store works for the main consumer (fnox → shell env).

**Examples:**
- `fnox exec -- env | rg '^GITHUB_TOKEN='` prints a value (do not log/commit the value).
- Invalid/expired token is a separate problem; this step proves **decrypt + read** works.
- `mise r //aspects/aur:packages` no longer fails on usage install due to missing/broken token env (if token was the issue).

### R4 — VM vs real machine

| Environment | Expectation |
|---|---|
| **Real hardware / daily driver** | Full store import required; step not done until R1–R3 pass |
| **Ephemeral Arch VM** | Either bind-mount store from host (like age key in `arch:test-container`) **or** import a minimal test store **or** document as manual skip with reduced test scope for steps that need secrets |

**Examples:**
- VM used only for sway/wofi UI tests: may skip R3 if secrets not needed for that session.
- VM used for `mise r aur:packages`: needs R3 or `env -u GITHUB_TOKEN`.

### R5 — No secrets committed to dotfiles

Repo URL may be documented; GPG key, passwords, and store contents stay out of git.

**Examples:**
- Spec/plan may reference `github.com/<user>/<repo>` once Q1 is resolved.
- No `.gpg` key files, no `password-store/` tree, no tokens in committed scripts.

### R6 — Step complete only after proof

**Examples:**
- `gopass ls` succeeds.
- `gopass show <known-entry>` decrypts (pick a non-sensitive path for VM logs if needed).
- fnox read test (R3) on real machine.

## Acceptance criteria

1. Documented procedure (mise task or `aspects/aur/` script) for store import — or clear manual steps in this spec until automated.
2. Q1 (GitHub URL) and Q2 (GPG key transfer) resolved.
3. Real machine: R1–R3 pass.
4. PLAN.sway.md step 7 row marked done with commit reference after proof.
5. Step 13 (passmenu) and fnox consumers declare step 7 as prerequisite.

## Out of scope (step 7)

- Dropbox install/sync (optional alternate path to same directory on main machine).
- Migrating from pass to gopass format changes.
- Rotating or generating new GPG keys.
- Committing new secrets into the store from the VM.

## Parked questions

| ID | Question | Recommendation | Owner | Review by |
|---|---|---|---|---|
| Q1 | GitHub remote URL for the store? | SSH form `git@github.com:USER/STORE.git` — matches ssh aspect | user | before implementation |
| Q2 | How is the **GPG** private key transferred? | USB / backup / `gpg --import` — **not** covered by `key.yml` (that is SSH) | user | before implementation |
| Q3 | VM strategy: bind-mount host store vs clone vs skip? | Bind-mount host store **or** age key + `mise r ssh:keys` + clone in VM | — | before VM work |
| Q4 | `PASSWORD_STORE_DIR` under Dropbox when Dropbox absent? | `mkdir -p ~/Dropbox` then clone, **or** override `DROPBOX_DIR` in VM — match whichever the main machine uses | — | during implementation |

## Candidate terms

| Term | Gloss |
|---|---|
| **password store** | git-backed encrypted tree; pass/gopass compatible |
| **fnox prefix** | Secrets under `fnox/` in the store map to fnox config |
| **Bootstrap gap** | Packages install gopass binary but not the encrypted git content |

## Implementation hints (non-normative)

Typical first-time import:

```bash
# 1. age key (same as ssh/sops bootstrap)
test -f ~/.config/age/key.txt

# 2. GitHub SSH access from dotfiles
mise r ssh:keys

# 3. clone store (after Q1 URL confirmed)
mkdir -p "$(dirname "$PASSWORD_STORE_DIR")"
gopass clone git@github.com:USER/STORE.git "$PASSWORD_STORE_DIR"

# 4. decrypt proof (needs GPG key from Q2)
gopass ls
gopass show fnox/GITHUB_TOKEN  # verify; do not echo in logs
```

Optional mise task sketch (`aspects/aur/mise.toml`):

```toml
[tasks."gopass-store"]
description = "Clone password store from GitHub (requires GPG key + Q1 URL)"
depends = [":packages"]
usage = 'arg "<repo_url>" help="GitHub git URL for password store"'
run = '…'
```

Consider extending `arch:test-container` binds when Q3 resolves.

## Review notes

Round 1 (agent draft). Before implementation:

1. User confirms Q1 (repo URL) and Q2 (GPG key transfer).
2. Decide Q3 for VM workflow.
3. Link from step 13 passmenu spec as hard prerequisite.
