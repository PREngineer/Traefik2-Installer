#!/bin/bash

echo "#######################################"
echo ""
echo "Grabbing operating system details..."
echo ""
echo "#######################################"
echo ""
sudo apt-get update --allow-releaseinfo-change -y

echo "#######################################"
echo ""
echo "Updating operating system..."
echo ""
echo "#######################################"
echo ""
sudo apt-get upgrade -y

echo "#######################################"
echo ""
echo "Setting up directories..."
echo ""
echo "#######################################"
echo ""
mkdir /etc/traefik
touch /etc/traefik/traefik.toml
touch /etc/traefik/acme.json
chmod 0600 /etc/traefik/acme.json

echo "#######################################"
echo ""
echo "Grabbing Traefik binaries from GitHub..."
echo ""
echo "#######################################"
echo ""
wget https://github.com/traefik/traefik/releases/download/v2.5.6/traefik_v2.5.6_linux_armv6.tar.gz
tar -xvzf traefik_v2.5.6_linux_armv6.tar.gz
rm CHANGELOG.md LICENSE.md traefik_v2.5.6_linux_armv6.tar.gz
chmod +x traefik
mv traefik /usr/local/bin/

echo "#######################################"
echo ""
echo "Creating Static configuration file..."
echo ""
echo "#######################################"
echo ""

echo '' > /etc/traefik/traefik.yaml

echo "#######################################"
echo ""
echo "Creating Dynamic configuration file..."
echo ""
echo "#######################################"
echo ""

echo '' > /etc/traefik/traefik-dynamic.yaml

echo "#######################################"
echo ""
echo "Setting up as a service..."
echo ""
echo "#######################################"
echo ""
echo '[Unit]
Description=Traefik
Documentation=https://docs.traefik.io
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/traefik
AssertPathExists=/etc/traefik
[Service]
Type=notify
ExecStart=/usr/local/bin/traefik -c /etc/traefik/traefik.toml
Restart=always
WatchdogSec=1s
ProtectSystem=strict
ReadWritePaths=/etc/traefik/acme.json
ReadOnlyPaths=/etc/traefik/traefik.toml
PrivateTmp=true
ProtectHome=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectControlGroups=true
LimitNPROC=1
[Install]
WantedBy=multi-user.target' > /etc/systemd/system/traefik.service;

echo "########################################################"
echo ""
echo "Enabling Traefik v2 service..."
echo ""
echo "########################################################"
systemctl daemon-reload
systemctl enable traefik.service
systemctl start traefik.service
