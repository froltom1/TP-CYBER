# 1. Vérifier que le dossier existe
ls -la /var/www/monsite

# 2. Vérifier les fichiers créés
ls -laR /var/www/monsite

# 3. Vérifier les permissions dangereuses
ls -l /var/www/monsite/config/database.php
# Doit afficher : -rwxrwxrwx (777)

ls -l /var/www/monsite/.env
# Doit afficher : -rw-rw-rw- (666)

ls -l /var/www/monsite/uploads
# Doit afficher : drwxrwxrwx (777)

ls -l /var/www/monsite/backup.sh
# Doit afficher : -rwxrwxrwx (777)

# 4. Vérifier le contenu d'un fichier
cat /var/www/monsite/.env
# Doit afficher le mot de passe "J'aimeMangerDesPommes"
```

**✅ CE QUE TU DOIS VOIR :**
```
/var/www/monsite/
├── backup.sh (777)
├── config/
│   └── database.php (777)
├── .env (666)
├── index.php (644 ou autre)
└── uploads/ (777)
