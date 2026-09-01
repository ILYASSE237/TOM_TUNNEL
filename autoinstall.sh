#!/bin/bash

# ============================================================
# TOM_TUNNEL — Auto Installer
# ============================================================

clear

echo -e "\e[36m====================================================\e[0m"
echo -e "\e[36m       DÉMARRAGE DE L'INSTALLATION TOM_TUNNEL      \e[0m"
echo -e "\e[36m====================================================\e[0m"
echo

# ------------------------------------------------------------
# Root
# ------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "[-] ERREUR : ce script doit être exécuté en root."
    exit 1
fi

# ------------------------------------------------------------
# Détection OS
# ------------------------------------------------------------

if [ ! -f /etc/os-release ]; then
    echo "[-] ERREUR : impossible de détecter le système."
    exit 1
fi

. /etc/os-release

case "$ID" in
    ubuntu|debian)
        echo "[+] Système détecté : $PRETTY_NAME"
        ;;
    *)
        echo "[-] ERREUR : système non supporté : $ID"
        echo "[!] TOM_TUNNEL supporte Debian et Ubuntu."
        exit 1
        ;;
esac

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

SERVER_HOST="https://raw.githubusercontent.com/ILYASSE237/TOM_TUNNEL/main"

# ------------------------------------------------------------
# Dépendances minimales
# ------------------------------------------------------------

echo "[+] Mise à jour des dépôts..."

export DEBIAN_FRONTEND=noninteractive

if ! apt-get update; then
    echo "[-] ERREUR : apt-get update a échoué."
    exit 1
fi

echo "[+] Installation des dépendances..."

if ! apt-get install -y wget curl ca-certificates; then
    echo "[-] ERREUR : impossible d'installer wget/curl."
    exit 1
fi

# ------------------------------------------------------------
# Test connexion GitHub
# ------------------------------------------------------------

echo "[+] Vérification de l'accès au dépôt TOM_TUNNEL..."

if ! curl -4fsS --max-time 15 \
    "$SERVER_HOST/tom_tunnel.sh" >/dev/null; then

    echo "[-] ERREUR : impossible d'accéder au dépôt TOM_TUNNEL."
    echo "[!] Vérifie la connexion Internet du VPS."
    exit 1
fi

# ------------------------------------------------------------
# Optimisation réseau IPv4
# ------------------------------------------------------------

echo "[+] Configuration réseau..."

if ! grep -qF "precedence ::ffff:0:0/96  100" /etc/gai.conf 2>/dev/null; then
    echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf
fi

sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1 || true

# ------------------------------------------------------------
# Téléchargement de tom_tunnel.sh
# ------------------------------------------------------------

echo "[+] Téléchargement de tom_tunnel.sh..."

TMP_SCRIPT="$(mktemp)"

if ! wget -q \
    --timeout=30 \
    --tries=3 \
    "$SERVER_HOST/tom_tunnel.sh" \
    -O "$TMP_SCRIPT"; then

    echo "[-] ERREUR : téléchargement de tom_tunnel.sh échoué."
    rm -f "$TMP_SCRIPT"
    exit 1
fi

# ------------------------------------------------------------
# Vérifications
# ------------------------------------------------------------

if [ ! -s "$TMP_SCRIPT" ]; then
    echo "[-] ERREUR : tom_tunnel.sh est vide."
    rm -f "$TMP_SCRIPT"
    exit 1
fi

if ! head -n 1 "$TMP_SCRIPT" | grep -q "bash"; then
    echo "[-] ERREUR : tom_tunnel.sh ne semble pas être un script Bash."
    rm -f "$TMP_SCRIPT"
    exit 1
fi

if ! bash -n "$TMP_SCRIPT"; then
    echo "[-] ERREUR : tom_tunnel.sh contient une erreur de syntaxe."
    rm -f "$TMP_SCRIPT"
    exit 1
fi

# ------------------------------------------------------------
# Installation du script principal
# ------------------------------------------------------------

install -m 755 "$TMP_SCRIPT" /root/tom_tunnel.sh
rm -f "$TMP_SCRIPT"

if [ ! -x /root/tom_tunnel.sh ]; then
    echo "[-] ERREUR : impossible d'installer tom_tunnel.sh."
    exit 1
fi

echo "[+] Fichier noyau OK."
echo "[+] Lancement de TOM_TUNNEL..."
echo

# ------------------------------------------------------------
# Lancement
# ------------------------------------------------------------

if [ -r /dev/tty ]; then
    exec bash /root/tom_tunnel.sh </dev/tty
else
    exec bash /root/tom_tunnel.sh
fi