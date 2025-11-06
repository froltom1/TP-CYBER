# 1. Vérifier que hacker n'existe plus
cat /etc/passwd | grep hacker
# Ne doit RIEN afficher

# 2. Vérifier que /tmp/.hidden est supprimé
ls -la /tmp/.hidden
# Doit afficher : No such file or directory

# 3. Vérifier que le processus Python est arrêté
ps aux | grep python
# Ne doit PAS afficher python3 port 8888

# 4. Vérifier que le port 8888 est fermé
ss -tulpn | grep 8888
# Ne doit RIEN afficher

# 5. Tester que le serveur ne répond plus
curl http://localhost:8888
# Doit afficher : Connection refused
```

**✅ CE QUE TU DOIS VOIR :**
```
Utilisateur hacker : ❌ (n'existe plus)
/tmp/.hidden : ❌ (supprimé)
Processus Python : ❌ (arrêté)
Port 8888 : ❌ (fermé)
