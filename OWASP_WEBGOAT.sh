#!/usr/bin/env bash
# Installation de WebGoat sur Ubuntu Server 22.04 LTS (sans Docker)
# - WebGoat  : HTTP sur port 8080
# - WebWolf  : HTTP sur port 9090

set -e

WEBGOAT_VERSION="2023.4"
WEBGOAT_JAR="webgoat-${WEBGOAT_VERSION}.jar"
WEBGOAT_URL="https://github.com/WebGoat/WebGoat/releases/download/v${WEBGOAT_VERSION}/${WEBGOAT_JAR}"

INSTALL_DIR="/opt/webgoat"
WG_USER="webgoat"
SERVICE_FILE="/etc/systemd/system/webgoat.service"

WEBGOAT_PORT=8080
WEBWOLF_PORT=9090

echo "=== Installation de WebGoat ${WEBGOAT_VERSION} sur Ubuntu 22.04 ==="

# 0) Vérifier que le script est lancé en root
if [ "$EUID" -ne 0 ]; then
  echo "Merci de lancer ce script avec sudo ou en root."
  exit 1
fi

echo "[1/6] Mise à jour des paquets..."
apt update -y

echo "[2/6] Installation de Java et wget..."
apt install -y openjdk-17-jre wget

echo "[3/6] Création de l'utilisateur et du répertoire WebGoat..."
if ! id -u "$WG_USER" >/dev/null 2>&1; then
  useradd --system --home "$INSTALL_DIR" --shell /usr/sbin/nologin "$WG_USER"
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "[4/6] Téléchargement de WebGoat (${WEBGOAT_JAR})..."
wget -O "$WEBGOAT_JAR" "$WEBGOAT_URL"

chown -R "$WG_USER":"$WG_USER" "$INSTALL_DIR"

echo "[5/6] Création / mise à jour du service systemd..."
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=OWASP WebGoat
After=network.target

[Service]
Type=simple
User=${WG_USER}
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/bin/java -Dfile.encoding=UTF-8 -Dwebgoat.port=${WEBGOAT_PORT} -Dwebwolf.port=${WEBWOLF_PORT} -Dserver.address=0.0.0.0 -jar ${INSTALL_DIR}/${WEBGOAT_JAR}
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "[6/6] Activation et démarrage du service WebGoat..."
systemctl daemon-reload
systemctl enable webgoat
systemctl restart webgoat

echo
echo "=== Installation terminée ==="
echo

if systemctl is-active --quiet webgoat; then
  echo "✅ Service WebGoat actif."
else
  echo "❌ Attention : le service WebGoat ne semble pas démarrer correctement."
  systemctl status webgoat --no-pager
fi

IP_ADDR=\$(hostname -I | awk '{print \$1}')

echo
echo "Accès HTTP (pas de HTTPS !) :"
echo "  WebGoat :  http://\${IP_ADDR}:${WEBGOAT_PORT}/WebGoat"
echo "  WebWolf :  http://\${IP_ADDR}:${WEBWOLF_PORT}/WebWolf"
echo
echo "Si UFW est actif, ouvre les ports :"
echo "  sudo ufw allow ${WEBGOAT_PORT}/tcp"
echo "  sudo ufw allow ${WEBWOLF_PORT}/tcp"
echo
echo "Fin."
