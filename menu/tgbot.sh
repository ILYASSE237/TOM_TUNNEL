#!/bin/bash
set -u
UI="/usr/local/lib/tom_tunnel-ui.sh"; [ -f "$UI" ] && source "$UI"
[ -f "$UI" ] && k_header "TOM_TUNNEL VPN • 🤖 BOT PANEL" || clear

CONFIG_DIR="/etc/tom_tunnel_bot"
CONFIG="$CONFIG_DIR/config.json"
SERVICE="tom_tunnel_bot"
mkdir -p "$CONFIG_DIR"
chmod 700 "$CONFIG_DIR"

echo -e "${K_CYAN}╭────────────────────────────────────────────────────────────────╮${K_RESET}"
echo -e "${K_CYAN}│ ${K_WHITE}🤖 TOM_TUNNEL BOT PANEL${K_RESET}                                  ${K_CYAN}│${K_RESET}"
echo -e "${K_CYAN}╰────────────────────────────────────────────────────────────────╯${K_RESET}"
echo
echo -e "${K_YELLOW}ℹ️ Aucun TOKEN ni ID Telegram n'est demandé pendant l'installation.${K_RESET}"

if ! command -v python3 >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y python3 python3-pip
fi
python3 -m pip install --break-system-packages pyTelegramBotAPI psutil >/dev/null 2>&1 || true

if [ ! -f "$CONFIG" ]; then
  cat > "$CONFIG" <<'JSON'
{
  "bot_token": "",
  "super_admin": 0,
  "admins": [],
  "enabled": false
}
JSON
  chmod 600 "$CONFIG"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOT_SRC="$(dirname "$SCRIPT_DIR")/tom_tunnel_core_bot"
if [ -d "$BOT_SRC" ]; then
  cp -a "$BOT_SRC"/. "$CONFIG_DIR"/
fi

if [ -f "$CONFIG_DIR/tom_tunnel_bot.py" ]; then
  cat > "/etc/systemd/system/${SERVICE}.service" <<EOF
[Unit]
Description=TOM_TUNNEL Telegram Bot
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$CONFIG_DIR
ExecStart=/usr/bin/python3 $CONFIG_DIR/tom_tunnel_bot.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  TOKEN="$(python3 - "$CONFIG" <<'PY'
import json,sys
try:
    print(json.load(open(sys.argv[1])).get("bot_token",""))
except Exception:
    print("")
PY
)"
  if [ -n "$TOKEN" ]; then
    systemctl enable --now "$SERVICE" >/dev/null 2>&1 || true
    echo -e "${K_GREEN}✔ Bot configuré détecté : service démarré.${K_RESET}"
  else
    systemctl disable --now "$SERVICE" >/dev/null 2>&1 || true
    echo -e "${K_YELLOW}ℹ Bot installé mais désactivé : aucun TOKEN configuré.${K_RESET}"
  fi
else
  echo -e "${K_YELLOW}ℹ️ Moteur du bot non présent dans cette distribution. Le panneau reste disponible.${K_RESET}"
fi

read -r -p " Appuyez sur Entrée pour revenir au menu..." _
exec /usr/local/sbin/menu
