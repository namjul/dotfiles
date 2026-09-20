# WireGuard VPS Tunnel — Simple Local Web Server from Workplace

## Goal

Verify the tunnel works by serving a simple Python web server on your Desktop,
accessible from your workplace through the VPS.

## Architecture

```
[Workplace] ──HTTP──▶ [VPS :8080] ──WireGuard──▶ [Desktop :8080]
             public IP                 tunnel        Python http.server
```

---

## IP & Port Reference

| IP | Where | Purpose |
|----|-------|---------|
| `<VPS_PUBLIC_IP>` | Internet | VPS real IP — workplace connects here, Desktop dials here |
| `10.0.0.1` | Tunnel | VPS virtual tunnel IP |
| `10.0.0.2` | Tunnel | Desktop virtual tunnel IP — where web server lives |
| `0.0.0.0` | Desktop | Tells Python server to accept connections from any interface |

| Port | Protocol | On | Purpose |
|------|----------|----|---------|
| `51820` | UDP | VPS | WireGuard — Desktop dials in here to form the tunnel |
| `8080` | TCP | VPS + Desktop | Python web server |

---

## Step 1 — Install WireGuard

Run on **both VPS and Desktop**:

```bash
sudo apt update && sudo apt install wireguard -y
```

---

## Step 2 — Generate Key Pairs

Run on **each machine** separately:

```bash
wg genkey | tee privatekey | wg pubkey > publickey
cat privatekey   # save this — never share it
cat publickey    # share with the other machine
```

---

## Step 3 — Configure WireGuard on the VPS

`/etc/wireguard/wg0.conf` on the **VPS**:

```ini
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <VPS_PRIVATE_KEY>

# Forward web server traffic into the tunnel
PostUp   = iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 10.0.0.2:8080
PostUp   = iptables -A FORWARD -p tcp -d 10.0.0.2 --dport 8080 -j ACCEPT
PostDown = iptables -t nat -D PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 10.0.0.2:8080
PostDown = iptables -D FORWARD -p tcp -d 10.0.0.2 --dport 8080 -j ACCEPT

[Peer]
# Desktop
PublicKey = <DESKTOP_PUBLIC_KEY>
AllowedIPs = 10.0.0.2/32
```

Enable IP forwarding on the VPS:

```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

---

## Step 4 — Configure WireGuard on the Desktop

`/etc/wireguard/wg0.conf` on the **Desktop**:

```ini
[Interface]
Address = 10.0.0.2/24
PrivateKey = <DESKTOP_PRIVATE_KEY>

[Peer]
# VPS
PublicKey = <VPS_PUBLIC_KEY>
Endpoint = <VPS_PUBLIC_IP>:51820
AllowedIPs = 10.0.0.1/32
PersistentKeepalive = 25
```

> `PersistentKeepalive = 25` keeps the tunnel alive through your home NAT.

---

## Step 5 — Start WireGuard on Both Machines

```bash
sudo systemctl enable --now wg-quick@wg0
```

---

## Step 6 — Test the Tunnel

From the Desktop, ping the VPS tunnel IP:

```bash
ping 10.0.0.1
```

From the VPS, ping the Desktop tunnel IP:

```bash
ping 10.0.0.2
```

Both should respond. If not, check your `wg0.conf` keys.

---

## Step 7 — Open Firewall on the VPS

```bash
sudo ufw allow 51820/udp   # WireGuard
sudo ufw allow 8080/tcp    # Web server
sudo ufw reload
```

---

## Step 8 — Start the Python Web Server on the Desktop

Create a test page:

```bash
mkdir ~/testserver && cd ~/testserver
echo "<h1>Tunnel works!</h1>" > index.html
```

Start the server, listening on all interfaces:

```bash
python3 -m http.server 8080 --bind 0.0.0.0
```

---

## Step 9 — Test from Workplace

Open a browser or run:

```bash
curl http://<VPS_PUBLIC_IP>:8080
```

You should see `Tunnel works!`

---

## Prevent Desktop from Sleeping

The tunnel dies if the Desktop sleeps:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

---

## Next Step

Once this works, swap Python http.server for Ollama on port `11434` — the tunnel
config stays identical, just change the port numbers.
