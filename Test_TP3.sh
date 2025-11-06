# 1. Vérifier que l'utilisateur hacker existe
cat /etc/passwd | grep hacker
# Doit afficher : hacker:x:1003:1003::/home/hacker:/bin/bash

# 2. Vérifier les fichiers suspects
ls -la /tmp/.hidden
cat /tmp/.hidden/data.txt
# Doit afficher les mots de passe volés

# 3. Vérifier que le processus Python tourne
ps aux | grep python
# Doit afficher : hacker ... python3 -m http.server 8888

# OU plus précis :
ps aux | grep "[p]ython.*8888"

# 4. Vérifier le PID du processus
pgrep -f "python3.*8888"
# Doit afficher un numéro (par exemple : 1234)

# 5. Vérifier que le port 8888 est ouvert
ss -tulpn | grep 8888
# Doit afficher : tcp LISTEN 0.0.0.0:8888 ... python3

# 6. Tester le serveur web
curl http://localhost:8888
# Doit afficher une page HTML avec "data.txt"

# 7. Vérifier les logs suspects
tail -5 /var/log/auth.log
# Doit contenir des lignes avec "hacker"

# 8. Vérifier le cron de hacker
crontab -u hacker -l
# Doit afficher : */5 * * * * /tmp/.hidden/exfiltrate.sh
```

**✅ CE QUE TU DOIS VOIR :**
```
Utilisateur : hacker ✅
Fichiers : /tmp/.hidden/data.txt ✅
Processus : python3 port 8888 ✅
Port ouvert : 8888 ✅
Logs : Connexion de hacker ✅
Cron : Tâche planifiée ✅
