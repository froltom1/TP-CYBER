#!/bin/bash
# setup_intrus.sh - À exécuter 5 min avant le TP

# Créer un utilisateur suspect
sudo useradd -m -s /bin/bash hacker
echo "hacker:password123" | chpasswd

# Créer des fichiers suspects
sudo mkdir /tmp/.hidden
sudo tee /tmp/.hidden/data.txt > /dev/null <<EOF
Liste des mots de passe récupérés :
admin:admin123
root:toor
webmaster:password
EOF

# Lancer un processus suspect (serveur web caché)
sudo -u hacker nohup python3 -m http.server 8888 --directory /tmp/.hidden > /dev/null 2>&1 &

# Créer des logs suspects
sudo bash -c "echo '$(date) hacker : commande sudo REFUSÉE' >> /var/log/auth.log"
sudo bash -c "echo '$(date) session ouverte pour hacker' >> /var/log/auth.log"

# Créer une tâche cron suspecte
echo "*/5 * * * * /tmp/.hidden/exfiltrate.sh" | crontab -u hacker -

echo "✅ Environnement 'intrus' créé"
