# server

Manages the remote VPS at `hobl.at`. Structured as a monorepo of aspects — the same pattern as the top-level dotfiles repo.

## Navigation

```
server/
├── mise.toml                     deployment tasks (server:init, server:up, remote:*)
├── init                          one-time VPS initialization
├── up                            idempotent sync to remote
├── config/                       sshd, SSH client config, UFW firewall
├── secrets/                      SOPS-encrypted credentials (SSH keys, rclone)
├── dns/                          DNS zone files
└── files/
    ├── etc/                      system-level configs (environment, gitconfig, mise)
    └── home/square/aspects/      services running on the VPS
        ├── actualbudget/         budget management (Docker Compose)
        ├── anki/                 flashcard server
        ├── caddy/                reverse proxy / HTTPS termination
        ├── cron/                 scheduled tasks
        ├── docker/               Docker daemon setup
        ├── dotfiles/             server-side dotfiles
        ├── ejabberd/             XMPP messaging server
        ├── evolu-relay/          Evolu database sync relay (Node)
        ├── goatcounter/          analytics
        ├── memex/                knowledge base (Bun/Python)
        ├── meta/                 smoke tests
        ├── pdfding/              PDF management (Docker Compose)
        ├── soft-serve/           self-hosted git server
        ├── tools/                utility scripts
        ├── webhook/              git push webhook handler (Go)
        ├── website/              static site builder
        └── wireguard/            VPN
```

Each aspect follows the same structure: `mise.toml` (tool versions + tasks), `default` script (idempotent setup), optional systemd service file and Caddyfile.
