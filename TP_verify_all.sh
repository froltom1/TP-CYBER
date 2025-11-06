#!/bin/bash
# verify_all.sh
# Vérifie tous les TP installés

echo "═══════════════════════════════════════════════════"
echo "     VÉRIFICATION COMPLÈTE DES TP"
echo "═══════════════════════════════════════════════════"
echo ""

# ════════════════════════════════════════
# TP1 : PERMISSIONS
# ════════════════════════════════════════
echo "📁 TP1 - PERMISSIONS"
echo -n "  Dossier /var/www/monsite : "
if [ -d /var/www/monsite ]; then echo "✅"; else echo "❌"; fi

echo -n "  database.php (777) : "
if [ -f /var/www/monsite/config/database.php ]; then
    PERM=$(stat -c '%a' /var/www/monsite/config/database.php)
    if [ "$PERM" = "777" ]; then echo "✅"; else echo "❌ ($PERM)"; fi
else
    echo "❌ (fichier absent)"
fi

echo -n "  .env (666) : "
if [ -f /var/www/monsite/.env ]; then
    PERM=$(stat -c '%a' /var/www/monsite/.env)
    if [ "$PERM" = "666" ]; then echo "✅"; else echo "❌ ($PERM)"; fi
else
    echo "❌ (fichier absent)"
fi

echo ""

# ════════════════════════════════════════
# TP3 : INTRUS
# ════════════════════════════════════════
echo "🕵️ TP3 - INTRUS"
echo -n "  Utilisateur 'hacker' : "
if id "hacker" &>/dev/null; then echo "✅"; else echo "❌"; fi

echo -n "  Fichiers /tmp/.hidden : "
if [ -d /tmp/.hidden ]; then echo "✅"; else echo "❌"; fi

echo -n "  Processus Python 8888 : "
if pgrep -f "python3.*8888" >/dev/null; then 
    echo "✅ (PID: $(pgrep -f 'python3.*8888'))"
else 
    echo "❌"
fi

echo -n "  Port 8888 ouvert : "
if ss -tulpn 2>/dev/null | grep -q 8888; then echo "✅"; else echo "❌"; fi

echo ""

# ════════════════════════════════════════
# CTF : 4 CHALLENGES
# ════════════════════════════════════════
echo "🚩 CTF - 4 CHALLENGES"

echo -n "  Challenge 1 - alice : "
if id "alice" &>/dev/null; then echo "✅"; else echo "❌"; fi

echo -n "  Challenge 1 - flag1.txt : "
if [ -f /home/alice/.secrets/flag1.txt ]; then echo "✅"; else echo "❌"; fi

echo -n "  Challenge 2 - config.ini : "
if [ -f /opt/webapp/config.ini ]; then echo "✅"; else echo "❌"; fi

echo -n "  Challenge 3 - mallory : "
if id "mallory" &>/dev/null; then echo "✅"; else echo "❌"; fi

echo -n "  Challenge 3 - notes.txt : "
if [ -f /home/mallory/.hidden_tools/notes.txt ]; then echo "✅"; else echo "❌"; fi

echo -n "  Challenge 4 - encrypted_message.txt : "
if [ -f /var/ctf/encrypted_message.txt ]; then echo "✅"; else echo "❌"; fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Vérification terminée"
echo "═══════════════════════════════════════════════════"
