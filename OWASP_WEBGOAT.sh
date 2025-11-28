#!/usr/bin/env bash

set -e

WEBGOAT_VERSION="2023.4"
WEBGOAT_JAR="webgoat-${WEBGOAT_VERSION}.jar"
WEBGOAT_URL="https://github.com/WebGoat/WebGoat/releases/download/v${WEBGOAT_VERSION}/${WEBGOAT_JAR}"

INSTALL_DIR="/opt/webgoat"
WG_USER="webgoat"

echo "=== Installation de WebGoat ${WEBGOAT_VERSION} ==="

if [ "$EUID" -ne 0 ]; then
  echo "Lance ce script avec sudo."
  exit 1
fi

apt update -y
apt install -y openjdk-17-jre wget

if ! id "$WG_USER" >/dev/null 2>&1; then
  useradd --system --home "$INSTALL_DIR" --shell /usr/sbin/nologin "$WG_USER"
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "Téléchargement de WebGoat..."
wget -O "$WEBGOAT_JAR" "$WEBGOAT_URL"

chown -R "$WG_USER":"$WG_USER" "$INSTALL_DIR"

cat > /etc/systemd/system/webgoat.service <<EOF
[Unit]
Description=OWASP WebGoat
After=network.target

[Service]
Type=simple
User=${WG_USER}
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/bin/java -jar ${INSTALL_DIR}/${WEBGOAT_JAR} --server.port=8080 --server.address=0.0.0.0
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable webgoat
systemctl restart webgoat

echo "Installation terminée."
