#!/bin/bash
# TOM_TUNNEL — Auto Installer
clear
echo -e "\e[36m====================================================\e[0m"
echo -e "\e[36m    DÉMARRAGE DE L'INSTALLATION: TOM_TUNNEL     \e[0m"
echo -e "\e[36m====================================================\e[0m"

apt-get update -y >/dev/null 2>&1
apt-get install -y wget curl >/dev/null 2>&1

echo "[+] Optimisation des routes réseau..."
echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf 2>/dev/null || true
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1 || true

SERVER_HOST="https://raw.githubusercontent.com/ILYASSE237/TOM_TUNNEL/main"
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"

echo "[+] Connexion au dépôt TOM_TUNNEL..."
if [ -f "$SCRIPT_DIR/tom_tunnel.sh" ]; then
  cp "$SCRIPT_DIR/tom_tunnel.sh" /root/tom_tunnel.sh
elif [ -f ./tom_tunnel.sh ]; then
  cp ./tom_tunnel.sh /root/tom_tunnel.sh
else
  wget -qO /root/tom_tunnel.sh "$SERVER_HOST/tom_tunnel.sh" 2>/dev/null
fi

if [ -f /root/tom_tunnel.sh ]; then
    echo "[+] Fichier noyau OK. Lancement..."
    chmod +x /root/tom_tunnel.sh
    # Also copy full package next to installer for offline install
    if [ -d "$SCRIPT_DIR/menu" ]; then
      export TOM_TUNNEL_SRC="$SCRIPT_DIR"
    fi
    if [ -r /dev/tty ]; then
        exec bash /root/tom_tunnel.sh </dev/tty
    else
        exec bash /root/tom_tunnel.sh
    fi
else
    echo "[-] ERREUR: tom_tunnel.sh introuvable."
    exit 1
fi