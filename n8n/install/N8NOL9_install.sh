#!/usr/bin/env bash

#
# Native n8n installation script for Oracle Linux 9
# This script installs Node.js, n8n, creates a system user,
# configures systemd, and opens the firewall port.
#

# -------------------------------------------------------------------
# Update the system and install basic utilities
# -------------------------------------------------------------------

sudo dnf update -y
dnf install -y curl git wget

# -------------------------------------------------------------------
# Enable Node.js module and install Node.js
# -------------------------------------------------------------------

sudo dnf module enable nodejs:24 -y
sudo dnf install -y nodejs

# Install n8n globally via npm
sudo npm install -g n8n

# -------------------------------------------------------------------
# Create dedicated n8n user and data directory
# -------------------------------------------------------------------

sudo useradd -m -s /bin/bash n8n
sudo mkdir -p /home/n8n/.n8n
sudo chown -R n8n:n8n /home/n8n/.n8n

# -------------------------------------------------------------------
# Create systemd service for n8n
# -------------------------------------------------------------------

sudo tee /etc/systemd/system/n8n.service > /dev/null <<'EOF'
[Unit]
Description=n8n Workflow Automation
After=network.target

[Service]
Type=simple
User=n8n
Environment="HOME=/home/n8n"
Environment="N8N_SECURE_COOKIE=false"
# Add these two lines:
Environment="N8N_HOST=0.0.0.0"
Environment="N8N_PROTOCOL=http"
ExecStart=/usr/local/bin/n8n
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# -------------------------------------------------------------------
# Reload systemd and enable n8n service
# -------------------------------------------------------------------

sudo systemctl daemon-reload
sudo systemctl enable --now n8n

# -------------------------------------------------------------------
# Open firewall port for n8n web interface
# -------------------------------------------------------------------

sudo firewall-cmd --zone=public --add-port=5678/tcp --permanent
sudo firewall-cmd --reload
