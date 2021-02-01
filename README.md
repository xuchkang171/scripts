# What
##  node_exporter-1.0.1.sh
Install node_exporter and start it on boot
1. get node_exporter-1.0.1 to /usr/local/bin/node_exporter
2. sudo useradd -rs /bin/false node_exporter
3. make node_exporter start on boot with systemd unit

Usage:
> curl -O https://raw.githubusercontent.com/xuchkang171/scripts/main/node_exporter-1.0.1.sh && chmod +x node_exporter-1.0.1.sh && ./node_exporter-1.0.1.sh
