# node_exporter-1.0.1-installer.sh
Install node_exporter and start it on boot. root needed.
1. get node_exporter-1.0.1 to /usr/local/bin/node_exporter
2. sudo useradd -rs /bin/false node_exporter
3. make node_exporter start on boot with systemd unit

Tested on: Ubuntu 18.04, CentOS 7, Debian 9.

Usage:
> curl -O https://raw.githubusercontent.com/xuchkang171/scripts/main/node_exporter-1.0.1-installer.sh && chmod +x node_exporter-1.0.1-installer.sh && ./node_exporter-1.0.1-installer.sh
