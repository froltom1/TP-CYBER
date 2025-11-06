#!/bin/bash
# setup_tp1_permissions.sh
# À lancer EN ROOT avant le TP1 (9h00)

echo "🔧 Installation TP1 : Audit de Sécurité - Permissions"
echo ""

# Créer l'environnement de TP
mkdir -p /var/www/monsite
mkdir -p /var/www/monsite/config
mkdir -p /var/www/monsite/uploads

# Créer des fichiers vulnérables
cat > /var/www/monsite/index.php <<'EOF'
<?php
echo "Bienvenue sur mon site";
?>
EOF

cat > /var/www/monsite/config/database.php <<'EOF'
<?php
$db_password = "SuperMotDePasse123!";
$db_user = "admin";
?>
EOF

cat > /var/www/monsite/.env <<'EOF'
SECRET_KEY=abc123xyz789
DATABASE_URL=mysql://root:J'aimeMangerDesPommes@localhost/db
EOF

# Créer un script dangereux
cat > /var/www/monsite/backup.sh <<'EOF'
#!/bin/bash
tar -czf /tmp/backup.tar.gz /var/www/monsite
EOF

# Appliquer des permissions DANGEREUSES
chmod 777 /var/www/monsite/config/database.php
chmod 666 /var/www/monsite/.env
chmod 777 /var/www/monsite/uploads
chmod 777 /var/www/monsite/backup.sh

# Définir le propriétaire (utiliser root si www-data n'existe pas)
if id "www-data" &>/dev/null; then
    chown -R www-data:www-data /var/www/monsite
else
    chown -R root:root /var/www/monsite
fi

echo ""
echo "✅ TP1 installé avec succès !"
echo ""
echo "Vérification :"
ls -laR /var/www/monsite
echo ""
echo "📁 Les étudiants doivent auditer : /var/www/monsite"
