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
wget https://github.com/traefik/traefik/releases/download/v2.5.5/traefik_v2.5.5_linux_armv6.tar.gz
tar -xvzf traefik_v2.5.5_linux_armv6.tar.gz
rm CHANGELOG.md LICENSE.md traefik_v2.5.5_linux_armv6.tar.gz
chmod +x traefik
mv traefik /usr/local/bin/

echo "#######################################"
echo ""
echo "Creating basic configuration file..."
echo ""
echo "#######################################"
echo ""

echo 'debug = false

#Uncomment below if you selfsigned backends
#insecureSkipVerify = true

logLevel = "ERROR"

defaultEntryPoints = ["https","http"]

[entryPoints]
# Redirect http to https
  [entryPoints.http]
  address = ":80"
    [entryPoints.http.redirect]
    entryPoint = "https"

# Define https
  [entryPoints.https]
  address = ":443"
  [entryPoints.https.tls]

[retry]
[api]

# This is for SSL certs auto-renewals
[acme]
  email = "you@email.com"
  storage = "/etc/traefik/acme.json"
  entryPoint = "https"
  onHostRule = true

[acme.httpChallenge]
  entryPoint = "http"

[file]

# definition of backend servers
[backends]
  # Plex Server
  [backends.plex]
    [backends.plex.servers.server1]
      url = "http://10.0.0.21"

# definition of frontend listeners  
[frontends]
    # Plex listens on URL plex.jlpc.dns.us
    [frontends.plex]
      backend = "plex"
      passHostHeader = true
    [frontends.plex.routes.server1]
      rule = "Host:plex.jlpc.dns1.us"' > /etc/traefik/traefik.toml;

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
