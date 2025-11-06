#!/bin/bash
# setup_tp3_intrus.sh
# À lancer EN ROOT 5 minutes avant le TP3 (10h55)

echo "🕵️ Installation TP3 : Trouvez l'Intrus"
echo ""

# Créer un utilisateur suspect
if id "hacker" &>/dev/null; then
    echo "⚠️  L'utilisateur 'hacker' existe déjà, nettoyage..."
    pkill -u hacker 2>/dev/null
    userdel -r hacker 2>/dev/null
fi

useradd -m -s /bin/bash hacker
echo "hacker:password123" | chpasswd

# Créer des fichiers suspects
mkdir -p /tmp/.hidden
cat > /tmp/.hidden/data.txt <<'EOF'
Liste des mots de passe récupérés :
admin:admin123
root:toor
webmaster:password
EOF

# Donner les permissions à hacker
chown -R hacker:hacker /tmp/.hidden

# Lancer un processus suspect EN TANT QUE hacker
su - hacker -c "python3 -m http.server 8888 --directory /tmp/.hidden >/dev/null 2>&1 &" &

# Attendre que le serveur démarre
sleep 3

# Créer des logs suspects
echo "$(date '+%b %d %H:%M:%S') $(hostname) sshd[5555]: Accepted password for hacker from 203.0.113.50 port 12345 ssh2" >> /var/log/auth.log
echo "$(date '+%b %d %H:%M:%S') $(hostname) sudo: hacker : user NOT in sudoers ; TTY=pts/2 ; PWD=/home/hacker ; USER=root ; COMMAND=/bin/cat /etc/shadow" >> /var/log/auth.log

# Créer une tâche cron suspecte
echo "*/5 * * * * /tmp/.hidden/exfiltrate.sh" | crontab -u hacker -

echo ""
echo "✅ TP3 installé avec succès !"
echo ""
echo "Vérifications :"
echo -n "1. Utilisateur hacker : "
if id "hacker" &>/dev/null; then echo "✅"; else echo "❌"; fi

echo -n "2. Fichiers dans /tmp/.hidden : "
if [ -f /tmp/.hidden/data.txt ]; then echo "✅"; else echo "❌"; fi

echo -n "3. Processus Python : "
if pgrep -f "python3.*8888" >/dev/null; then echo "✅ (PID: $(pgrep -f 'python3.*8888'))"; else echo "❌"; fi

echo -n "4. Port 8888 ouvert : "
if ss -tulpn | grep -q 8888; then echo "✅"; else echo "❌"; fi

echo ""
echo "🕵️ Les étudiants doivent enquêter sur le système compromis"
