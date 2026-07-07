#!/bin/bash
# ==============================================================================
# WSL DOCKER NATIVE SETUP SCRIPT (Ubuntu/Debian)
# ==============================================================================

set -e # Bricht bei Fehlern sofort ab

echo "=== 1. Update & Pakete installieren ==="
sudo apt-get update
sudo apt-get install -y ca-certificates curl jq

echo "=== 2. Docker Repository hinzufügen ==="
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

echo "=== 3. Docker Engine installieren ==="
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== 4. Benutzergruppe einrichten ==="
sudo usermod -aG docker $USER

echo "=== 5. /etc/wsl.conf konfigurieren ==="
sudo tee /etc/wsl.conf > /dev/null <<EOF
[boot]
systemd=true

[automount]
root = /
options = "metadata"
EOF

echo "=== 6. Docker Daemon TCP-Port konfigurieren (daemon.json) ==="
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "hosts": [
    "unix:///var/run/docker.sock",
    "tcp://0.0.0.0:2375"
  ]
}
EOF

echo "=== 7. Systemd Override für Konfliktvermeidung erstellen ==="
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/override.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
EOF

echo "=== 8. Sudoers für passwortlosen Start freischalten ==="
# Wir schreiben eine separate Datei in sudoers.d, das überschreibt visudo sicher
SUDOERS_LINE="$USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl start docker, /usr/bin/systemctl stop docker, /usr/bin/systemctl restart docker, /usr/bin/systemctl stop docker.socket"
echo "$SUDOERS_LINE" | sudo tee /etc/sudoers.d/docker-autostart > /dev/null
sudo chmod 0440 /etc/sudoers.d/docker-autostart

echo "=== 9. Systemd neu laden und aktivieren ==="
sudo systemctl daemon-reload
sudo systemctl enable docker

echo "=============================================================================="
echo " FERTIG! Bitte schließe dieses WSL-Fenster und starte WSL neu mit:"
echo " powershell: wsl --shutdown"
echo "=============================================================================="
