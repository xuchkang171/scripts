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
ss_config_path="/var/snap/shadowsocks-libev/common/etc/shadowsocks-libev/config.json"
ss_server_port=$(shuf -i 1024-65535 -n 1)
ss_password=$(openssl rand -base64 32)

# 1 preparation
sudo apt update
sudo apt install snapd
sudo snap install core

# 2 ss > download 
sudo snap install shadowsocks-libev --edge

# 3 ss > config
bash -c "cat > $ss_config_path" << EOF
{
    "server":["0.0.0.0"],
    "server_port":$ss_server_port,
    "encryption_method":"chacha20-ietf-poly1305",
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

# 6 ss > show config
echo "$ss_config_path:"
cat $ss_config_path
echo ""
echo "[Proxy] // in Surge"
echo "SS+UDP = ss, $(curl ip.sb -s), $ss_server_port, encrypt-method=chacha20-ietf-poly1305, password=$ss_password, udp-relay=true"

echo -e "\n👌"
