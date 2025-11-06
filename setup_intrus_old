#!/bin/bash
# setup_intrus.sh - À exécuter 5 min avant le TP3

# Créer un utilisateur suspect
useradd -m -s /bin/bash hacker
echo "hacker:password123" | chpasswd

# Créer des fichiers suspects
mkdir -p /tmp/.hidden
cat > /tmp/.hidden/data.txt <<EOF
Liste des mots de passe récupérés :
admin:admin123
root:toor
webmaster:password
EOF

# Donner les permissions à hacker
chown -R hacker:hacker /tmp/.hidden

# Lancer un processus suspect EN TANT QUE hacker
# Méthode 1 : avec su
su - hacker -c "python3 -m http.server 8888 --directory /tmp/.hidden >/dev/null 2>&1 &"

# OU Méthode 2 : avec sudo (si installé)
# sudo -u hacker python3 -m http.server 8888 --directory /tmp/.hidden >/dev/null 2>&1 &

# Attendre 2 secondes que le serveur démarre
sleep 2

# Créer des logs suspects
echo "$(date '+%b %d %H:%M:%S') $(hostname) sshd[5555]: Accepted password for hacker from 203.0.113.50 port 12345 ssh2" >> /var/log/auth.log
echo "$(date '+%b %d %H:%M:%S') $(hostname) sudo: hacker : user NOT in sudoers ; TTY=pts/2 ; PWD=/home/hacker ; USER=root ; COMMAND=/bin/cat /etc/shadow" >> /var/log/auth.log

# Créer une tâche cron suspecte
echo "*/5 * * * * /tmp/.hidden/exfiltrate.sh" | crontab -u hacker -

echo "✅ Environnement 'intrus' créé"
echo ""
echo "Vérifications :"
echo "1. Utilisateur hacker : $(grep hacker /etc/passwd && echo '✅' || echo '❌')"
echo "2. Fichiers dans /tmp/.hidden : $(ls /tmp/.hidden 2>/dev/null && echo '✅' || echo '❌')"
echo "3. Processus python : $(ps aux | grep '[p]ython.*8888' && echo '✅' || echo '❌')"
echo "4. Port 8888 ouvert : $(ss -tulpn | grep 8888 && echo '✅' || echo '❌')"
