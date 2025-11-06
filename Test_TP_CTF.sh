# ════════════════════════════════════════
# CHALLENGE 1 : Password in Logs
# ════════════════════════════════════════

# 1. Vérifier que alice existe
cat /etc/passwd | grep alice
# Doit afficher : alice:x:1001:...

# 2. Vérifier les logs d'alice
grep alice /var/log/auth.log
# Doit afficher des connexions SSH

# 3. Vérifier le dossier caché
ls -la /home/alice/.secrets
# Doit afficher : flag1.txt

# 4. Vérifier le flag (en tant que root)
cat /home/alice/.secrets/flag1.txt
# Doit afficher : FLAG{l0gs_t3ll_ev3ryth1ng}

# ════════════════════════════════════════
# CHALLENGE 2 : Bad Permissions
# ════════════════════════════════════════

# 5. Vérifier le fichier config
ls -l /opt/webapp/config.ini
# Doit afficher : -rw-r--r-- (644)

# 6. Vérifier le contenu (lisible par tous)
cat /opt/webapp/config.ini
# Doit afficher le flag : FLAG{p3rm1ss10ns_m4tt3r}

# ════════════════════════════════════════
# CHALLENGE 3 : Suspect User
# ════════════════════════════════════════

# 7. Vérifier que mallory existe
cat /etc/passwd | grep mallory
# Doit afficher : mallory:x:1002:...

# 8. Vérifier les fichiers cachés de mallory
ls -la /home/mallory/.hidden_tools
# Doit afficher : notes.txt

# 9. Vérifier le contenu
cat /home/mallory/.hidden_tools/notes.txt
# Doit afficher le flag : FLAG{susp3ct_us3r_f0und}

# 10. Vérifier le cron de mallory
crontab -u mallory -l
# Doit afficher : */15 * * * * ...exfiltrate.sh

# 11. Vérifier les logs de mallory
grep mallory /var/log/auth.log
# Doit afficher des connexions depuis 203.0.113.66

# ════════════════════════════════════════
# CHALLENGE 4 : SSH Decrypt
# ════════════════════════════════════════

# 12. Vérifier les fichiers dans /var/ctf
ls -la /var/ctf
# Doit afficher : encrypted_message.txt et hint.txt

# 13. Voir le message chiffré
cat /var/ctf/encrypted_message.txt
# Doit afficher : U2FsdGVkX19...

# 14. Tester le déchiffrement
openssl enc -d -aes-256-cbc -base64 -in /var/ctf/encrypted_message.txt -k cyb3rs3cur1ty
# Doit afficher : FLAG{crypt0_m4st3r_unlocked}
```

**✅ CE QUE TU DOIS VOIR :**
```
Challenge 1 : alice + logs + flag1.txt ✅
Challenge 2 : /opt/webapp/config.ini (644) ✅
Challenge 3 : mallory + notes.txt + cron ✅
Challenge 4 : /var/ctf/ + message chiffré ✅
