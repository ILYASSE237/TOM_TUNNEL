#!/bin/bash
UI="/usr/local/lib/tom_tunnel-ui.sh"; [ -f "$UI" ] && source "$UI"
[ -f "$UI" ] && k_header "TOM_TUNNEL • UNINSTALL" || clear
printf '%b\n' "${K_RED}╭────────────────────────────────────────────────────────────────╮"
printf '%b\n' "│  DÉSINSTALLATION COMPLÈTE — TOM_TUNNEL                     │"
printf '%b\n' "╰────────────────────────────────────────────────────────────────╯${K_RESET}"
printf '%b\n' "${K_YELLOW}⚠ Cette opération supprime les composants installés par TOM_TUNNEL.${K_RESET}"
printf '%b\n' "${K_YELLOW}⚠ Elle ne supprime pas OpenSSH ni les fichiers personnels non liés.${K_RESET}"
printf '%b\n' "${K_YELLOW}⚠ Les comptes VPN et données TOM_TUNNEL seront perdus.${K_RESET}"
read -r -p " Confirmer la purge complète ? (y/N) : " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { k_info "Désinstallation annulée."; exit 0; }

mkdir -p /var/log/tom_tunnel
exec > >(tee -a /var/log/tom_tunnel/uninstall.log) 2>&1

stop_disable(){
  local s
  for s in "$@"; do systemctl stop "$s" 2>/dev/null || true; systemctl disable "$s" 2>/dev/null || true; done
}

k_spinner "Arrêt des services TOM_TUNNEL" 8
stop_disable xray zivpn tom_tunnel_bot tom_tunnel-web dropbear stunnel5 ws-dropbear ws-stunnel sshws sshwsssl hysteria-server tuic-server dnstt udp-custom ohp squid nginx

pkill -f '/usr/local/sbin/proxy3.js' 2>/dev/null || true
pkill -f 'proxy3.js' 2>/dev/null || true
tmux kill-session -t sshws 2>/dev/null || true
tmux kill-session -t sshwsssl 2>/dev/null || true

k_spinner "Suppression des unités systemd et tâches automatiques" 8
rm -f /etc/systemd/system/tom_tunnel* /etc/systemd/system/xray* /etc/systemd/system/tuic-server.service /etc/systemd/system/hysteria-server.service /etc/systemd/system/dnstt.service
rm -f /etc/systemd/system/ws-dropbear.service /etc/systemd/system/ws-stunnel.service /etc/systemd/system/stunnel5.service /etc/systemd/system/udp-custom.service
rm -f /etc/cron.d/tom_tunnel* /etc/cron.d/tom_tunnel-web-watchdog
rm -f /usr/local/bin/tom_tunnel-web-watchdog.sh /usr/local/sbin/tom_tunnel* /usr/local/sbin/proxy3.js
systemctl daemon-reload
systemctl reset-failed

k_spinner "Suppression des données TOM_TUNNEL" 8
rm -rf /etc/tom_tunnel /etc/tom_tunnel_bot /etc/tom_tunnel-vpn-web /etc/xray /etc/zivpn /etc/slowdns /etc/tuic /etc/hysteria
rm -rf /opt/tom_tunnel /opt/TOM_TUNNEL /opt/tom_tunnel-vpn-web /root/tom_tunnel_core_bot /root/tom_tunnel_bot_engine
rm -f /root/tom_tunnel.sh /root/domain
rm -rf /root/.acme.sh
rm -f /etc/systemd/system/multi-user.target.wants/tom_tunnel_bot.service

k_spinner "Nettoyage Nginx / certificats TOM_TUNNEL" 8
rm -f /etc/nginx/sites-enabled/tom_tunnel /etc/nginx/sites-available/tom_tunnel
rm -f /etc/nginx/conf.d/tom_tunnel.conf
rm -rf /etc/letsencrypt
nginx -t >/dev/null 2>&1 || true

k_spinner "Nettoyage des fichiers temporaires" 6
rm -f /tmp/tom_tunnel-* /tmp/TOM_TUNNEL-* /tmp/tom_tunnel-update.*
rm -rf /usr/local/lib/tom_tunnel-core /usr/local/lib/tom_tunnel-ui.sh

k_ok "Désinstallation TOM_TUNNEL terminée."
printf '%b\n' "${K_GREEN}Ports 80/443 restitués aux services restants du VPS.${K_RESET}"
printf '%b\n' "${K_CYAN}Journal de cette purge : /var/log/tom_tunnel/uninstall.log${K_RESET}"
rm -f /usr/local/sbin/menu /usr/local/sbin/update /usr/local/sbin/uninstall
exit 0
