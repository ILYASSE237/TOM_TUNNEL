#!/bin/bash
# ==============================================================
# TOM_TUNNEL — Premium Multi-Protocol VPS Control Panel
# Presented by JOEL TOM
# ==============================================================

UI="/usr/local/lib/tom_tunnel-ui.sh"
[ -f "$UI" ] && source "$UI"

# =========================
# SERVER INFORMATION
# =========================

MYIP=$(curl -sS --max-time 5 ipv4.icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}')
IPV6=$(curl -sS --max-time 5 ipv6.icanhazip.com 2>/dev/null || ip -6 addr show scope global 2>/dev/null | awk '/inet6/{print $2}' | head -1 | cut -d/ -f1)

domain=$(cat /etc/xray/domain 2>/dev/null || echo "N/A")
uptime="$(uptime -p 2>/dev/null | cut -d ' ' -f 2-10 || echo "N/A")"

VERSION_FILE="/etc/version"
INSTALLED_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")

readonly SERVER_HOST="https://raw.githubusercontent.com/ILYASSSE237/TOM_TUNNEL/main"

LATEST_VERSION=$(curl -fsS --max-time 4 \
"$SERVER_HOST/version" 2>/dev/null || echo "$INSTALLED_VERSION")

UPDATE_AVAILABLE=0

version_greater(){
    [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n1)" = "$1" ] &&
    [ "$1" != "$2" ]
}

version_greater "$LATEST_VERSION" "$INSTALLED_VERSION" &&
UPDATE_AVAILABLE=1

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS="$NAME"
    VER="$VERSION_ID"
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

# =========================
# COLORS
# =========================

K_RESET="${K_RESET:-\033[0m}"

K_CYAN="${K_CYAN:-\033[1;36m}"
K_BLUE="${K_BLUE:-\033[1;34m}"
K_GREEN="${K_GREEN:-\033[1;32m}"
K_RED="${K_RED:-\033[1;31m}"
K_YELLOW="${K_YELLOW:-\033[1;33m}"
K_MAGENTA="${K_MAGENTA:-\033[1;35m}"
K_WHITE="${K_WHITE:-\033[1;37m}"
K_DIM="${K_DIM:-\033[2m}"

# =========================
# SERVICE STATUS
# =========================

svc(){
    systemctl is-active "$1" 2>/dev/null | grep -q '^active$'
}

mark(){
    if svc "$1"; then
        printf '%b' "${K_GREEN}● ONLINE${K_RESET}"
    else
        printf '%b' "${K_RED}● OFFLINE${K_RESET}"
    fi
}

# =========================
# DISPLAY
# =========================

clear

# ==============================================================
# TOM_TUNNEL PREMIUM BANNER
# ==============================================================

printf '%b\n' "${K_CYAN}╔══════════════════════════════════════════════════════════════════════════╗${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}                                                                      ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}       ${K_CYAN}████████╗ ██████╗ ███╗   ███╗${K_RESET}                         ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}       ${K_CYAN}╚══██╔══╝██╔═══██╗████╗ ████║${K_RESET}                         ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}          ${K_CYAN}██║   ██║   ██║██╔████╔██║${K_RESET}                         ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}          ${K_CYAN}██║   ██║   ██║██║╚██╔╝██║${K_RESET}                         ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}          ${K_CYAN}██║   ╚██████╔╝██║ ╚═╝ ██║${K_RESET}                         ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}          ${K_CYAN}╚═╝    ╚═════╝ ╚═╝     ╚═╝${K_RESET}                         ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}                                                                      ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}                    ${K_WHITE}TOM_TUNNEL${K_RESET}                               ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}             ${K_MAGENTA}★ PRESENTED BY JOEL TOM ★${K_RESET}                         ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}                  ${K_YELLOW}VERSION ${INSTALLED_VERSION}${K_RESET}                            ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}          ${K_DIM}PREMIUM MULTI-PROTOCOL VPS CONTROL PANEL${K_RESET}              ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}                                                                      ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}╚══════════════════════════════════════════════════════════════════════════╝${K_RESET}"

echo

# ==============================================================
# SERVER INFORMATION
# ==============================================================

printf '%b\n' "${K_CYAN}╔══════════════════════[ 🖥 SERVER INFORMATION ]══════════════════════════╗${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}                                                                      ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}   🖥️  VPS OS       : ${K_GREEN}${OS}${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}   🌐 IPv4         : ${K_GREEN}${MYIP:-N/A}${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}   🌍 IPv6         : ${K_GREEN}${IPV6:-N/A}${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}   🔗 DOMAIN       : ${K_GREEN}${domain:-N/A}${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}   ⏱️  UPTIME       : ${K_GREEN}${uptime:-N/A}${K_RESET}"
printf '%b\n' "${K_CYAN}║${K_RESET}                                                                      ${K_CYAN}║${K_RESET}"
printf '%b\n' "${K_CYAN}╚══════════════════════════════════════════════════════════════════════════╝${K_RESET}"

echo

# ==============================================================
# SERVICES
# ==============================================================

printf '%b\n' "${K_BLUE}╔════════════════════════════[ ⚡ SERVICES ]═══════════════════════════════╗${K_RESET}"
printf '%b\n' "${K_BLUE}║${K_RESET}                                                                      ${K_BLUE}║${K_RESET}"
printf '%b\n' "${K_BLUE}║${K_RESET}   ⚡ XRAY       : $(mark xray)"
printf '%b\n' "${K_BLUE}║${K_RESET}   🌐 NGINX      : $(mark nginx)"
printf '%b\n' "${K_BLUE}║${K_RESET}   🔐 SSH        : $(mark ssh)"
printf '%b\n' "${K_BLUE}║${K_RESET}   📡 ZIVPN      : $(mark zivpn)"
printf '%b\n' "${K_BLUE}║${K_RESET}                                                                      ${K_BLUE}║${K_RESET}"
printf '%b\n' "${K_BLUE}╚══════════════════════════════════════════════════════════════════════════╝${K_RESET}"

echo

# ==============================================================
# PROTOCOLS
# ==============================================================

printf '%b\n' "${K_MAGENTA}╔═══════════════════════[ 🚀 PROTOCOLS ]══════════════════════════════════╗${K_RESET}"
printf '%b\n' "${K_MAGENTA}║${K_RESET}                                                                      ${K_MAGENTA}║${K_RESET}"
printf '%b\n' "${K_MAGENTA}║${K_RESET}   ${K_CYAN}[01]${K_RESET} 🔐 SSH / WS          ${K_CYAN}[02]${K_RESET} ⚡ VMESS                ${K_MAGENTA}║${K_RESET}"
printf '%b\n' "${K_MAGENTA}║${K_RESET}   ${K_CYAN}[03]${K_RESET} 🛡️  VLESS             ${K_CYAN}[04]${K_RESET} 🔥 TROJAN               ${K_MAGENTA}║${K_RESET}"
printf '%b\n' "${K_MAGENTA}║${K_RESET}   ${K_CYAN}[05]${K_RESET} 🌐 SOCKS              ${K_CYAN}[06]${K_RESET} ⚡ ZIVPN                 ${K_MAGENTA}║${K_RESET}"
printf '%b\n' "${K_MAGENTA}║${K_RESET}                                                                      ${K_MAGENTA}║${K_RESET}"
printf '%b\n' "${K_MAGENTA}╚══════════════════════════════════════════════════════════════════════════╝${K_RESET}"

echo

# ==============================================================
# TOOLS
# ==============================================================

printf '%b\n' "${K_YELLOW}╔═══════════════════════════[ 🛠 TOOLS ]═══════════════════════════════════╗${K_RESET}"
printf '%b\n' "${K_YELLOW}║${K_RESET}                                                                      ${K_YELLOW}║${K_RESET}"
printf '%b\n' "${K_YELLOW}║${K_RESET}   ${K_CYAN}[07]${K_RESET} 🌐 DNS PANEL          ${K_CYAN}[08]${K_RESET} 🔗 DOMAIN PANEL        ${K_YELLOW}║${K_RESET}"
printf '%b\n' "${K_YELLOW}║${K_RESET}   ${K_CYAN}[09]${K_RESET} 🌍 IPV6 PANEL         ${K_CYAN}[10]${K_RESET} 📊 VPS STATUS          ${K_YELLOW}║${K_RESET}"
printf '%b\n' "${K_YELLOW}║${K_RESET}   ${K_CYAN}[11]${K_RESET} 🛡️  NETGUARD PANEL     ${K_CYAN}[12]${K_RESET} 🔌 VPN PORT INFO       ${K_YELLOW}║${K_RESET}"
printf '%b\n' "${K_YELLOW}║${K_RESET}   ${K_CYAN}[13]${K_RESET} 🧹 CLEAN VPS LOGS      ${K_CYAN}[14]${K_RESET} 🤖 TOM_TUNNEL BOT      ${K_YELLOW}║${K_RESET}"
printf '%b\n' "${K_YELLOW}║${K_RESET}   ${K_CYAN}[15]${K_RESET} 🗑️  UNINSTALL           ${K_CYAN}[16]${K_RESET} ⚡ FAST DNS MENU        ${K_YELLOW}║${K_RESET}"
printf '%b\n' "${K_YELLOW}║${K_RESET}                                                                      ${K_YELLOW}║${K_RESET}"
printf '%b\n' "${K_YELLOW}╚══════════════════════════════════════════════════════════════════════════╝${K_RESET}"

echo

# ==============================================================
# WEB PANEL
# ==============================================================

printf '%b\n' "${K_GREEN}╔══════════════════════════[ 🌐 WEB PANEL ]════════════════════════════════╗${K_RESET}"
printf '%b\n' "${K_GREEN}║${K_RESET}                                                                      ${K_GREEN}║${K_RESET}"
printf '%b\n' "${K_GREEN}║${K_RESET}   ${K_CYAN}[18]${K_RESET} 🖥️  TOM_TUNNEL WEB     $(mark tom_tunnel-web 2>/dev/null || echo -e "${K_DIM}● UNKNOWN${K_RESET}")"
printf '%b\n' "${K_GREEN}║${K_RESET}                                                                      ${K_GREEN}║${K_RESET}"
printf '%b\n' "${K_GREEN}╚══════════════════════════════════════════════════════════════════════════╝${K_RESET}"

echo

# ==============================================================
# SYSTEM
# ==============================================================

printf '%b\n' "${K_RED}╔════════════════════════════[ ⚙ SYSTEM ]══════════════════════════════════╗${K_RESET}"
printf '%b\n' "${K_RED}║${K_RESET}                                                                      ${K_RED}║${K_RESET}"
printf '%b\n' "${K_RED}║${K_RESET}   ${K_CYAN}[88]${K_RESET} 🔄 REBOOT VPS         ${K_CYAN}[99]${K_RESET} 🔃 UPDATE TOM_TUNNEL   ${K_RED}║${K_RESET}"
printf '%b\n' "${K_RED}║${K_RESET}   ${K_CYAN}[00]${K_RESET} 🚪 EXIT                                                        ${K_RED}║${K_RESET}"
printf '%b\n' "${K_RED}║${K_RESET}                                                                      ${K_RED}║${K_RESET}"
printf '%b\n' "${K_RED}╚══════════════════════════════════════════════════════════════════════════╝${K_RESET}"

echo

# ==============================================================
# FOOTER
# ==============================================================

printf '%b\n' "${K_DIM}              ──────── TOM_TUNNEL • JOEL TOM ────────${K_RESET}"

if [ "$UPDATE_AVAILABLE" -eq 1 ]; then
    printf '%b\n' "${K_RED}              ⚡ UPDATE AVAILABLE → v${LATEST_VERSION}${K_RESET}"
else
    printf '%b\n' "${K_GREEN}              ✓ TOM_TUNNEL IS UP TO DATE${K_RESET}"
fi

echo

printf '%b' "${K_GREEN}╭─[ TOM_TUNNEL ]─[ SELECT OPTION ] » ${K_RESET}"
read -r opt
echo

# ==============================================================
# MENU ACTIONS
# ==============================================================

case "$opt" in

  1|01)
      clear
      /usr/local/sbin/ssh 2>/dev/null || bash "$(dirname "$0")/ssh.sh"
      ;;

  2|02)
      clear
      /usr/local/sbin/vmess 2>/dev/null || bash "$(dirname "$0")/vmess.sh"
      ;;

  3|03)
      clear
      /usr/local/sbin/vless 2>/dev/null || bash "$(dirname "$0")/vless.sh"
      ;;

  4|04)
      clear
      /usr/local/sbin/trojan 2>/dev/null || bash "$(dirname "$0")/trojan.sh"
      ;;

  5|05)
      clear
      /usr/local/sbin/socks 2>/dev/null || bash "$(dirname "$0")/socks.sh"
      ;;

  6|06)
      clear
      /usr/local/sbin/zivpn 2>/dev/null || bash "$(dirname "$0")/zivpn.sh"
      ;;

  7|07)
      clear
      /usr/local/sbin/dns 2>/dev/null || bash "$(dirname "$0")/dns.sh"
      ;;

  8|08)
      clear
      /usr/local/sbin/domain 2>/dev/null || bash "$(dirname "$0")/domain.sh"
      ;;

  9|09)
      clear
      /usr/local/sbin/iptools 2>/dev/null || bash "$(dirname "$0")/iptools.sh"
      ;;

  10)
      clear
      /usr/local/sbin/status 2>/dev/null || bash "$(dirname "$0")/status.sh"
      ;;

  11)
      clear
      /usr/local/sbin/netguard 2>/dev/null || bash "$(dirname "$0")/netguard.sh"
      ;;

  12)
      clear
      /usr/local/sbin/port 2>/dev/null || bash "$(dirname "$0")/port.sh"
      ;;

  13)
      clear
      /usr/local/sbin/log 2>/dev/null || bash "$(dirname "$0")/log.sh"
      ;;

  14)
      clear
      /usr/local/sbin/tgbot 2>/dev/null || bash "$(dirname "$0")/tgbot.sh"
      ;;

  15)
      clear
      /usr/local/sbin/uninstall 2>/dev/null || bash "$(dirname "$0")/uninstall.sh"
      ;;

  16)
      clear
      /usr/local/sbin/fastdns 2>/dev/null || bash "$(dirname "$0")/fastdns.sh"
      ;;

  18)
      clear
      /usr/local/sbin/web 2>/dev/null || bash "$(dirname "$0")/web.sh"
      ;;

  88|17)
      reboot
      ;;

  99)
      clear
      /usr/local/sbin/update 2>/dev/null || bash "$(dirname "$0")/update.sh"
      ;;

  0|00)
      exit 0
      ;;

  *)
      printf '%b\n' "${K_RED}╰─[ ERROR ] Invalid option.${K_RESET}"
      sleep 1
      ;;

esac

exec /usr/local/sbin/menu