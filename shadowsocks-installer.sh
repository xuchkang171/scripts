#!/usr/bin/env bash
# Purpose: Install shadowsocks-libev and start it on boot
# Author: Frank
#
# Usage:
# curl -O https://raw.githubusercontent.com/xuchkang171/scripts/main/shadowsocks-installer.sh && chmod +x shadowsocks-installer.sh && ./shadowsocks-installer.sh
# --------------------------------------

if [ "$(whoami)" != 'root' ]
  then
    echo "You must be root to run this script."
    exit
fi

# 0 variables
ip=$(curl -4 ip.sb -s)
ss_config_path="/var/snap/shadowsocks-libev/common/etc/shadowsocks-libev/config.json"
ss_server_port=$(shuf -i 1024-65535 -n 1)
ss_password=$(openssl rand -base64 32)
ss_encryption="chacha20-ietf-poly1305"
ss_name="SS+UDP"

# 1 preparation
sudo apt update
sudo apt install snapd
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
    "encryption_method":$ss_encryption,
    "password":"$ss_password",
    "fast_open":false
}
EOF

# 4 set up firewall
sudo apt update && sudo apt install -y ufw
yes | sudo ufw reset
sudo ufw allow ssh
sudo ufw allow "$ss_server_port"/tcp
sudo ufw allow "$ss_server_port"/udp
yes | sudo ufw enable

# 5 start and turn on start on boot
sudo systemctl start snap.shadowsocks-libev.ss-server-daemon.service
sudo systemctl enable snap.shadowsocks-libev.ss-server-daemon.service

# 6 ss > show config in json
echo ""
echo "config.json ($ss_config_path):"
cat $ss_config_path
echo ""

# 6 ss > show config in Surge
echo "[Proxy] in Surge"
echo "$ss_name = ss, $ip, $ss_server_port, encrypt-method=$ss_encryption, password=$ss_password, udp-relay=true"
echo ""

# 6 ss > show config in URI
# URI Format:
#   ss://method:password@hostname:port
URI="ss://"$(echo "$ss_encryption:$ss_password@$ip:$ss_server_port" | base64)
echo "${URI}#${(urlencode($ss_name) | base64)}"
echo ""

echo "👌"
echo ""
systemctl status snap.shadowsocks-libev.ss-server-daemon.service

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