# node_exporter-1.0.1-installer.sh
`root` is needed to run this script. It'll install node_exporter and start it on boot, listen on `:9100`. 
1. get node_exporter-1.0.1 to /usr/local/bin/node_exporter
2. sudo useradd -rs /bin/false node_exporter
3. make node_exporter start on boot with systemd unit

Tested on: Ubuntu 16.04, Ubuntu 18.04, CentOS 7, Debian 9.

Usage:
> curl -O https://raw.githubusercontent.com/xuchkang171/scripts/main/node_exporter-1.0.1-installer.sh && chmod +x node_exporter-1.0.1-installer.sh && ./node_exporter-1.0.1-installer.sh

# install-shadowsocks-on-brand-new-oracle.sh
`root` is needed to run this script. It'll install shadowsocks-libev and start it on boot. 
1. install `shadowsocks-libev` w/ snap
2. set up `ufw` to allow only port of `shadowsocks-libev` and `ssh`
3. show you the ss config in json and Surge

Tested on: Ubuntu 20.04

Usage:
> curl https://raw.githubusercontent.com/xuchkang171/scripts/main/install-shadowsocks-on-brand-new-oracle.sh --output ss.sh && chmod +x ./ss.sh && ./ss.sh
