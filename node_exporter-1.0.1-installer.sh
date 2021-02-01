#!/usr/bin/env bash
# Purpose: Install node_exporter and start it on boot
#          * get node_exporter-1.0.1 to /usr/local/bin/node_exporter
#          * sudo useradd -rs /bin/false node_exporter
#          * make node_exporter start on boot with systemd unit
# Author: Frank
# --------------------------------------

# 1
echo "Downloading node_exporter-1.0.1 ..."
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar -xf node_exporter-1.0.1.linux-amd64.tar.gz
mv node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin
rm -r node_exporter-1.0.1.linux-amd64*
echo "Downloading node_exporter-1.0.1 to /usr/local/bin ... done"

# 2
useradd -rs /bin/false node_exporter
echo "useradd node_exporter ... done"

# 3
echo "Writing: /etc/systemd/system/node_exporter.service ..."
bash -c "cat > /etc/systemd/system/node_exporter.service" << EOL
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL
echo "Writing: /etc/systemd/system/node_exporter.service ... done"

# 4
echo "Make node_exporter start on boot ..."
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
echo "Make node_exporter start on boot ... done"

echo "👌"
