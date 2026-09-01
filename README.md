# 🚀 TOM_TUNNEL

### Panel professionnel de gestion de tunnels VPN
**Installation en une commande · Debian · Ubuntu · x86_64**

| VERSION | 2.0.0 |
|---|---|
| PLATFORM | DEBIAN \| UBUNTU |
| ARCH | X86_64 |
| TYPE | MULTI-PROTOCOLE |
| STATUS | STABLE |

> Un panneau unique pour déployer, superviser et gérer plusieurs services VPN sur un VPS, avec installation automatisée, menu de gestion et services persistants après redémarrage.

---

## ⚡ Installation rapide

> **Prérequis :** VPS Debian ou Ubuntu, accès **root** et architecture **x86_64**.  
> Le script refuse notamment les environnements OpenVZ.

### Installation en une commande

```bash
git clone https://github.com/ILYASSE237/TOM_TUNNEL.git && cd TOM_TUNNEL && sudo bash autoinstall.sh
```

### Installation manuelle

```bash
git clone https://github.com/ILYASSE237/TOM_TUNNEL.git
cd TOM_TUNNEL
sudo bash tom_tunnel.sh
```

L'installation est interactive : acceptez les conditions, puis renseignez le domaine lorsque le script le demande.

---

## 🌐 Domaine

Le domaine utilisé par TOM_TUNNEL doit pointer vers **l'adresse IP publique du VPS**.

Exemple :

```text
vpn.example.com  →  IP_DU_VPS
```

Le script vérifie que le domaine résout vers l'IP du serveur avant de poursuivre l'installation.

### ⚠️ SlowDNS / NS Domain

Lors de l'installation de SlowDNS, le script demande également un **NS Domain**.

Exemple :

```text
NS Domain : ns1.example.com
```

Préparez donc votre domaine et votre configuration DNS avant de lancer l'installation.

---

## 🔐 Protocoles et services

TOM_TUNNEL regroupe notamment :

- **SSH / WebSocket**
- **Dropbear**
- **VMess**
- **VLESS**
- **Trojan**
- **SOCKS**
- **ZIVPN**
- **SlowDNS / dnstt**
- **Nginx**
- **Reverse Proxy**
- **Telegram Bot**
- **Web Panel**
- **NetGuard**
- **Fast DNS**
- **Gestion des ports**
- **Logs**
- **Mise à jour / désinstallation / redémarrage**

---

## 📋 Menu principal

Après installation, le panneau fournit notamment :

```text
╔══════════════════════════════════════════════╗
║              🚀 TOM_TUNNEL                  ║
╠══════════════════════════════════════════════╣
║  SSH/WS   VMESS   VLESS   TROJAN   SOCKS    ║
║  ZIVPN    DNS     DOMAIN  IPV6    STATUS    ║
║  NETGUARD PORTS   LOGS    BOT     FAST DNS  ║
║  WEB PANEL   UPDATE   UNINSTALL   REBOOT    ║
╚══════════════════════════════════════════════╝
```

---

## 🛠️ Configuration recommandée

Avant l'installation :

1. Utiliser un VPS **Debian ou Ubuntu**.
2. Se connecter avec un compte **root** ou utiliser `sudo`.
3. Vérifier que le VPS est en **x86_64**.
4. Faire pointer le domaine vers l'IP publique du VPS.
5. Préparer le **NS Domain** pour SlowDNS.
6. Lancer l'installateur.

---

## 🔄 Après installation

Le script configure et démarre les services disponibles sur le serveur. Il active également certains services au démarrage et applique l'optimisation TCP BBR.

Un redémarrage du VPS est **recommandé** après l'installation.

Pour relancer le menu :

```bash
menu
```

---

## 📁 Structure du projet

```text
TOM_TUNNEL/
├── core/                  # Cœur des protocoles
├── docs/                  # Documentation
├── menu/                  # Menus de gestion
├── module/                # Modules, services et interface
├── tom_tunnel_bot_source/ # Source du bot Telegram
├── tom_tunnel_core_bot/   # Bot Telegram
├── tom_tunnel_web/        # Interface Web
├── autoinstall.sh         # Installateur automatique
├── tom_tunnel.sh          # Installateur principal
├── patch_menu.py
├── port_info
├── version
└── README.md
```

---

## 📡 Support Telegram

Pour le support, les informations et les mises à jour :

**Telegram : [@scotpro3](https://t.me/scotpro3)**

---

## ⚠️ Avertissement

TOM_TUNNEL est fourni **tel quel**. Utilisez les services installés uniquement dans le respect des lois, des conditions de votre hébergeur et des politiques des réseaux concernés.

Avant toute installation sur un serveur de production, effectuez une sauvegarde de vos configurations importantes.

---

## 🔗 Dépôt officiel

**GitHub :**  
https://github.com/ILYASSE237/TOM_TUNNEL

---

### TOM_TUNNEL
**Multi-Protocol VPS VPN Management Suite**
