#!/bin/bash
# cleanup_all_force.sh
# Version FORCÉE qui supprime vraiment tout

echo "=============================================="
echo "  NETTOYAGE FORCE DE TOUS LES TP"
echo "=============================================="
echo ""

# Fonction de suppression forcée d'un utilisateur
force_delete_user() {
    local username=$1
    
    if id "$username" &>/dev/null; then
        echo "  Suppression de $username..."
        
        # 1. Tuer TOUS les processus
        pkill -9 -u "$username" 2>/dev/null
        sleep 1
        
        # 2. Supprimer le cron
        crontab -u "$username" -r 2>/dev/null
        
        # 3. Déconnecter les sessions
        pkill -KILL -u "$username" 2>/dev/null
        sleep 1
        
        # 4. Supprimer l'utilisateur (même si processus)
        userdel -f -r "$username" 2>/dev/null
        
        # 5. Supprimer manuellement le home si encore là
        rm -rf "/home/$username" 2>/dev/null
        
        # 6. Vérifier la suppression
        if id "$username" &>/dev/null; then
            echo "  ❌ ECHEC : $username existe encore"
            # Dernière tentative : éditer directement /etc/passwd
            sed -i "/^$username:/d" /etc/passwd
            sed -i "/^$username:/d" /etc/shadow
            sed -i "/^$username:/d" /etc/group
            rm -rf "/home/$username"
        else
            echo "  ✅ OK : $username supprimé"
        fi
    else
        echo "  ℹ️  $username n'existait pas"
    fi
}

# ════════════════════════════════════════
# NETTOYAGE TP1
# ════════════════════════════════════════
echo "[1/4] Nettoyage TP1 - Permissions"
rm -rf /var/www/monsite 2>/dev/null
echo "  ✅ /var/www/monsite supprimé"
echo ""

# ════════════════════════════════════════
# NETTOYAGE TP3
# ════════════════════════════════════════
echo "[2/4] Nettoyage TP3 - Intrus"
force_delete_user "hacker"
rm -rf /tmp/.hidden 2>/dev/null
echo "  ✅ /tmp/.hidden supprimé"
echo ""

# ════════════════════════════════════════
# NETTOYAGE CTF
# ════════════════════════════════════════
echo "[3/4] Nettoyage CTF - Challenges"
force_delete_user "alice"
force_delete_user "mallory"
rm -rf /opt/webapp 2>/dev/null
rm -rf /var/ctf 2>/dev/null
echo "  ✅ /opt/webapp et /var/ctf supprimés"
echo ""

# ════════════════════════════════════════
# NETTOYAGE LOGS
# ════════════════════════════════════════
echo "[4/4] Nettoyage logs"
cp /var/log/auth.log /var/log/auth.log.backup 2>/dev/null
sed -i '/hacker/d; /alice/d; /mallory/d' /var/log/auth.log 2>/dev/null
echo "  ✅ Logs nettoyés"
echo ""

# ════════════════════════════════════════
# VERIFICATIONS FINALES
# ════════════════════════════════════════
echo "=============================================="
echo "  VERIFICATIONS FINALES"
echo "=============================================="
echo ""

echo -n "TP1 - /var/www/monsite : "
if [ -d /var/www/monsite ]; then echo "❌ Existe"; else echo "✅ Supprimé"; fi

echo -n "TP3 - Utilisateur hacker : "
if id "hacker" &>/dev/null; then echo "❌ Existe"; else echo "✅ Supprimé"; fi

echo -n "TP3 - Home de hacker : "
if [ -d /home/hacker ]; then echo "❌ Existe"; else echo "✅ Supprimé"; fi

echo -n "TP3 - /tmp/.hidden : "
if [ -d /tmp/.hidden ]; then echo "❌ Existe"; else echo "✅ Supprimé"; fi

echo -n "TP3 - Processus Python : "
if pgrep -f "python3.*8888" >/dev/null; then echo "❌ Actif"; else echo "✅ Arrêté"; fi

echo -n "CTF - Utilisateur alice : "
if id "alice" &>/dev/null; then echo "❌ Existe"; else echo "✅ Supprimé"; fi

echo -n "CTF - Home d'alice : "
if [ -d /home/alice ]; then echo "❌ Existe"; else echo "✅ Supprimé"; fi

echo -n "CTF - Utilisateur mallory : "
if id "mallory" &>/dev/null; then echo "❌ Existe"; else echo "✅ Supprimé"; fi

echo -n "CTF - Home de mallory : "
if [ -d /home/mallory ]; then echo "❌ Existe"; else echo "✅ Supprimé"; fi

echo -n "CTF - /opt/webapp : "
if [ -d /opt/webapp ]; then echo "❌ Existe"; else echo "✅ Supprimé"; fi

echo -n "CTF - /var/ctf : "
if [ -d /var/ctf ]; then echo "❌ Existe"; else echo "✅ Supprimé"; fi

echo ""
echo "=============================================="
echo "  NETTOYAGE TERMINE"
echo "=============================================="
echo ""
