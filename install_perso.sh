#!/bin/bash
GITHUB_RAW="https://raw.githubusercontent.com/ILYASSE237/TOM_TUNNEL/main"

echo "--- Nettoyage et arrêt des services conflictuels ---"
systemctl stop nginx stunnel5 badvpn@7100 badvpn@7200 badvpn@7300 xray ssh dnstt 2>/dev/null

echo "--- Téléchargement des protocoles d'installation ---"
wget -q --timeout=30 --tries=3 -O /usr/bin/setup_zivpn "$GITHUB_RAW/core/setup_zivpn.sh" || { echo "[ERROR] setup_zivpn"; exit 1; }
wget -q --timeout=30 --tries=3 -O /usr/bin/setup_udp   "$GITHUB_RAW/core/setup_udp.sh"   || { echo "[ERROR] setup_udp"; exit 1; }
wget -q --timeout=30 --tries=3 -O /usr/bin/setup_xray  "$GITHUB_RAW/core/xray.sh"        || { echo "[ERROR] setup_xray"; exit 1; }
wget -q --timeout=30 --tries=3 -O /usr/bin/setup_ssh   "$GITHUB_RAW/core/sshws.sh"       || { echo "[ERROR] setup_ssh"; exit 1; }
wget -q --timeout=30 --tries=3 -O /usr/bin/setup_dns   "$GITHUB_RAW/core/setup_dns.sh"   || { echo "[ERROR] setup_dns"; exit 1; }

chmod +x /usr/bin/setup_*

echo "--- Téléchargement de l'écosystème complet du Menu ---"
wget -q --timeout=30 --tries=3 -O /usr/bin/menu "$GITHUB_RAW/menu/menu.sh" || { echo "[ERROR] menu"; exit 1; }
chmod +x /usr/bin/menu

FILES=("zivpn.sh" "vmess.sh" "vless.sh" "update.sh" "trojan.sh" "status.sh" "ssh.sh" "socks.sh" "port.sh" "netguard.sh" "log.sh" "iptools.sh" "expiry.sh" "domain.sh" "dns.sh" "tgbot.sh")

for file in "${FILES[@]}"; do
    cmd_name=$(echo "$file" | sed 's/\.sh//')
    wget -q --timeout=30 --tries=3 -O "/usr/bin/$cmd_name" "$GITHUB_RAW/menu/$file" || {
        echo "[ERROR] Impossible de télécharger $file"
        exit 1
    }
    chmod +x "/usr/bin/$cmd_name"
done

echo "--- Exécution des configurations ---"
echo "[1/5] Installation Xray..."
/usr/bin/setup_xray

echo "[2/5] Installation SSH/WS..."
/usr/bin/setup_ssh

echo "[3/5] Installation ZIVPN..."
/usr/bin/setup_zivpn

echo "[4/5] Installation UDP Custom..."
/usr/bin/setup_udp

echo "[5/5] Installation SlowDNS..."
echo "→ Vous allez devoir entrer le NS Domain"
/usr/bin/setup_dns

# Rafraîchir les chemins du terminal
hash -r

echo ""
echo "=============================================="
echo " Installation V2 terminée avec succès !"
echo " Tapez 'menu' pour lancer le panneau."
echo "=============================================="