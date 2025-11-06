#!/bin/bash
# cleanup_all.sh
# Nettoie TOUS les TP et remet la VM à zéro

echo "=============================================="
echo "     NETTOYAGE COMPLET DE TOUS LES TP"
echo "=============================================="
echo ""
echo "Ce script va supprimer :"
echo "  - TP1 : /var/www/monsite"
echo "  - TP3 : Utilisateur 'hacker' et /tmp/.hidden"
echo "  - CTF : Utilisateurs alice, mallory, /opt/webapp, /var/ctf"
echo ""
echo "Debut du nettoyage..."
echo ""

# ════════════════════════════════════════
# Fonction de suppression BRUTALE d'un utilisateur
# ════════════════════════════════════════
delete_user_force() {
    local user=$1
    
    if id "$user" &>/dev/null; then
        echo "  Suppression de $user..."
        
        # 1. Tuer TOUS les processus (force)
        pkill -9 -u "$user" 2>/dev/null
        sleep 1
        
        # 2. Supprimer le cron
        crontab -u "$user" -r 2>/dev/null
        
        # 3. Tentative userdel classique
        userdel -f -r "$user" 2>/dev/null
        
        # 4. Si ça a échoué, méthode BRUTALE
        if id "$user" &>/dev/null; then
            # Éditer directement les fichiers système
            sed -i "/^$user:/d" /etc/passwd 2>/dev/null
            sed -i "/^$user:/d" /etc/shadow 2>/dev/null
            sed -i "/^$user:/d" /etc/group 2>/dev/null
            sed -i "/^$user:/d" /etc/gshadow 2>/dev/null
            
            # Supprimer le home manuellement
            rm -rf "/home/$user" 2>/dev/null
        fi
        
        # 5. Vérification finale
        if id "$user" &>/dev/null; then
            echo "  ❌ ECHEC : $user existe encore"
        else
            echo "  ✅ OK : $user supprime"
        fi
    else
        echo "  ℹ️  $user n'existait pas"
    fi
}

# ════════════════════════════════════════
# NETTOYAGE TP1 : PERMISSIONS
# ════════════════════════════════════════
echo "[1/4] Nettoyage TP1 - Permissions"

if [ -d /var/www/monsite ]; then
    rm -rf /var/www/monsite 2>/dev/null
    echo "  ✅ /var/www/monsite supprime"
else
    echo "  ℹ️  /var/www/monsite n'existait pas"
fi

echo ""

# ════════════════════════════════════════
# NETTOYAGE TP3 : INTRUS
# ════════════════════════════════════════
echo "[2/4] Nettoyage TP3 - Intrus"

delete_user_force "hacker"

if [ -d /tmp/.hidden ]; then
    rm -rf /tmp/.hidden 2>/dev/null
    echo "  ✅ /tmp/.hidden supprime"
else
    echo "  ℹ️  /tmp/.hidden n'existait pas"
fi

echo ""

# ════════════════════════════════════════
# NETTOYAGE CTF : CHALLENGES
# ════════════════════════════════════════
echo "[3/4] Nettoyage CTF - Tous les challenges"

delete_user_force "alice"
delete_user_force "mallory"

if [ -d /opt/webapp ]; then
    rm -rf /opt/webapp 2>/dev/null
    echo "  ✅ /opt/webapp supprime"
else
    echo "  ℹ️  /opt/webapp n'existait pas"
fi

if [ -d /var/ctf ]; then
    rm -rf /var/ctf 2>/dev/null
    echo "  ✅ /var/ctf supprime"
else
    echo "  ℹ️  /var/ctf n'existait pas"
fi

echo ""

# ════════════════════════════════════════
# NETTOYAGE DES LOGS
# ════════════════════════════════════════
echo "[4/4] Nettoyage des logs suspects"

# Sauvegarder auth.log
cp /var/log/auth.log /var/log/auth.log.backup 2>/dev/null

# Supprimer les lignes contenant hacker, alice, mallory
sed -i '/hacker/d' /var/log/auth.log 2>/dev/null
sed -i '/alice/d' /var/log/auth.log 2>/dev/null
sed -i '/mallory/d' /var/log/auth.log 2>/dev/null

echo "  ✅ Logs nettoyes (backup : /var/log/auth.log.backup)"

echo ""

# ════════════════════════════════════════
# VÉRIFICATIONS FINALES
# ════════════════════════════════════════
echo "=============================================="
echo "     VERIFICATIONS FINALES"
echo "=============================================="
echo ""

echo -n "TP1 - /var/www/monsite : "
if [ -d /var/www/monsite ]; then echo "❌ Existe encore"; else echo "✅ Supprime"; fi

echo -n "TP3 - Utilisateur hacker : "
if id "hacker" &>/dev/null; then echo "❌ Existe encore"; else echo "✅ Supprime"; fi

echo -n "TP3 - Home de hacker : "
if [ -d /home/hacker ]; then echo "❌ Existe encore"; else echo "✅ Supprime"; fi

echo -n "TP3 - /tmp/.hidden : "
if [ -d /tmp/.hidden ]; then echo "❌ Existe encore"; else echo "✅ Supprime"; fi

echo -n "TP3 - Processus Python : "
if pgrep -f "python3.*8888" >/dev/null 2>&1; then echo "❌ Tourne encore"; else echo "✅ Arrete"; fi

echo -n "TP3 - Port 8888 : "
if ss -tulpn 2>/dev/null | grep -q 8888; then echo "❌ Ouvert"; else echo "✅ Ferme"; fi

echo -n "CTF - Utilisateur alice : "
if id "alice" &>/dev/null; then echo "❌ Existe encore"; else echo "✅ Supprime"; fi

echo -n "CTF - Home d'alice : "
if [ -d /home/alice ]; then echo "❌ Existe encore"; else echo "✅ Supprime"; fi

echo -n "CTF - Utilisateur mallory : "
if id "mallory" &>/dev/null; then echo "❌ Existe encore"; else echo "✅ Supprime"; fi

echo -n "CTF - Home de mallory : "
if [ -d /home/mallory ]; then echo "❌ Existe encore"; else echo "✅ Supprime"; fi

echo -n "CTF - /opt/webapp : "
if [ -d /opt/webapp ]; then echo "❌ Existe encore"; else echo "✅ Supprime"; fi

echo -n "CTF - /var/ctf : "
if [ -d /var/ctf ]; then echo "❌ Existe encore"; else echo "✅ Supprime"; fi

echo ""
echo "=============================================="
echo "     ✅ NETTOYAGE TERMINE"
echo "=============================================="
echo ""
echo "La VM est maintenant propre et prete pour une nouvelle installation."
echo ""
