
Doable, but there's a contract you need to implement in your dotfiles
 repo. The ISO build clones OMARCHY_INSTALLER_REPO and expects this
structure:

dotfiles/
├── install.sh                     ← main script, sourced in chroot as $USER
├── install/
│   ├── omarchy-base.packages      ← package list for offline mirror
│   ├── omarchy-other.packages     ← additional packages for offline mirror
│   └── helpers/
│       └── all.sh                 ← helper functions (sourced before configurator runs)
├── bin/
│   └── omarchy-upload-log         ← stub needed, copied to /usr/local/bin
└── default/
    └── plymouth/                  ← Plymouth boot theme files

Your install.sh runs inside chroot as the new user with passwordless
sudo. Environment it gets:
- OMARCHY_USER — username
- OMARCHY_USER_NAME, OMARCHY_USER_EMAIL — from configurator
- HOME, USER set correctly
- offline pacman mirror available at /var/cache/omarchy/mirror/offline

So your install.sh would essentially be: install packages → clone
dotfiles → run aspects.

Tradeoffs vs. standard ISO + archinstall.json:

┌──────────────────────────┬───────────────┬────────────────────┐
│                          │ omarchy-iso   │    standard ISO    │
│                          │     fork      │                    │
├──────────────────────────┼───────────────┼────────────────────┤
│ TUI configurator         │ included free │ manual             │
│ (keyboard/user/disk)     │               │                    │
├──────────────────────────┼───────────────┼────────────────────┤
│ Offline package mirror   │ auto-bundled  │ download at        │
│                          │               │ install time       │
├──────────────────────────┼───────────────┼────────────────────┤
│ Plymouth boot theme      │ need to make  │ n/a                │
│                          │ one           │                    │
├──────────────────────────┼───────────────┼────────────────────┤
│ Scaffold to implement    │ ~5 files      │ ~1                 │
│                          │               │ archinstall.json   │
├──────────────────────────┼───────────────┼────────────────────┤
│ Build time               │ 30-60 min +   │ none               │
│                          │ Docker        │                    │
├──────────────────────────┼───────────────┼────────────────────┤
│ ISO size                 │ 7GB+          │ ~1GB               │
└──────────────────────────┴───────────────┴────────────────────┘

The offline mirror is the main real benefit — no internet needed
during install. Is that a requirement, or are you always online when
installing?
