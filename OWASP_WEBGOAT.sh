#!/usr/bin/env bash
# Installation de WebGoat sur Ubuntu Server 22.04 LTS (sans Docker)

set -e

WEBGOAT_VERSION="2023.4"
WEBGOAT_JAR="webgoat-${WEBGOAT_VERSION}.jar"
WEBGOAT_URL="https://github.com/WebGoat/WebGoat/releases/download/v${WEBGOAT_VERSION}/${WEBGOAT_JAR}"
INSTALL_DIR="/opt/webgoat"
WG_USER="webgoat"
WG_GROUP="webgoat"
SERVICE_FILE="/etc/systemd/system/webgoat.service"

echo "=== Installation de WebGoat ${WEBGOAT_VERSION} sur Ubuntu 22.04 ==="

# Vérifier que le script est lancé en root
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

chown -R "$WG_USER":"$WG_GROUP" "$INSTALL_DIR"

echo "[5/6] Création du service systemd..."

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=OWASP WebGoat
After=network.target

[Service]
Type=simple
User=${WG_USER}
Group=${WG_GROUP}
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/bin/java -jar ${INSTALL_DIR}/${WEBGOAT_JAR} --server.port=8080 --server.address=0.0.0.0
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "[6/6] Activation et démarrage du service WebGoat..."
systemctl daemon-reload
systemctl enable webgoat
systemctl restart webgoat

echo "=== Installation terminée ==="
echo "Statut du service :"
systemctl --no-pager status webgoat || true

echo
echo "Si UFW est actif, pense à ouvrir le port 8080 :"
echo "  sudo ufw allow 8080/tcp"
echo
echo "Accès à WebGoat : http://IP_DE_LA_VM:8080/WebGoat"
echo "Login par défaut : guest / guest"
