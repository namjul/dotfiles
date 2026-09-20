# Agent isolation: wincent Tart sandboxes vs Gondolin vs sandbox-runtime

Exploration notes from comparing Greg Hurrell’s [wincent](https://github.com/wincent/wincent) Tart VM workflow (seen in a local checkout under `~/code/tries/2026-09-09-wincent-wincent`) with [Gondolin](https://github.com/earendil-works/gondolin) and Anthropic’s [sandbox-runtime](https://github.com/anthropics/sandbox-runtime) (`srt`). This repo does not implement the wincent VM stack; the doc is for deciding when each approach fits.

## Wincent Tart + `sb` sandboxes

Wincent uses [Tart](https://tart.run/) on **macOS Apple Silicon** to run **Ubuntu 24.04** guests (Cirrus Labs OCI image, e.g. `ghcr.io/cirruslabs/ubuntu:latest`). Fig treats guests as **`linux.debian`** and runs the `vm` aspect only there (`fig.config.ts`).

Two layers:

1. **Base image (`wincent-base`)** — `bin/vm create` clones Ubuntu, pushes the dotfiles checkout, runs `./install`. Roughly an 11-minute one-time provision on a fast Mac (per wincent `CONTRIBUTING.md`).
2. **Project sandboxes** — `sb create` / `sb ssh` copy-on-write clones from the base (e.g. **wincent-sandbox** for the dotfiles repo, or per-subproject VMs for agents and untrusted deps).

Default VM login: `admin` / `admin`. Workflow is **SSH into a full Linux dev box** provisioned like wincent on Debian/Ubuntu (Neovim, shell, node, optional rust/dprint/Claude Code/tmux in `aspects/vm/index.ts`), not a one-shot command wrapper on the host.

Security story: **strong OS boundary** (separate kernel/userspace), **weak built-in egress/secret policy** unless you add firewalls or other controls. Secrets often reach the guest via SSH (`AcceptEnv` in `aspects/vm/files/etc/ssh/sshd_config.d/sandbox.conf`), not host-side injection.

### What `sandbox.conf` does

Installed at `/etc/ssh/sshd_config.d/sandbox.conf` by the `vm` aspect; restarts `ssh` on change.

- **`AcceptEnv`** — whitelists client env vars (`ANTHROPIC_API_KEY`, `CLAUDE_CODE_OAUTH_TOKEN`, `KAGI_API_TOKEN`, `LANG`, `LC_*`) so tokens and locale can flow from the Mac SSH client into the session.
- **`StreamLocalBindUnlink yes`** — removes stale Unix sockets before stream-local binds, so reconnects for socket forwarding do not fail with “address already in use.”

The filename reflects the **`sb` sandbox** SSH tuning for coding agents, not a generic “sandbox runtime” product.

## Gondolin

Local **disposable micro-VMs** (QEMU by default, optional experimental `krun`), default **minimal Alpine** image (~200MB+ guest assets, auto-cached). **macOS and Linux** hosts.

Designed for **programmable policy** in JavaScript:

- HTTP/TLS egress allowlists and hooks
- **Secret injection** — guest sees placeholders; host injects only for allowed destinations
- Custom VFS mounts, snapshots/resume, optional SSH and ingress gateway

Typical unit: **one agent turn or task** in a small VM with explicit network and filesystem rules. Pi integration can mount the project at `/workspace` ([pi-gondolin example](https://github.com/earendil-works/gondolin/blob/main/host/examples/pi-gondolin.ts)).

Same broad family as wincent (**real Linux guest, separate kernel**), opposite on **granularity and policy**: policy-first micro-VMs, not a cloned personal dotfiles server.

## Anthropic sandbox-runtime (`srt`)

**Not a VM.** Wraps **process trees on the host**:

- **macOS** — `sandbox-exec` / Seatbelt profiles
- **Linux** — bubblewrap + network namespace
- **Windows** — dedicated local user + WFP egress

**Filesystem** — deny/allow read/write paths on the **host** tree (e.g. allow `.`, block `~/.ssh`).

**Network** — proxy-based allowlists around wrapped commands.

Aimed at **Claude Code**, arbitrary bash, and **MCP servers** (`srt npx …`) with default-deny holes. Lightweight startup; no Ubuntu image or `sb inject` lifecycle.

## Comparison (when to use which)

| Dimension | Wincent Tart + `sb` | Gondolin | `srt` |
| --- | --- | --- | --- |
| Isolation | Full Ubuntu VM | Micro-VM (Alpine default) | Host OS sandbox |
| Guest environment | Curated dotfiles install | Minimal / custom image | Host filesystem + same OS |
| Network policy | Guest default routing; SSH env only in `sandbox.conf` | JS hooks, allowlists | Proxy + config (`~/.srt-settings.json`) |
| Secrets | Real values in guest session (e.g. SSH `AcceptEnv`) | Host injection; guest placeholders | Config-bound; not VM-style injection |
| Host platforms | macOS + Tart only | macOS, Linux | macOS, Linux, Windows |
| Typical session | Long SSH dev work, `sb inject` / `sb extract` | `npx @earendil-works/gondolin bash`, attach/snapshot | `srt "command"` or wrap MCP |
| Maintenance | Base image, registry push/pull, `bin/vm` / `sb` | Image cache, optional custom builds | npm package + local policy file |

**Isolation strength (guest kernel boundary):** full Tart VM ≈ Gondolin micro-VM **>** `srt` on the host. That ordering is about **boundary type**, not a ranking of which product is “safest” overall—misconfiguration hurts any layer.

**Policy precision for agents:** Gondolin and `srt` are built for allowlists and secret control. Wincent optimizes **environment fidelity + VM boundary**, with SSH tweaks for tokens.

## Relation to this dotfiles repo

- **Arch / `linux` platform** here: `aspects/server` for VPS, `aspects/ssh` for keys/config—not Tart `vm` or `sandbox.conf`.
- Exploring wincent-style VMs is relevant on a **Mac + Tart** setup with a wincent checkout; on this machine, Gondolin or `srt` may be more practical for agent sandboxing without maintaining `wincent-base`.

## Sources

- Wincent: `CONTRIBUTING.md` (“Working with VMs”), `aspects/vm/aspect.json`, `aspects/vm/index.ts`, `aspects/vm/files/etc/ssh/sshd_config.d/sandbox.conf`
- Gondolin: [README](https://github.com/earendil-works/gondolin/blob/main/README.md), [docs](https://earendil-works.github.io/gondolin/)
- `srt`: [README](https://github.com/anthropics/sandbox-runtime/blob/main/README.md)
