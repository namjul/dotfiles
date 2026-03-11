# WireGuard VPS Tunnel Setup - Complete Process

## Overview

This documents the complete setup process for creating a WireGuard tunnel between a VPS and Desktop PC to expose local services through the VPS public IP.

## Architecture

```
[Workplace] ──HTTP──▶ [VPS :8081] ──WireGuard──▶ [Desktop :8081]
             public IP                 tunnel        Local service
```

## IP Configuration

- VPS Public IP: `80.240.23.145`
- VPS Tunnel IP: `10.0.0.1`
- Desktop Tunnel IP: `10.0.0.2`
- WireGuard Port: `51820/udp`
- Service Port: `8081/tcp` (8080 was occupied by anki-sync-server)

---

## VPS Setup (Automated via Aspect)

### 1. Aspect Structure

Created aspect at `aspects/server/files/home/square/aspects/wireguard/`:
- `mise.toml` - Environment configuration
- `wg0.conf` - WireGuard config template
- `default` - Setup script

### 2. Key Generation

Generate keys locally or on VPS:
```bash
wg genkey | tee vps_privatekey | wg pubkey > vps_publickey
```

Add to `mise.toml`:
```toml
[env]
VPS_PRIVATE_KEY = "<generated_key>"
DESKTOP_PUBLIC_KEY = "<desktop_public_key>"

[tasks.default]
file = './default'
```

### 3. WireGuard Config Template

`wg0.conf`:
```ini
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = ${VPS_PRIVATE_KEY}

PostUp   = iptables -t nat -A PREROUTING -p tcp --dport 8081 -j DNAT --to-destination 10.0.0.2:8081
PostUp   = iptables -A FORWARD -p tcp -d 10.0.0.2 --dport 8081 -j ACCEPT
PostDown = iptables -t nat -D PREROUTING -p tcp --dport 8081 -j DNAT --to-destination 10.0.0.2:8081
PostDown = iptables -D FORWARD -p tcp -d 10.0.0.2 --dport 8081 -j ACCEPT

[Peer]
PublicKey = ${DESKTOP_PUBLIC_KEY}
AllowedIPs = 10.0.0.2/32
```

### 4. Setup Script

`default`:
```bash
#!/usr/bin/env bash
# mise description="Setup WireGuard VPN Tunnel"

set -euxo pipefail

sudo apt install wireguard -y

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

envsubst < ${root}/wg0.conf | sudo tee /etc/wireguard/wg0.conf

sudo systemctl daemon-reload
sudo systemctl enable --now wg-quick@wg0
sudo systemctl restart wg-quick@wg0
```

### 5. Firewall Configuration

Updated `aspects/server/config/ufw.sh`:
```bash
ufw allow 51820/udp   # WireGuard
ufw allow 8081/tcp    # Service port
```

---

## Desktop Setup (Manual)

### 1. Install WireGuard

```bash
sudo apt update && sudo apt install wireguard -y
```

### 2. Generate Keys

```bash
wg genkey | tee desktop_privatekey | wg pubkey > desktop_publickey
cat desktop_privatekey desktop_publickey
```

### 3. Create Config

Create `/etc/wireguard/wg0.conf`:
```ini
[Interface]
Address = 10.0.0.2/24
PrivateKey = <DESKTOP_PRIVATE_KEY>

[Peer]
PublicKey = 0GA80u8cIUGbB531dmFMjgxdX3fOMmf82QQepQlEBzM=
Endpoint = 80.240.23.145:51820
AllowedIPs = 10.0.0.1/32
PersistentKeepalive = 25
```

Using heredoc (fish shell compatible):
```bash
sudo tee /etc/wireguard/wg0.conf <<'EOF'
[Interface]
Address = 10.0.0.2/24
PrivateKey = <DESKTOP_PRIVATE_KEY>

[Peer]
PublicKey = 0GA80u8cIUGbB531dmFMjgxdX3fOMmf82QQepQlEBzM=
Endpoint = 80.240.23.145:51820
AllowedIPs = 10.0.0.1/32
PersistentKeepalive = 25
EOF
```

Or use nano for pasting:
```bash
sudo nano /etc/wireguard/wg0.conf
# Paste with Ctrl+Shift+V or right-click
```

### 4. Start WireGuard

```bash
sudo systemctl enable --now wg-quick@wg0
```

---

## Testing

### 1. Verify Tunnel

On Desktop:
```bash
sudo wg show
ping -c 3 10.0.0.1
```

On VPS:
```bash
sudo wg show
ping -c 3 10.0.0.2
```

Both should show handshake and successful pings.

### 2. Test Service Forwarding

On Desktop, start test server:
```bash
mkdir -p ~/testserver && cd ~/testserver
echo "<h1>Tunnel works!</h1>" > index.html
python3 -m http.server 8081 --bind 0.0.0.0
```

From VPS, test direct tunnel:
```bash
curl http://10.0.0.2:8081
```

From external network (phone/workplace):
```
http://80.240.23.145:8081
```

---

## Troubleshooting

### Port Already in Use

Check what's using the port on VPS:
```bash
ss -tlnp | grep 8081
```

If occupied, use a different port in both `wg0.conf` and test server.

### iptables Rules Not Applied

Verify rules exist:
```bash
sudo iptables -t nat -L PREROUTING -n -v | grep 8081
sudo iptables -L FORWARD -n -v | grep 10.0.0.2
```

If missing, restart WireGuard:
```bash
sudo systemctl restart wg-quick@wg0
```

### No Handshake Between Peers

Check firewall allows WireGuard:
```bash
sudo ufw status | grep 51820
```

Verify keys match in configs:
```bash
sudo wg show
```

### VPS Can't Reach Own Public IP

This is expected - DNAT only affects PREROUTING chain (external traffic), not OUTPUT (localhost).
Test from actual external network instead.

### Local Network Device Unreachable

If trying to access another device on local network (e.g., Ollama server):

1. Check device is online:
```bash
nmap -sn 192.168.1.0/24
```

2. Check firewall on target device:
```bash
sudo ufw allow from 192.168.1.0/24
```

3. Check router AP Isolation:
- Access router admin (usually http://192.168.1.1)
- Disable "AP Isolation" or "Client Isolation" in wireless settings
- This feature blocks WiFi clients from communicating with each other

---

## IP Forwarding Explanation

The `net.ipv4.ip_forward=1` setting enables the kernel to route packets between interfaces.

Without it, the VPS would drop packets traveling between:
- Public interface (eth0) ↔ WireGuard tunnel (wg0)
- Required for VPS to act as gateway/router

---

## Next Steps

- Replace test Python server with actual service (Ollama on port 11434)
- Update port numbers in `wg0.conf` from 8081 to 11434
- Restart WireGuard to apply changes
- Configure service to listen on 0.0.0.0 instead of localhost
