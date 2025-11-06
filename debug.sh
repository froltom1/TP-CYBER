su -

cat > cleanup_debug.sh << 'ENDFILE'
#!/bin/bash
echo "Suppression BRUTALE..."

for user in hacker alice mallory; do
    echo "→ $user"
    pkill -9 -u "$user" 2>/dev/null
    userdel -f "$user" 2>/dev/null
    groupdel "$user" 2>/dev/null
    sed -i "/^$user:/d" /etc/passwd
    sed -i "/^$user:/d" /etc/shadow
    sed -i "/^$user:/d" /etc/group
    sed -i "/^$user:/d" /etc/gshadow
    rm -rf "/home/$user"
    
    if id "$user" 2>/dev/null; then
        echo "  ❌ ECHEC"
    else
        echo "  ✅ OK"
    fi
done

rm -rf /var/www/monsite /tmp/.hidden /opt/webapp /var/ctf
echo "✅ Fichiers supprimés"
ENDFILE

chmod +x cleanup_debug.sh
./cleanup_debug.sh
