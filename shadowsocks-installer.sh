#!/bin/bash
# Purpose: Install shadowsocks-libev and start it on boot
# Author: Frank
# Reference: https://gfw.report/blog/ss_tutorial/zh/
# Usage: curl -O https://raw.githubusercontent.com/xuchkang171/scripts/main/shadowsocks-installer.sh && chmod +x shadowsocks-installer.sh && ./shadowsocks-installer.sh
# --------------------------------------

urlencode() {
    # urlencode <string>

    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

if [ "$(whoami)" != 'root' ]
  then
    echo "You must be root to run this script."
    exit
fi

# 0 variables
GREEN='\033[1;32m'
NC='\033[0m' # No Color
ip=$(curl -4 ip.sb -s)
ss_config_path="/var/snap/shadowsocks-libev/common/etc/shadowsocks-libev/config.json"
ss_server_port=$(shuf -i 1024-65535 -n 1)
ss_password=$(openssl rand -base64 32)
ss_encryption="chacha20-ietf-poly1305"
ss_name="$(date '+%Y%m%d') SS+UDP"

# 1 preparation
sudo apt update
sudo apt install -y snapd
sudo snap install core

# stop and disable ss if running
systemctl stop snap.shadowsocks-libev.ss-server-daemon.service
systemctl disable snap.shadowsocks-libev.ss-server-daemon.service

# 2 ss > download 
sudo snap install shadowsocks-libev --edge

# 3 ss > config
bash -c "cat > $ss_config_path" << EOF
{
    "server":["0.0.0.0"],
    "server_port":$ss_server_port,
    "encryption_method":"$ss_encryption",
    "password":"$ss_password",
    "fast_open":false
}
EOF

# 4 set up firewall
sudo apt install -y ufw
yes | sudo ufw reset
sudo ufw allow ssh
sudo ufw allow "$ss_server_port"/tcp
sudo ufw allow "$ss_server_port"/udp
yes | sudo ufw enable
ufw status

# 5 start and turn on start on boot
sudo systemctl start snap.shadowsocks-libev.ss-server-daemon.service
sudo systemctl enable snap.shadowsocks-libev.ss-server-daemon.service

# 6 ss > show config in json
echo ""
echo -e "config.${GREEN}json${NC} ($ss_config_path):"
cat $ss_config_path
echo ""

# 6 ss > show config in URI
# URI Format:
#   ss://method:password@hostname:port
echo -e "${GREEN}URI${NC} Scheme:"
URI="ss://"$(echo "$ss_encryption:$ss_password@$ip:$ss_server_port" | base64 -w 0)
URI="${URI}#$(urlencode "$ss_name")"
echo "$URI"
echo ""

# 6 ss > show config in Surge
echo -e "[Proxy] in ${GREEN}Surge${NC}:"
echo "$ss_name = ss, $ip, $ss_server_port, encrypt-method=$ss_encryption, password=$ss_password, udp-relay=true"
echo ""

# 6 ss > show config for Clash
echo -e "${GREEN}Clash${NC} Subscription Link:"
echo "https://sub.id9.cc/sub?target=clash&url=$(urlencode "$URI")&insert=false&config=%E5%93%81%E4%BA%91%E4%B8%93%E5%B1%9E%E9%85%8D%E7%BD%AE&emoji=true&list=false&udp=true&tfo=false&scv=false&fdn=false&sort=false&new_name=true"
echo ""

echo "👌"
echo ""
systemctl status snap.shadowsocks-libev.ss-server-daemon.service