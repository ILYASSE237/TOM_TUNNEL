# TOM_TUNNEL

**Premium Multi-Protocol VPS VPN Script Suite** — Version 1.0.0

## Features (complets)

### Protocoles
- **SSH/WS** — Dropbear + WebSocket + Stunnel
- **VMess / VLESS / Trojan / SOCKS** — Xray-core
- **ZIVPN** — UDP custom
- **SlowDNS** — dnstt (build Go réel, service systemd)
- **Nginx** — reverse proxy / landing

### Outils
- DNS Panel, Domain, IPv6, VPS Status, NetGuard, Port Info
- Clean logs, Fast DNS, Telegram Bot
- Web Panel (Node.js + React)
- Update / Uninstall / Reboot

## Installation

```bash
# Depuis le package
unzip TOM_TUNNEL.zip
cd TOM_TUNNEL
sudo bash tom_tunnel.sh
# ou
sudo bash autoinstall.sh
```

## Structure

```
TOM_TUNNEL/
├── tom_tunnel.sh          # Installateur principal
├── autoinstall.sh
├── version
├── core/                  # xray, sshws, zivpn, slowdns, udp...
├── menu/                  # Tous les menus interactifs
├── module/                # Configs, binaires, services, UI
├── tom_tunnel-web/        # Web panel (frontend + server)
├── tom_tunnel_core_bot/   # Bot Telegram
├── tom_tunnel_bot_source/ # Source bot alternative
└── docs/
```

## Menu

```
╔══════════════════════════════════════╗
║        🚀 TOM_TUNNEL                 ║
╠══════════════════════════════════════╣
║ OS / IPv4 / IPv6 / DOMAIN / UPTIME   ║
╚══════════════════════════════════════╝
[01] SSH/WS  [02] VMESS  [03] VLESS  [04] TROJAN  [05] SOCKS  [06] ZIVPN
[07] DNS  [08] DOMAIN  [09] IPV6  [10] STATUS  [11] NETGUARD
[12] PORTS  [13] LOGS  [14] BOT  [15] UNINSTALL  [16] FAST DNS
[18] WEB PANEL  [00] EXIT  [88] REBOOT  [99] UPDATE
```

## Requirements
- Debian / Ubuntu root, x86_64, not OpenVZ

## Note SlowDNS
Installé via `git clone https://www.bamsoftware.com/git/dnstt.git` + `go build`.
Service `dnstt` UDP :5300 → SSH 22.
