#!/bin/bash
# JOEL_TOM — Main Menu
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

if [ -f /etc/os-release ]; then . /etc/os-release; OS="$NAME"; VER="\( VERSION_ID"; else OS= \)(uname -s); VER=$(uname -r); fi

svc(){ systemctl is-active "$1" 2>/dev/null | grep -q '^active$'; }
mark(){
  if svc "$1"; then printf '%b' "\( {K_GREEN}● ON \){K_RESET}"
  else printf '%b' "\( {K_RED}● OFF \){K_RESET}"; fi
}

# Colors (fallback if UI not loaded)
K_GREEN="${K_GREEN:-\033[0;32m}"
K_RED="${K_RED:-\033[1;31m}"
K_CYAN="${K_CYAN:-\033[0;36m}"
K_BLUE="${K_BLUE:-\033[1;34m}"
K_YELLOW="${K_YELLOW:-\033[1;33m}"
K_WHITE="${K_WHITE:-\033[1;37m}"
K_MAGENTA="${K_MAGENTA:-\033[1;35m}"
K_DIM="${K_DIM:-\033[2m}"
K_BOLD="${K_BOLD:-\033[1m}"
K_RESET="${K_RESET:-\033[0m}"
K_BG="${K_BG:-\033[40m}"

# Neon helpers
NC="${K_CYAN}"
NB="${K_BLUE}"
NW="${K_WHITE}"
NG="${K_GREEN}"
NR="${K_RED}"
NY="${K_YELLOW}"
NM="${K_MAGENTA}"
ND="${K_DIM}"
R="${K_RESET}"

clear

# ═══════════════════════════════════════════════════════════════
#                        HEADER
# ═══════════════════════════════════════════════════════════════
printf '%b\n' "\( {NC}╔════════════════════════════════════════════════════════════════════════════╗ \){R}"
printf '%b\n' "\( {NC}║ \){R}  \( {NC}🛡️ \){R}                    \( {K_BOLD} \){NC}J O E L _ T O M${R}                    \( {NC}🛡️ \){R}  \( {NC}║ \){R}"
printf '%b\n' "\( {NC}║ \){R}           \( {ND}★ \){R}  \( {NW}PREMIUM MULTI-PROTOCOL VPS CONTROL PANEL \){R}  \( {ND}★ \){R}            \( {NC}║ \){R}"
printf '%b\n' "\( {NC}╚════════════════════════════════════════════════════════════════════════════╝ \){R}"
echo

# ═══════════════════════════════════════════════════════════════
#                     INFO + MAP PANEL
# ═══════════════════════════════════════════════════════════════
printf '%b\n' "\( {NC}┌──────────────────────────────────────┬─────────────────────────────────────┐ \){R}"
printf '%b\n' "\( {NC}│ \){R} 🖥️  \( {NW}VPS OS \){R}   : \( {NG} \)(printf '%-22s' "\( {OS:0:22}") \){R}\( {NC}│ \){R}                                     \( {NC}│ \){R}"
printf '%b\n' "\( {NC}│ \){R} 🌐  \( {NW}IPV4 \){R}    : \( {NG} \)(printf '%-22s' "\( {MYIP:-N/A}") \){R}\( {NC}│ \){R}          \( {ND}·  ·  ·  ·  · \){R}             \( {NC}│ \){R}"
printf '%b\n' "\( {NC}│ \){R} 🌍  \( {NW}IPV6 \){R}    : \( {NG} \)(printf '%-22s' "\( {IPV6:0:22}") \){R}\( {NC}│ \){R}       \( {ND}·  ·  ·  ·  ·  ·  · \){R}          \( {NC}│ \){R}"
printf '%b\n' "\( {NC}│ \){R} 🔗  \( {NW}DOMAIN \){R}  : \( {NG} \)(printf '%-22s' "\( {domain:0:22}") \){R}\( {NC}│ \){R}     \( {ND}·  ·  ·  ·  ·  ·  ·  · \){R}        \( {NC}│ \){R}"
printf '%b\n' "\( {NC}│ \){R} ⏱️   \( {NW}UPTIME \){R}  : \( {NG} \)(printf '%-22s' "\( {uptime:0:22}") \){R}\( {NC}│ \){R}       \( {ND}·  ·  ·  ·  ·  ·  · \){R}          \( {NC}│ \){R}"
printf '%b\n' "\( {NC}│ \){R} 📦  \( {NW}VERSION \){R} : \( {NG} \)(printf '%-22s' "\( {INSTALLED_VERSION}") \){R}\( {NC}│ \){R}          \( {ND}·  ·  ·  ·  · \){R}             \( {NC}│ \){R}"
printf '%b\n' "\( {NC}└──────────────────────────────────────┴─────────────────────────────────────┘ \){R}"
echo

# Services status
printf '%b\n' "  \( {NY}⚡ SERVICES \){R}   \( {NC}| \){R}  XRAY $(mark xray)   \( {NC}| \){R}  NGINX $(mark nginx)   \( {NC}| \){R}  SSH $(mark ssh)"
echo

# ═══════════════════════════════════════════════════════════════
#                         PROTOCOLS
# ═══════════════════════════════════════════════════════════════
printf '%b\n' "${NM}┌─────────────────────────────── \( {NY}🚀 PROTOCOLS \){NM} ───────────────────────────────┐${R}"
printf '%b\n' "\( {NM}│ \){R}  \( {NC}[01] \){R} 🔒 SSH/WS MENU          \( {NC}│ \){R}  \( {NC}[02] \){R} 🌐 VMESS MENU              \( {NM}│ \){R}"
printf '%b\n' "\( {NM}│ \){R}  \( {NC}[03] \){R} 🛡️  VLESS MENU          \( {NC}│ \){R}  \( {NC}[04] \){R} 🔥 TROJAN MENU             \( {NM}│ \){R}"
printf '%b\n' "\( {NM}│ \){R}  \( {NC}[05] \){R} 🧦 SOCKS MENU           \( {NC}│ \){R}  \( {NC}[06] \){R} ⚡ ZIVPN MENU              \( {NM}│ \){R}"
printf '%b\n' "\( {NM}└────────────────────────────────────────────────────────────────────────────┘ \){R}"
echo

# ═══════════════════════════════════════════════════════════════
#                           TOOLS
# ═══════════════════════════════════════════════════════════════
printf '%b\n' "${NY}┌─────────────────────────────── \( {NW}🛠️  TOOLS \){NY} ────────────────────────────────┐${R}"
printf '%b\n' "\( {NY}│ \){R}  \( {NC}[07] \){R} ✂️  DNS PANEL            \( {NC}│ \){R}  \( {NC}[08] \){R} 🌐 DOMAIN PANEL            \( {NY}│ \){R}"
printf '%b\n' "\( {NY}│ \){R}  \( {NC}[09] \){R} 6️⃣  IPV6 PANEL           \( {NC}│ \){R}  \( {NC}[10] \){R} 📊 VPS STATUS              \( {NY}│ \){R}"
printf '%b\n' "\( {NY}│ \){R}  \( {NC}[11] \){R} 🛡️  NETGUARD PANEL       \( {NC}│ \){R}  \( {NC}[12] \){R} 🔌 VPN PORT INFO           \( {NY}│ \){R}"
printf '%b\n' "\( {NY}│ \){R}  \( {NC}[13] \){R} 🧹 CLEAN VPS LOGS        \( {NC}│ \){R}  \( {NC}[14] \){R} 🤖 JOEL_TOM BOT PANEL      \( {NY}│ \){R}"
printf '%b\n' "\( {NY}│ \){R}  \( {NC}[15] \){R} 🗑️  UNINSTALL JOEL_TOM   \( {NC}│ \){R}  \( {NC}[16] \){R} ⚡ FAST DNS MENU           \( {NY}│ \){R}"
printf '%b\n' "\( {NY}└────────────────────────────────────────────────────────────────────────────┘ \){R}"
echo

# ═══════════════════════════════════════════════════════════════
#                         WEB PANEL
# ═══════════════════════════════════════════════════════════════
printf '%b\n' "${NG}┌─────────────────────────────── \( {NW}🌐 WEB PANEL \){NG} ──────────────────────────────┐${R}"
printf '%b\n' "\( {NG}│ \){R}  \( {NC}[18] \){R} 🌍 JOEL_TOM TUNNEL WEB                                              \( {NG}│ \){R}"
printf '%b\n' "\( {NG}└────────────────────────────────────────────────────────────────────────────┘ \){R}"
echo

# ═══════════════════════════════════════════════════════════════
#                          SYSTEM
# ═══════════════════════════════════════════════════════════════
printf '%b\n' "${NR}┌─────────────────────────────── \( {NW}⚙️  SYSTEM \){NR} ────────────────────────────────┐${R}"
printf '%b\n' "\( {NR}│ \){R}  \( {NC}[88] \){R} 🔄 REBOOT VPS            \( {NC}│ \){R}  \( {NC}[99] \){R} 🔃 UPDATE SCRIPT           \( {NR}│ \){R}"
printf '%b\n' "\( {NR}│ \){R}  \( {NC}[00] \){R} 🚪 EXIT                                                         \( {NR}│ \){R}"
printf '%b\n' "\( {NR}└────────────────────────────────────────────────────────────────────────────┘ \){R}"
echo

# Footer
printf '%b\n' "\( {ND}  ★─── JOEL_TOM  •  Premium Multi-Protocol VPS Control ───★ \){R}"
if [ "$UPDATE_AVAILABLE" -eq 1 ]; then
  printf '%b\n' "  \( {NR}⚡ UPDATE AVAILABLE : v \){LATEST_VERSION}${R}"
fi
echo
printf '%b' "${NG}→ Sélection : ${R}"
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
  *)     printf '%b\n' "\( {K_RED}Invalid option. \){K_RESET}"; sleep 1 ;;
esac

exec /usr/local/sbin/menu