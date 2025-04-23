#!/bin/bash

# Set the OwlH repository and installation directory
REPO_URL="http://repo.owlh.net/current-debian"
INSTALL_DIR="/tmp/owlhinstaller"
CONFIG_FILE="${INSTALL_DIR}/config.json"

# Install dependencies
echo "Updating package lists and installing dependencies..."
apt-get update
apt-get install -y wget curl unzip sudo apache2 libpcap-dev dbus python3-pip python3-setuptools

# Download and extract the OwlH installer
cd /tmp
wget "${REPO_URL}/owlhinstaller.tar.gz" -O owlhinstaller.tar.gz
mkdir -p "$INSTALL_DIR"
tar -C "$INSTALL_DIR" -xf owlhinstaller.tar.gz

# Configure the installer
echo "Configuring the installation..."
cat > "$CONFIG_FILE" <<EOF
{
    "action": "install",
    "repourl": "${REPO_URL}",
    "target": ["owlhmaster", "owlhnode", "owlhui"],
    "tmpfolder": "/tmp/"
}
EOF

# Run the OwlH installer
echo "Running the OwlH installer..."
cd "$INSTALL_DIR"
./owlhinstaller

# Install and configure Apache for the OwlH UI
echo "Setting up Apache for OwlH UI..."
wget "${REPO_URL}/services/owlhui-httpd.sh" -O owlhui-httpd.sh
bash owlhui-httpd.sh 127.0.0.1

# Install Suricata
echo "Installing Suricata..."
wget "${REPO_URL}/services/owlhsuricata.sh" -O owlhsuricata.sh
bash owlhsuricata.sh

# Install Zeek
echo "Installing Zeek..."
wget "${REPO_URL}/services/owlhzeek.sh" -O owlhzeek.sh
bash owlhzeek.sh

# Install the OwlH interface
echo "Installing the OwlH interface..."
wget "${REPO_URL}/services/owlhinterface.sh" -O owlhinterface.sh
bash owlhinterface.sh

# Configure the firewall
echo "Configuring the firewall..."
ufw allow 50001/tcp
ufw allow 50010:50020/tcp
ufw allow 8005/tcp
ufw reload

echo "OwlH AIO installation completed successfully."
