UI="/usr/local/lib/tom_tunnel-ui.sh"; [ -f "$UI" ] && source "$UI"
[ -f "$UI" ] && k_header "TOM_TUNNEL • SETUP_DNS" || clear

export LN='\033[34m'
export BG='\033[44m'
export NC='\033[0m'
export GR='\033[32m'
export RD='\033[31m'

echo "Please Wait ... Installing required packages"

REQUIRED_PACKAGES=(
    curl wget dnsutils git screen whois pwgen python3 jq fail2ban sudo
    gnutls-bin mlocate dh-make libaudit-dev build-essential dos2unix debconf-utils
)

for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg-query -W --showformat='${Status}\n' "$package" 2>/dev/null | grep -q "install ok installed"; then
        apt-get -qq install "$package" -y &>/dev/null
    fi
done

clear
echo "Installing Go (golang)..."

# Nettoyage propre
rm -rf /usr/local/go /usr/bin/go /root/go1.22.0.linux-amd64.tar.gz

# Téléchargement + extraction
cd /root || exit 1
wget -q --timeout=30 --tries=3 https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -O /root/go1.22.0.linux-amd64.tar.gz || {
    echo -e "\( {RD}[ERROR] Impossible de télécharger Go \){NC}"
    exit 1
}

tar -C /usr/local -xzf /root/go1.22.0.linux-amd64.tar.gz
rm -f /root/go1.22.0.linux-amd64.tar.gz

# PATH correct (sans /rere)
export PATH="/usr/local/go/bin:$PATH"
echo 'export PATH="/usr/local/go/bin:$PATH"' >> /root/.bashrc

# Vérification
if ! command -v go &>/dev/null; then
    echo -e "\( {RD}[ERROR] Go n'est pas installé correctement \){NC}"
    exit 1
fi
go version

install_slowdns() {
    cd /root || exit 1
    rm -rf /etc/slowdns /root/dnstt

    echo "[*] Cloning dnstt..."
    git clone https://www.bamsoftware.com/git/dnstt.git || {
        echo -e "\( {RD}[ERROR] Impossible de cloner dnstt \){NC}"
        exit 1
    }

    cd dnstt/dnstt-server || exit 1
    rm -f go.sum
    go mod tidy
    go build -o dnstt-server || {
        echo -e "\( {RD}[ERROR] Échec de la compilation de dnstt-server \){NC}"
        exit 1
    }

    mkdir -p /etc/slowdns
    mv dnstt-server /etc/slowdns/dns-server
    chmod +x /etc/slowdns/dns-server

    # Génération des clés
    /etc/slowdns/dns-server -gen-key \
        -privkey-file /etc/slowdns/server.key \
        -pubkey-file /etc/slowdns/server.pub

    clear
    echo -e "\( {LN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ \){NC}"
    echo -e "\( {LN}┃ \){NC} ${BG}                 DOMAIN PANEL                   ${NC} \( {LN}┃ \){NC}"
    echo -e "\( {LN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ \){NC}"
    echo -e "\( {LN}●━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━● \){NC}"
    echo

    while true; do
        if [ -r /dev/tty ]; then
            read -r -p "  NS Domain : " -e Nameserver </dev/tty
        else
            read -r -p "  NS Domain : " -e Nameserver
        fi

        if [[ -z "$Nameserver" ]]; then
            echo -e "\( {RD}NS Domain cannot be empty. Please enter a value. \){NC}"
        else
            break
        fi
    done

    echo "$Nameserver" > /etc/slowdns/nsdomain

    # Arrêt propre de l'ancien service
    systemctl stop dnstt 2>/dev/null || true
    pkill -f dns-server 2>/dev/null || true
    rm -f /etc/systemd/system/dnstt.service

    # Création du service systemd
    cat > /etc/systemd/system/dnstt.service <<END
[Unit]
Description=SlowDNS Service (dnstt)
Documentation=https://www.bamsoftware.com/software/dnstt/
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/dns-server -udp :5300 -privkey-file /etc/slowdns/server.key $Nameserver 127.0.0.1:22
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
END

    systemctl daemon-reload
    systemctl enable dnstt
    systemctl start dnstt

    # Vérification du service
    sleep 2
    if systemctl is-active --quiet dnstt; then
        echo -e "\( {GR}[✔] Service dnstt démarré avec succès \){NC}"
    else
        echo -e "\( {RD}[✘] Échec du démarrage de dnstt \){NC}"
        systemctl status dnstt --no-pager
    fi

    # Autoriser le forwarding TCP
    sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/' /etc/ssh/sshd_config
    systemctl restart ssh
}

install_firewall() {
    local interface
    interface=$(ip route get 8.8.8.8 2>/dev/null | awk '/dev/ {print $5; exit}')

    if [[ -z "$interface" ]]; then
        echo -e "\( {RD}[ERROR] Impossible de détecter l'interface réseau \){NC}"
        return 1
    fi

    echo "[*] Configuration du firewall (interface: $interface)"

    iptables -I INPUT -p udp --dport 5300 -j ACCEPT &>/dev/null
    iptables -t nat -I PREROUTING -i "$interface" -p udp --dport 53 -j REDIRECT --to-ports 5300

    iptables-save > /etc/iptables.up.rules
    iptables-restore < /etc/iptables.up.rules

    if command -v netfilter-persistent &>/dev/null; then
        netfilter-persistent save
        netfilter-persistent reload
    fi
}

# --- Exécution ---
install_slowdns
install_firewall

echo ""
rm -rf /root/dnstt
echo -e "\( {GR} SlowDNS Autoscript installation completed! \){NC}"
echo ""
echo -e "Nameserver : $(cat /etc/slowdns/nsdomain 2>/dev/null)"
echo -e "Public Key : $(cat /etc/slowdns/server.pub 2>/dev/null)"
echo ""