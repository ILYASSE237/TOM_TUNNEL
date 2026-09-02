#!/bin/bash
# ============================================================
# TOM_TUNNEL — Main Menu
# Style: Premium Multi-Protocol VPS Control
# ============================================================

UI="/usr/local/lib/tom_tunnel-ui.sh"
[ -f "$UI" ] && source "$UI"

# ------------------------------------------------------------
# COLORS — fallback if UI is not loaded
# ------------------------------------------------------------
K_GREEN="${K_GREEN:-\033[0;32m}"
K_RED="${K_RED:-\033[1;31m}"
K_CYAN="${K_CYAN:-\033[0;36m}"
K_YELLOW="${K_YELLOW:-\033[1;33m}"
K_WHITE="${K_WHITE:-\033[1;37m}"
K_MAGENTA="${K_MAGENTA:-\033[1;35m}"
K_DIM="${K_DIM:-\033[2m}"
K_RESET="${K_RESET:-\033[0m}"

# ------------------------------------------------------------
# SERVER INFORMATION
# ------------------------------------------------------------
MYIP="$(curl -4fsS --max-time 5 https://ipv4.icanhazip.com 2>/dev/null \
  || hostname -I 2>/dev/null | awk '{print $1}')"

IPV6="$(curl -6fsS --max-time 5 https://ipv6.icanhazip.com 2>/dev/null \
  || ip -6 addr show scope global 2>/dev/null \
  | awk '/inet6/{print $2}' | head -1 | cut -d/ -f1)"

DOMAIN="$(cat /etc/xray/domain 2>/dev/null || echo "N/A")"

UPTIME="$(uptime -p 2>/dev/null || echo "N/A")"

VERSION_FILE="/etc/version"
INSTALLED_VERSION="$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")"

readonly SERVER_HOST="https://raw.githubusercontent.com/ILYASSSE237/TOM_TUNNEL/main"

LATEST_VERSION="$(curl -fsS --max-time 4 \
  "$SERVER_HOST/version" 2>/dev/null || echo "$INSTALLED_VERSION")"

UPDATE_AVAILABLE=0

version_greater() {
    [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n1)" = "$1" ] \
    && [ "$1" != "$2" ]
}

version_greater "$LATEST_VERSION" "$INSTALLED_VERSION" \
  && UPDATE_AVAILABLE=1

# ------------------------------------------------------------
# OPERATING SYSTEM
# ------------------------------------------------------------
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME="${PRETTY_NAME:-$NAME}"
else
    OS_NAME="$(uname -s)"
fi

# ------------------------------------------------------------
# SERVICE CHECK
# ------------------------------------------------------------
svc() {
    systemctl is-active --quiet "$1" 2>/dev/null
}

mark() {
    if svc "$1"; then
        printf '%b' "${K_GREEN}● ON${K_RESET}"
    else
        printf '%b' "${K_RED}○ OFF${K_RESET}"
    fi
}

# ------------------------------------------------------------
# MODULE RUNNER
# ------------------------------------------------------------
run_menu() {
    local cmd="$1"
    local script=""

    clear

    case "$cmd" in
        ssh)       script="ssh.sh" ;;
        vmess)     script="vmess.sh" ;;
        vless)     script="vless.sh" ;;
        trojan)    script="trojan.sh" ;;
        socks)     script="socks.sh" ;;
        zivpn)     script="zivpn.sh" ;;
        dns)       script="dns.sh" ;;
        domain)    script="domain.sh" ;;
        iptools)   script="iptools.sh" ;;
        status)    script="status.sh" ;;
        netguard)  script="netguard.sh" ;;
        port)      script="port.sh" ;;
        log)       script="log.sh" ;;
        tgbot)     script="tgbot.sh" ;;
        uninstall) script="uninstall.sh" ;;
        fastdns)   script="fastdns.sh" ;;
        web)       script="web.sh" ;;
        update)    script="update.sh" ;;
        *)         script="${cmd}.sh" ;;
    esac

    # First priority: installed module
    if [ -x "/usr/local/sbin/$cmd" ]; then
        "/usr/local/sbin/$cmd"
        return
    fi

    # Second priority: installed module even if not executable
    if [ -f "/usr/local/sbin/$cmd" ]; then
        bash "/usr/local/sbin/$cmd"
        return
    fi

    # Third priority: script located beside menu
    if [ -f "$(dirname "$0")/$script" ]; then
        bash "$(dirname "$0")/$script"
        return
    fi

    printf '%b\n' "${K_RED}✘ Module $cmd introuvable.${K_RESET}"
    sleep 2
}

# ------------------------------------------------------------
# BRAND
# ------------------------------------------------------------
clear

if [ -f "$UI" ] && declare -F k_brand >/dev/null 2>&1; then
    k_brand
fi

# ------------------------------------------------------------
# SERVER HEADER
# ------------------------------------------------------------
printf '%b\n' "${K_CYAN}╭────────────────────────────────────────────────────────────────╮"
printf '%b\n' "│ ${K_WHITE}🖥️  VPS${K_RESET}      : ${K_CYAN}${OS_NAME}${K_RESET}"
printf '%b\n' "│ ${K_WHITE}🌐 IPv4${K_RESET}     : ${K_CYAN}${MYIP:-N/A}${K_RESET}"
printf '%b\n' "│ ${K_WHITE}🌍 IPv6${K_RESET}     : ${K_CYAN}${IPV6:-N/A}${K_RESET}"
printf '%b\n' "│ ${K_WHITE}🔗 DOMAIN${K_RESET}   : ${K_CYAN}${DOMAIN}${K_RESET}"
printf '%b\n' "│ ${K_WHITE}⏱️  UPTIME${K_RESET}   : ${K_CYAN}${UPTIME:-N/A}${K_RESET}"
printf '%b\n' "│ ${K_WHITE}📦 VERSION${K_RESET}  : ${K_CYAN}${INSTALLED_VERSION}${K_RESET}"
printf '%b\n' "│ ${K_WHITE}⚡ SERVICES${K_RESET} : Xray $(mark xray)  •  Nginx $(mark nginx)  •  SSH $(mark ssh)"
printf '%b\n' "${K_CYAN}╰────────────────────────────────────────────────────────────────╯${K_RESET}"

# ------------------------------------------------------------
# PROTOCOLS
# ------------------------------------------------------------
printf '%b\n' "${K_MAGENTA}┏━━━━━━━━━━━━━━━━━━ 🚀 PROTOCOLS TOM_TUNNEL ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${K_RESET}"
printf '%b\n' "${K_CYAN}┃ [01] 🔐 SSH/WS MENU       [02] 🌐 VMESS MENU                 ┃${K_RESET}"
printf '%b\n' "${K_CYAN}┃ [03] 🛡️  VLESS MENU        [04] 🔥 TROJAN MENU                ┃${K_RESET}"
printf '%b\n' "${K_CYAN}┃ [05] 🧦 SOCKS MENU        [06] ⚡ ZIVPN MENU                 ┃${K_RESET}"
printf '%b\n' "${K_MAGENTA}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${K_RESET}"

# ------------------------------------------------------------
# TOOLS
# ------------------------------------------------------------
printf '%b\n' "${K_YELLOW}┏━━━━━━━━━━━━━━━━━━ 🛠️  TOOLS TOM_TUNNEL ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${K_RESET}"
printf '%b\n' "${K_YELLOW}┃ [07] 📡 DNS PANEL         [08] 🌐 DOMAIN PANEL              ┃${K_RESET}"
printf '%b\n' "${K_YELLOW}┃ [09] 6️⃣  IPV6 PANEL        [10] 📊 VPS STATUS                ┃${K_RESET}"
printf '%b\n' "${K_YELLOW}┃ [11] 🛡️  NETGUARD PANEL    [12] 🔌 VPN PORT INFO             ┃${K_RESET}"
printf '%b\n' "${K_YELLOW}┃ [13] 🧹 CLEAN VPS LOGS    [14] 🤖 TOM_TUNNEL BOT PANEL      ┃${K_RESET}"
printf '%b\n' "${K_YELLOW}┃ [15] 🗑️  UNINSTALL TOM_TUNNEL [16] ⚡ FAST DNS MENU          ┃${K_RESET}"
printf '%b\n' "${K_YELLOW}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${K_RESET}"

# ------------------------------------------------------------
# WEB PANEL
# ------------------------------------------------------------
printf '%b\n' "${K_GREEN}┏━━━━━━━━━━━━━━━━ 🖥️  WEB PANEL TOM_TUNNEL ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${K_RESET}"
printf '%b\n' "${K_GREEN}┃ [18] 🌍 TOM_TUNNEL TUNNEL WEB   $(mark tom_tunnel-web)       ┃${K_RESET}"
printf '%b\n' "${K_GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${K_RESET}"

# ------------------------------------------------------------
# SYSTEM
# ------------------------------------------------------------
printf '%b\n' "${K_RED}┏━━━━━━━━━━━━━━━━━━ ⚙️  SYSTEM TOM_TUNNEL ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${K_RESET}"
printf '%b\n' "${K_RED}┃ [88] 🔄 REBOOT VPS          [99] 🔁 UPDATE SCRIPT            ┃${K_RESET}"
printf '%b\n' "${K_RED}┃ [00] 🚪 EXIT                                                  ┃${K_RESET}"
printf '%b\n' "${K_RED}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${K_RESET}"

printf '%b\n' "${K_DIM}TOM_TUNNEL • Premium Multi-Protocol VPS Control${K_RESET}"

# ------------------------------------------------------------
# UPDATE NOTIFICATION
# ------------------------------------------------------------
if [ "$UPDATE_AVAILABLE" -eq 1 ]; then
    printf '%b\n' "${K_RED}⚡ UPDATE AVAILABLE : v${LATEST_VERSION}${K_RESET}"
fi

# ------------------------------------------------------------
# MENU INPUT
# ------------------------------------------------------------
read -r -p " ${K_GREEN}➜ Sélection : ${K_RESET}" opt

# ------------------------------------------------------------
# MENU ACTIONS
# ------------------------------------------------------------
case "$opt" in

    1|01)
        run_menu ssh
        ;;

    2|02)
        run_menu vmess
        ;;

    3|03)
        run_menu vless
        ;;

    4|04)
        run_menu trojan
        ;;

    5|05)
        run_menu socks
        ;;

    6|06)
        run_menu zivpn
        ;;

    7|07)
        run_menu dns
        ;;

    8|08)
        run_menu domain
        ;;

    9|09)
        run_menu iptools
        ;;

    10)
        run_menu status
        ;;

    11)
        run_menu netguard
        ;;

    12)
        run_menu port
        ;;

    13)
        run_menu log
        ;;

    14)
        run_menu tgbot
        ;;

    15)
        run_menu uninstall
        ;;

    16)
        run_menu fastdns
        ;;

    18)
        run_menu web
        ;;

    88|17)
        reboot
        ;;

    99)
        run_menu update
        ;;

    0|00)
        exit 0
        ;;

    *)
        printf '%b\n' "${K_RED}✘ Option invalide. Utilisez uniquement les numéros affichés.${K_RESET}"
        sleep 1
        ;;
esac

# ------------------------------------------------------------
# RETURN TO MAIN MENU
# ------------------------------------------------------------
exec /usr/local/sbin/menu