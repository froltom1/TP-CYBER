#!/bin/bash
# setup_ctf.sh
# À lancer EN ROOT avant le CTF (14h55)

echo "🚩 Installation CTF - Cybersécurité Linux"
echo ""

# Nettoyer les anciens challenges si ils existent
echo "Nettoyage des anciens challenges..."
userdel -r alice 2>/dev/null
userdel -r mallory 2>/dev/null
rm -rf /opt/webapp 2>/dev/null
rm -rf /var/ctf 2>/dev/null

echo ""
echo "═══════════════════════════════════════════════════"
echo "Installation des 4 challenges..."
echo "═══════════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════════
# CHALLENGE 1 : Password in Logs
# ═══════════════════════════════════════════════════
echo "[1/4] 🔍 Challenge 1 : Password in Logs"

# Créer l'utilisateur alice
useradd -m -s /bin/bash alice
echo "alice:SecretPass2024!" | chpasswd

# Ajouter des logs suspects
echo "$(date '+%b %d %H:%M:%S') $(hostname) sshd[9999]: Failed password for alice from 192.168.1.100 port 54321 ssh2" >> /var/log/auth.log
echo "$(date '+%b %d %H:%M:%S') $(hostname) sshd[9999]: Accepted password for alice from 192.168.1.100 port 54321 ssh2" >> /var/log/auth.log
echo "$(date '+%b %d %H:%M:%S') $(hostname) sudo: alice : TTY=pts/0 ; PWD=/home/alice ; USER=root ; COMMAND=/bin/cat /etc/shadow" >> /var/log/auth.log

# Créer le flag caché
mkdir -p /home/alice/.secrets
echo "FLAG{l0gs_t3ll_ev3ryth1ng}" > /home/alice/.secrets/flag1.txt
chown -R alice:alice /home/alice/.secrets
chmod 700 /home/alice/.secrets
chmod 600 /home/alice/.secrets/flag1.txt

echo "   ✅ Challenge 1 installé"

# ═══════════════════════════════════════════════════
# CHALLENGE 2 : Bad Permissions
# ═══════════════════════════════════════════════════
echo "[2/4] 🔐 Challenge 2 : Bad Permissions"

# Créer l'application web mal configurée
mkdir -p /opt/webapp
cat > /opt/webapp/config.ini <<'EOF'
[database]
host=localhost
user=dbadmin
password=FLAG{p3rm1ss10ns_m4tt3r}

[api]
key=sk_live_abc123xyz789
secret=very_secret_key_2024
EOF

# Appliquer les mauvaises permissions (lisible par tous)
chmod 644 /opt/webapp/config.ini
chown root:root /opt/webapp/config.ini

echo "   ✅ Challenge 2 installé"

# ═══════════════════════════════════════════════════
# CHALLENGE 3 : Suspect User
# ═══════════════════════════════════════════════════
echo "[3/4] 🕵️ Challenge 3 : Suspect User"

# Créer l'utilisateur suspect
useradd -m -s /bin/bash mallory
echo "mallory:hacktheplanet" | chpasswd

# Créer ses fichiers cachés
mkdir -p /home/mallory/.hidden_tools
cat > /home/mallory/.hidden_tools/notes.txt <<'EOF'
Mission réussie !
Accès root obtenu via /usr/local/bin/get-root
Le flag est : FLAG{susp3ct_us3r_f0und}
Exfiltration prévue à 03:00
Serveur C2 : 203.0.113.66:4444
EOF

chown -R mallory:mallory /home/mallory/.hidden_tools
chmod 700 /home/mallory/.hidden_tools

# Ajouter des logs suspects
echo "$(date '+%b %d %H:%M:%S') $(hostname) sshd[7777]: Accepted password for mallory from 203.0.113.66 port 12345 ssh2" >> /var/log/auth.log
echo "$(date '+%b %d %H:%M:%S') $(hostname) sudo: mallory : user NOT in sudoers ; TTY=pts/2 ; PWD=/home/mallory ; USER=root ; COMMAND=/usr/bin/whoami" >> /var/log/auth.log

# Créer une tâche cron suspecte
echo "*/15 * * * * /home/mallory/.hidden_tools/exfiltrate.sh" | crontab -u mallory -

echo "   ✅ Challenge 3 installé"

# ═══════════════════════════════════════════════════
# CHALLENGE 4 : SSH Decrypt (Bonus)
# ═══════════════════════════════════════════════════
echo "[4/4] 🔐 Challenge 4 : SSH Decrypt (Bonus)"

# Créer le dossier CTF
mkdir -p /var/ctf

# Créer le message chiffré
# Message original : "FLAG{crypt0_m4st3r_unlocked}"
# Chiffré avec : echo "FLAG{crypt0_m4st3r_unlocked}" | openssl enc -aes-256-cbc -salt -k cyb3rs3cur1ty -base64
echo "U2FsdGVkX19wvXGoE9x3xNb8YZ0FHXhJqK+Qa3vP2Tg=" > /var/ctf/encrypted_message.txt

# Créer le fichier d'indices
cat > /var/ctf/hint.txt <<'EOF'
🔐 MESSAGE CHIFFRÉ INTERCEPTÉ

Ce message a été chiffré avec OpenSSL.

Informations récupérées :
- Algorithme : AES-256-CBC
- Clé de déchiffrement : cyb3rs3cur1ty

Commande pour déchiffrer :
openssl enc -d -aes-256-cbc -base64 -in encrypted_message.txt -k [CLÉ]

Ou en une ligne :
openssl enc -d -aes-256-cbc -base64 -in /var/ctf/encrypted_message.txt -k cyb3rs3cur1ty
EOF

chmod 644 /var/ctf/*

echo "   ✅ Challenge 4 installé"

# ═══════════════════════════════════════════════════
# VÉRIFICATIONS FINALES
# ═══════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════"
echo "Vérifications finales"
echo "═══════════════════════════════════════════════════"
echo ""

echo -n "Challenge 1 - Utilisateur alice : "
if id "alice" &>/dev/null; then echo "✅"; else echo "❌"; fi

echo -n "Challenge 1 - Flag caché : "
if [ -f /home/alice/.secrets/flag1.txt ]; then echo "✅"; else echo "❌"; fi

echo -n "Challenge 2 - Fichier config : "
if [ -f /opt/webapp/config.ini ]; then echo "✅"; else echo "❌"; fi

echo -n "Challenge 2 - Permissions 644 : "
if [ "$(stat -c '%a' /opt/webapp/config.ini)" = "644" ]; then echo "✅"; else echo "❌"; fi

echo -n "Challenge 3 - Utilisateur mallory : "
if id "mallory" &>/dev/null; then echo "✅"; else echo "❌"; fi

echo -n "Challenge 3 - Notes cachées : "
if [ -f /home/mallory/.hidden_tools/notes.txt ]; then echo "✅"; else echo "❌"; fi

echo -n "Challenge 4 - Message chiffré : "
if [ -f /var/ctf/encrypted_message.txt ]; then echo "✅"; else echo "❌"; fi

echo -n "Challenge 4 - Indices : "
if [ -f /var/ctf/hint.txt ]; then echo "✅"; else echo "❌"; fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "🚩 CTF PRÊT !"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Challenges installés :"
echo "  1. Password in Logs     → /home/alice/.secrets/"
echo "  2. Bad Permissions      → /opt/webapp/config.ini"
echo "  3. Suspect User         → Utilisateur 'mallory'"
echo "  4. SSH Decrypt (Bonus)  → /var/ctf/"
echo ""
echo "Les étudiants peuvent commencer ! 🎯"
