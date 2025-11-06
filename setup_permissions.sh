#!/bin/bash
# Script de préparation à exécuter sur chaque VM étudiante
# À lancer EN ROOT : su - puis ./setup_permissions.sh

# Créer l'environnement de TP
mkdir -p /var/www/monsite
mkdir -p /var/www/monsite/config
mkdir -p /var/www/monsite/uploads

# Créer des fichiers vulnérables
cat > /var/www/monsite/index.php <<EOF
<?php
echo "Bienvenue sur mon site";cd
?>
EOF

cat > /var/www/monsite/config/database.php <<EOF
<?php
\$db_password = "J'aimeMangerDesPommes";
\$db_user = "admin";
?>
EOF

cat > /var/www/monsite/.env <<EOF
SECRET_KEY=abc123xyz789
DATABASE_URL=mysql://root:password@localhost/db
EOF

# Créer un script dangereux
cat > /var/www/monsite/backup.sh <<EOF
#!/bin/bash
tar -czf /tmp/backup.tar.gz /var/www/monsite
EOF

# Appliquer des permissions DANGEREUSES
chmod 777 /var/www/monsite/config/database.php
chmod 666 /var/www/monsite/.env
chmod 777 /var/www/monsite/uploads
chmod 777 /var/www/monsite/backup.sh
chown www-data:www-data /var/www/monsite -R

echo "✅ Environnement de TP créé dans /var/www/monsite"