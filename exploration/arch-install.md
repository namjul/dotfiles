# Arch install (not Omarchy)

Install a machine with the **official Arch ISO** and **archinstall**, then clone this repo and run `install.sh`. This repo is a mise/aspects tree. It is not an Omarchy installer and does not implement the quattro ISO contract (`omarchy-apply-system`, packaged `/usr/share/omarchy`, offline `[offline]` pacman).

Omarchy ISO `main` used to clone a git repo and `source install.sh`. Quattro dropped that hook. We do not fork `omarchy-iso` to get it back.

## Path

1. Boot the official monthly Arch ISO ([archlinux.org](https://archlinux.org/download/)).
2. Give the live session a working network (Ethernet DHCP, or `iwctl` / `nmtui` for Wi‑Fi). `"network_config": { "type": "iso" }` copies that live setup onto the installed disk. If the ISO cannot `ping archlinux.org`, neither will the new system.
3. On the live ISO, `git clone` this repo onto the live root (or `--config` a raw GitHub URL for the JSON only). Then run the wrapper, not bare `archinstall`:

```bash
/root/dotfiles/bin/arch-install/arch-install.sh
```

That script is the current live-ISO entry. It runs `configure.sh` first (gum forms: keyboard, user, hostname, timezone, disk, LUKS confirm). Official ISO does not ship `gum`; configure installs `gum`/`jq`/`openssl` via pacman if missing. Forms rewrite `user_configuration.json` and `user_credentials.json` in this directory (ext4 + Limine + 4.3, not Omarchy btrfs). `SKIP_CONFIGURE=1` keeps the checked-in JSON.

UI taken from Omarchy’s `configurator`: `gum input` / `choose` / `filter` / `confirm` / `table`, hide the live USB disk, Ctrl+C toggles LUKS vs plain wipe. Not taken: Tokyo Night TTY palette, `clear_logo` helpers, offline flags, chroot desktop install.

Then it patches two archinstall 4.2 / Python 3.14 bugs in `/usr/lib/python3.14/site-packages/archinstall/lib/installer.py` (logfile `Path` join, Limine `Path.copy` target), then:

```bash
archinstall --config "$DIR/user_configuration.json" --creds "$DIR/user_credentials.json"
```

Omarchy’s `.automated_script.sh` uses the same two `sed` lines and the same `--config` / `--creds` pair, plus `--silent --skip-ntp --skip-wkd --skip-wifi-check`. Those extra flags belong to an offline custom ISO (pre-populated keyring, no NTP/WKD/Wi‑Fi probe). Official monthly ISO stays online; we do not pass them.

Fallback if you do not want `--creds`: `archinstall --config /path/to/user_configuration.json` and type passwords in the TUI.

4. Reboot into the installed system (or `arch-chroot /mnt` as the new user). The clone must land on the **installed** disk, not only live RAM.
5. Network still works (`ip -br a`, `ping -c 1 archlinux.org`).
6. Clone and install:

```bash
git clone <this-repo-url> ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`user_configuration.json` already installs `git` and `base-devel`. Stock archinstall writes a normal online `pacman.conf` (core/extra/multilib). There is no ISO leftover `offline.db`.

`install.sh` links `~/.dotfiles`, bootstraps mise (`curl https://mise.run` if needed), then runs the aspect defaults (`nala` / `homebrew` skip or no-op on Arch; `aur` is the Arch desktop path).

## What lives where

| Concern | Owner |
|---|---|
| Live-ISO archinstall invoke (configure → patches → `--config` + `--creds`) | `bin/arch-install/arch-install.sh` |
| gum forms that write the two JSON files | `bin/arch-install/configure.sh` |
| Disk, wipe, filesystems, **LUKS** | archinstall `disk_config` / `disk_encryption` — written by configure, applied by archinstall |
| User, password, hostname, locale, mirrors | `user_credentials.json` + `user_configuration.json` |
| Live USB branding, extra live packages | **Not this path.** Official ISO only. `mkarchiso` later if we want a custom stick |
| Sway, SDDM, packages, dots | `install.sh` → `//aspects/aur:*` and the other aspects |

Current JSON (`bin/arch-install/user_configuration.json`) still names `/dev/vda` (a VM disk). On metal, change `device` to the real disk (`/dev/nvme0n1`, `/dev/sda`, …) before running archinstall. Ext4 root, **no** encryption block, hostname `namarchy`, Limine, timezone Europe/Vienna. Add LUKS in that file or in the TUI when the machine should unlock at initramfs.

## Closed

- `omarchy-iso` quattro / `--local-source` / `omarchy-pkgs`
- Custom ISO required for LUKS or “profile”
- `/var/tmp/omarchy-install-completed` as a reboot signal (leftover in `install.sh` if still present — unused on this path)
- Cloning only on the live ISO without copying into `/mnt/home/<user>`

## Later (optional)

Official **archiso** / `mkarchiso` from a copied `releng` profile, if we want a USB that already contains this repo or auto-starts archinstall. Same install-time story: LUKS and users stay in archinstall.

## Sequence: official ISO to Sway

Reducibility: pocket found — boot medium, then archinstall, then this repo’s `install.sh` is a fixed order; passwords and LUKS are taste, not structure.

```markdown
# From official ISO to Sway

intent: A machine that boots the stock Arch live medium, becomes your installed disk, then becomes this checkout’s desktop.
context: [domain]

human: which disk (JSON still says `/dev/vda`); LUKS or plain root; type passwords in the TUI (no `--creds`) vs a local creds file you do not commit

## Genesis

intent: The live stick and the installed disk are one story; Omarchy is not in it.
context: [domain]

1. The install medium is the official monthly Arch ISO (download + write; you do not run `mkarchiso`).
2. This repo stays a post-install tree: archinstall owns disk and user; `install.sh` owns the desktop.

## Stage 1: Live whole

intent: A booted official ISO with network and this repo’s config.
context: [stack]

1. Write the official Arch ISO to a USB; boot it on the machine.
2. Get a link (plug Ethernet, or `iwctl` / `nmtui`); the live ISO already has `git`.
3. `git clone <this-repo> /root/dotfiles` (or `--config` the JSON’s raw GitHub URL).

## Stage 2: Installed disk

intent: Arch on the target, with your user, before any aspects.
context: [stack]

1. `/root/dotfiles/bin/arch-install/arch-install.sh` (patches installer.py, then `--config` + `--creds` next to the script). Fallback: `archinstall --config …/user_configuration.json` and type passwords in the TUI.
2. human: confirm disk (`/dev/vda` is a VM); add LUKS in the TUI if the JSON has no encryption block
3. Let archinstall wipe the chosen disk, pacstrap, Limine, `git` + `base-devel`.
4. Reboot into the installed system (not the live RAM disk).
5. If LUKS: unlock at initramfs, then TTY login as `samho`.

## Stage 3: This repo is the system

intent: The installed user home grows into the dotfiles monorepo and a greeter.
context: [stack]

1. Confirm the link again on the installed OS.
2. `git clone <this-repo> ~/.dotfiles && cd ~/.dotfiles && ./install.sh`

## Stage 4: Secrets after the user exists

intent: Age stays off the public repo and off the live ISO.
context: [domain]

1. Restore `~/.config/age/key.txt` (USB, YubiKey, paper) only after login.
2. Then password-store / sops / fnox — not during archinstall.
```

## Lookup

- Live-ISO entry: `bin/arch-install/arch-install.sh` (`configure.sh` then archinstall)
- Archinstall configs: `bin/arch-install/user_configuration.json`, `bin/arch-install/user_credentials.json`
- Entry after reboot/clone: `install.sh`
- Desktop sequence: [PLAN.sway.md](../aspects/aur/PLAN.sway.md)
- archiso (only if we build a stick): https://wiki.archlinux.org/title/Archiso
