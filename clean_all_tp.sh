#!/bin/bash
# cleanup_all.sh
# Nettoie TOUS les TP et remet la VM à zéro

echo "═══════════════════════════════════════════════════"
echo "     🧹 NETTOYAGE COMPLET DE TOUS LES TP"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Ce script va supprimer :"
echo "   - TP1 : /var/www/monsite"
echo "   - TP3 : Utilisateur 'hacker' et /tmp/.hidden"
echo "   - CTF : Utilisateurs alice, mallory, /opt/webapp, /var/ctf"
echo ""
echo "Début du nettoyage dans 3 secondes..."
sleep 3
echo ""

# ════════════════════════════════════════
# NETTOYAGE TP1 : PERMISSIONS
# ════════════════════════════════════════
echo "[1/4] 🗑️  Nettoyage TP1 - Permissions"

if [ -d /var/www/monsite ]; then
    rm -rf /var/www/monsite
    echo "   ✅ /var/www/monsite supprimé"
else
    echo "   ℹ️  /var/www/monsite n'existe pas"
fi

echo ""

# ════════════════════════════════════════
# NETTOYAGE TP3 : INTRUS
# ════════════════════════════════════════
echo "[2/4] 🗑️  Nettoyage TP3 - Intrus"

# Arrêter les processus de hacker
if id "hacker" &>/dev/null; then
    echo "   Arrêt des processus de 'hacker'..."
    pkill -u hacker 2>/dev/null
    sleep 1
    
    # Supprimer l'utilisateur
    userdel -r hacker 2>/dev/null
    echo "   ✅ Utilisateur 'hacker' supprimé"
else
    echo "   ℹ️  Utilisateur 'hacker' n'existe pas"
fi

# Supprimer les fichiers suspects
if [ -d /tmp/.hidden ]; then
    rm -rf /tmp/.hidden
    echo "   ✅ /tmp/.hidden supprimé"
else
    echo "   ℹ️  /tmp/.hidden n'existe pas"
fi

echo ""

# ════════════════════════════════════════
# NETTOYAGE CTF : CHALLENGES
# ════════════════════════════════════════
echo "[3/4] 🗑️  Nettoyage CTF - Tous les challenges"

# Challenge 1 : alice
if id "alice" &>/dev/null; then
    pkill -u alice 2>/dev/null
    sleep 1
    userdel -r alice 2>/dev/null
    echo "   ✅ Utilisateur 'alice' supprimé"
else
    echo "   ℹ️  Utilisateur 'alice' n'existe pas"
fi

# Challenge 2 : /opt/webapp
if [ -d /opt/webapp ]; then
    rm -rf /opt/webapp
    echo "   ✅ /opt/webapp supprimé"
else
    echo "   ℹ️  /opt/webapp n'existe pas"
fi

# Challenge 3 : mallory
if id "mallory" &>/dev/null; then
    pkill -u mallory 2>/dev/null
    sleep 1
    crontab -u mallory -r 2>/dev/null
    userdel -r mallory 2>/dev/null
    echo "   ✅ Utilisateur 'mallory' supprimé"
else
    echo "   ℹ️  Utilisateur 'mallory' n'existe pas"
fi

# Challenge 4 : /var/ctf
if [ -d /var/ctf ]; then
    rm -rf /var/ctf
    echo "   ✅ /var/ctf supprimé"
else
    echo "   ℹ️  /var/ctf n'existe pas"
fi

echo ""

# ════════════════════════════════════════
# NETTOYAGE DES LOGS
# ════════════════════════════════════════
echo "[4/4] 🗑️  Nettoyage des logs suspects"

# Sauvegarder auth.log
cp /var/log/auth.log /var/log/auth.log.backup 2>/dev/null

# Supprimer les lignes contenant hacker, alice, mallory
sed -i '/hacker/d' /var/log/auth.log 2>/dev/null
sed -i '/alice/d' /var/log/auth.log 2>/dev/null
sed -i '/mallory/d' /var/log/auth.log 2>/dev/null

echo "   ✅ Logs nettoyés (backup : /var/log/auth.log.backup)"

echo ""

# ════════════════════════════════════════
# VÉRIFICATIONS FINALES
# ════════════════════════════════════════
echo "═══════════════════════════════════════════════════"
echo "     🔍 VÉRIFICATIONS FINALES"
echo "═══════════════════════════════════════════════════"
echo ""

echo -n "TP1 - /var/www/monsite : "
if [ ! -d /var/www/monsite ]; then echo "✅ Supprimé"; else echo "❌ Existe encore"; fi

echo -n "TP3 - Utilisateur hacker : "
if ! id "hacker" &>/dev/null; then echo "✅ Supprimé"; else echo "❌ Existe encore"; fi

echo -n "TP3 - /tmp/.hidden : "
if [ ! -d /tmp/.hidden ]; then echo "✅ Supprimé"; else echo "❌ Existe encore"; fi

echo -n "TP3 - Processus Python : "
if ! pgrep -f "python3.*8888" >/dev/null; then echo "✅ Arrêté"; else echo "❌ Tourne encore"; fi

echo -n "TP3 - Port 8888 : "
if ! ss -tulpn 2>/dev/null | grep -q 8888; then echo "✅ Fermé"; else echo "❌ Ouvert"; fi

echo -n "CTF - Utilisateur alice : "
if ! id "alice" &>/dev/null; then echo "✅ Supprimé"; else echo "❌ Existe encore"; fi

echo -n "CTF - Utilisateur mallory : "
if ! id "mallory" &>/dev/null; then echo "✅ Supprimé"; else echo "❌ Existe encore"; fi

echo -n "CTF - /opt/webapp : "
if [ ! -d /opt/webapp ]; then echo "✅ Supprimé"; else echo "❌ Existe encore"; fi

echo -n "CTF - /var/ctf : "
if [ ! -d /var/ctf ]; then echo "✅ Supprimé"; else echo "❌ Existe encore"; fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "     ✅ NETTOYAGE TERMINÉ"
echo "═══════════════════════════════════════════════════"
echo ""
echo "La VM est maintenant propre et prête pour une nouvelle installation."
echo ""
