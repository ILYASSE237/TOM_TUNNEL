#!/bin/bash
# TOM_TUNNEL — Main Menu
UI="/usr/local/lib/tom_tunnel-ui.sh"
[ -f "$UI" ] && source "$UI"

MYIP=$(curl -sS --max-time 5 ipv4.icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}')
IPV6=$(curl -sS --max-time 5 ipv6.icanhazip.com 2>/dev/null || ip -6 addr show scope global 2>/dev/null | awk '/inet6/{print $2}' | head -1 | cut -d/ -f1)
domain=$(cat /etc/xray/domain 2>/dev/null || echo "N/A")
uptime="$(uptime -p 2>/dev/null | cut -d ' ' -f 2-10 || echo "N/A")"
VERSION_FILE="/etc/version"
INSTALLED_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")
readonly SERVER_HOST="https://raw.githubusercontent.com/ILYASSSE237/TOM_TUNNEL/main"
LATEST_VERSION=$(curl -fsS --max-time 4 "$SERVER_HOST/version" 2>/dev/null || echo "$INSTALLED_VERSION")
UPDATE_AVAILABLE=0
version_greater(){ [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n1)" = "$1" ] && [ "$1" != "$2" ]; }
version_greater "$LATEST_VERSION" "$INSTALLED_VERSION" && UPDATE_AVAILABLE=1

if [ -f /etc/os-release ]; then . /etc/os-release; OS="$NAME"; VER="$VERSION_ID"; else OS=$(uname -s); VER=$(uname -r); fi

svc(){ systemctl is-active "$1" 2>/dev/null | grep -q '^active$'; }
mark(){
  if svc "$1"; then printf '%b' "${K_GREEN}🟢 RUN${K_RESET}"
  else printf '%b' "${K_RED}🔴 OFF${K_RESET}"; fi
}

# defaults if UI not loaded
K_GREEN="${K_GREEN:-\033[0;32m}"; K_RED="${K_RED:-\033[1;31m}"; K_CYAN="${K_CYAN:-\033[0;36m}"
K_YELLOW="${K_YELLOW:-\033[1;33m}"; K_WHITE="${K_WHITE:-\033[1;37m}"; K_DIM="${K_DIM:-\033[2m}"; K_RESET="${K_RESET:-\033[0m}"

# ─────────────────────────────────────────────────────────────────
# Helper functions for new box style
# ─────────────────────────────────────────────────────────────────

# Remove ANSI color codes to compute visible length
strip_ansi() {
  printf '%b' "$1" | sed -r 's/\x1B\[[0-9;]*[mK]//g'
}

# Pad string to given visible width (counting only visible chars)
pad_visible() {
  local str="$1" width="$2"
  local visible=$(strip_ansi "$str")
  local len=${#visible}
  if [ $len -lt $width ]; then
    local pad=$((width - len))
    str+="$(printf '%*s' $pad '')"
  fi
  printf '%b' "$str"
}

# Center text within a fixed width
center_text() {
  local text="$1" width="$2"
  local visible=$(strip_ansi "$text")
  local len=${#visible}
  local left=$(( (width - len) / 2 ))
  local right=$(( width - len - left ))
  printf '%*s%s%*s' $left '' "$text" $right ''
}

# Build a line with two options: [num1] label1  [num2] label2
menu_line() {
  local num1="$1" label1="$2" num2="$3" label2="$4"
  local col_width=29   # width for each column (after number + space)
  local left="[$(printf '%02d' $num1)] ${label1}"
  local right="[$(printf '%02d' $num2)] ${label2}"
  left=$(pad_visible "$left" $col_width)
  right=$(pad_visible "$right" $col_width)
  printf '┃ %b  %b ┃\n' "$left" "$right"
}

# ─────────────────────────────────────────────────────────────────
# Display new menu
# ─────────────────────────────────────────────────────────────────

clear

# --- Top info box (╭─╮ style) ---
INNER_WIDTH=68  # width of content between left │ and right │

# Prepare values
os_info="${OS:-N/A} ${VER:-}"
ipv4="${MYIP:-N/A}"
ipv6="${IPV6:-N/A}"
dom="${domain:-N/A}"
up="${uptime:-N/A}"
ver="${INSTALLED_VERSION:-1.0.0}"

# Services status line
svc_xray=$(mark xray)
svc_ssh=$(mark dropbear 2>/dev/null || mark ssh)
svc_web=$(mark tom_tunnel-web 2>/dev/null || echo -e "${K_DIM}—${K_RESET}")
svc_zivpn=$(mark zivpn 2>/dev/null)
services_line="Xray ${svc_xray} • SSH ${svc_ssh} • Web ${svc_web} • ZIVPN ${svc_zivpn}"

# Top border
printf '╭────────────────────────────────────────────────────────────────╮\n'
printf '│ %-68s │\n' "🖥️  VPS       : ${os_info}"
printf '│ %-68s │\n' "🌐 IPv4      : ${ipv4}"
printf '│ %-68s │\n' "🌍 IPv6      : ${ipv6}"
printf '│ %-68s │\n' "🔗 DOMAIN    : ${dom}"
printf '│ %-68s │\n' "⏱️  UPTIME   : ${up}"
printf '│ %-68s │\n' "📦 VERSION   : ${ver}"
printf '│ %-68s │\n' "⚡ SERVICES  : ${services_line}"
printf '╰────────────────────────────────────────────────────────────────╯\n'
echo

# --- Protocols Section ---
title="🚀 MENU TOM_TUNNEL"
printf '┏━━━━━━━━━━━━━━━━━━ %s ━━━━━━━━━━━━━━━━━━━━┓\n' "$(center_text "$title" 40)"
menu_line 1 "🔐 SSH/WS" 2 "🌐 VMESS"
menu_line 3 "🛡️  VLESS" 4 "🔥 TROJAN"
menu_line 5 "🧦 SOCKS" 6 "⚡ ZIVPN"
printf '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n'
echo

# --- Tools Section ---
title="🛠️  TOOLS TOM_TUNNEL"
printf '┏━━━━━━━━━━━━━━━━━━ %s ━━━━━━━━━━━━━━━━━━━━┓\n' "$(center_text "$title" 40)"
menu_line 7 "📡 DNS PANEL" 8 "🌐 DOMAIN PANEL"
menu_line 9 "6️⃣ IPV6 PANEL" 10 "📊 VPS STATUS"
menu_line 11 "🛡️ NETGUARD PANEL" 12 "🔌 VPN PORT INFO"
menu_line 13 "🧹 CLEAN VPN LOGS" 14 "🤖 TOM_TUNNEL BOT PANEL"
menu_line 15 "🗑️ UNINSTALL" 16 "⚡ FAST DNS MENU"
printf '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n'
echo

# --- Web Panel Section ---
title="🖥️  WEB PANEL TOM_TUNNEL"
printf '┏━━━━━━━━━━━━━━━━━━ %s ━━━━━━━━━━━━━━━━━━━━┓\n' "$(center_text "$title" 40)"
printf '┃ %-66s ┃\n' "18. 🌍 TOM_TUNNEL TUNNEL WEB"
printf '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n'
echo

# --- System Section ---
title="⚙️  SYSTEM"
printf '┏━━━━━━━━━━━━━━━━━━ %s ━━━━━━━━━━━━━━━━━━━━┓\n' "$(center_text "$title" 40)"
menu_line 0 "🚪 EXIT" 88 "🔄 REBOOT VPS"
printf '┃ %-66s ┃\n' "99. 🔃 UPDATE TOM_TUNNEL"
printf '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\n'
echo

# Version & update info
printf '%b\n' "${K_DIM}Version : ${INSTALLED_VERSION}${K_RESET}"
if [ "$UPDATE_AVAILABLE" -eq 1 ]; then
  printf '%b\n' "${K_RED}⚡ UPDATE AVAILABLE : v${LATEST_VERSION}${K_RESET}"
fi
echo
printf '%b' "${K_GREEN}  Select option » ${K_RESET}"
read -r opt
echo

case "$opt" in
  1|01)  clear; /usr/local/sbin/ssh 2>/dev/null || bash "$(dirname "$0")/ssh.sh" ;;
  2|02)  clear; /usr/local/sbin/vmess 2>/dev/null || bash "$(dirname "$0")/vmess.sh" ;;
  3|03)  clear; /usr/local/sbin/vless 2>/dev/null || bash "$(dirname "$0")/vless.sh" ;;
  4|04)  clear; /usr/local/sbin/trojan 2>/dev/null || bash "$(dirname "$0")/trojan.sh" ;;
  5|05)  clear; /usr/local/sbin/socks 2>/dev/null || bash "$(dirname "$0")/socks.sh" ;;
  6|06)  clear; /usr/local/sbin/zivpn 2>/dev/null || bash "$(dirname "$0")/zivpn.sh" ;;
  7|07)  clear; /usr/local/sbin/dns 2>/dev/null || bash "$(dirname "$0")/dns.sh" ;;
  8|08)  clear; /usr/local/sbin/domain 2>/dev/null || bash "$(dirname "$0")/domain.sh" ;;
  9|09)  clear; /usr/local/sbin/iptools 2>/dev/null || bash "$(dirname "$0")/iptools.sh" ;;
  10)    clear; /usr/local/sbin/status 2>/dev/null || bash "$(dirname "$0")/status.sh" ;;
  11)    clear; /usr/local/sbin/netguard 2>/dev/null || bash "$(dirname "$0")/netguard.sh" ;;
  12)    clear; /usr/local/sbin/port 2>/dev/null || bash "$(dirname "$0")/port.sh" ;;
  13)    clear; /usr/local/sbin/log 2>/dev/null || bash "$(dirname "$0")/log.sh" ;;
  14)    clear; /usr/local/sbin/tgbot 2>/dev/null || bash "$(dirname "$0")/tgbot.sh" ;;
  15)    clear; /usr/local/sbin/uninstall 2>/dev/null || bash "$(dirname "$0")/uninstall.sh" ;;
  16)    clear; /usr/local/sbin/fastdns 2>/dev/null || bash "$(dirname "$0")/fastdns.sh" ;;
  18)    clear; /usr/local/sbin/web 2>/dev/null || bash "$(dirname "$0")/web.sh" ;;
  88|17) reboot ;;
  99)    clear; /usr/local/sbin/update 2>/dev/null || bash "$(dirname "$0")/update.sh" ;;
  0|00)  exit 0 ;;
  *)     printf '%b\n' "${K_RED}Invalid option.${K_RESET}"; sleep 1 ;;
esac

exec /usr/local/sbin/menu