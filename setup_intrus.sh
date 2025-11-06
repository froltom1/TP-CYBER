#!/usr/bin/env bash
set -euo pipefail
# setup_intrus.sh - À exécuter 5 min avant le TP3
# Version corrigée : gère CRLF, vérifie pré-requis, n'expose pas de réponses en clair.

# --- helper pour garantir LF si on exécute directement le script pipé ---
# (utile si l'étudiant fait curl ... | bash) => va enlever \r dans le flux
# NOTE: si tu exécutes le fichier localement, dos2unix ou sed est préféré.
tr -d '\r' > /tmp/_setup_intrus$$ <<'__END__'
# placeholder - le vrai contenu sera remplacé par la suite après nettoyage
__END__
# Remplace le placeholder par le vrai contenu nettoyé en mémoire si pipé; si non, on continue

# Vérifier qu'on est root
if [ "$(id -u)" -ne 0 ]; then
  echo "Ce script doit être exécuté en root"
  exit 1
fi

# Vérifier outils essentiels
for cmd in useradd chpasswd su python3 ss crontab; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Commande manquante : $cmd. Installe-la d'abord."
    exit 1
  fi
done

# Paramètres
INTRUS_USER="hacker"
TMPDIR="/tmp/.hidden_intrus"
HTTP_PORT=8888

# Créer un utilisateur suspect (si n'existe pas)
if ! id -u "$INTRUS_USER" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$INTRUS_USER"
  # mot de passe aléatoire (pas en clair dans le fichier)
  PASS="$(head -c12 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | cut -c1-12)"
  echo "${INTRUS_USER}:${PASS}" | chpasswd
  # on n'affiche PAS le mot de passe pour que les étudiants ne le voient pas
fi

# Créer les fichiers suspects (avec permissions restreintes)
mkdir -p "$TMPDIR"
# *ne pas* écrire les réponses en clair ; on écrit un fichier chiffré ou masqué.
# Ici on place des indices pour l'exercice (ex: hachés) au lieu des réponses directes.
cat > "$TMPDIR/data.txt" <<'EOF'
# Indices (hachés) - débloquez en appliquant l'algorithme demandé dans le TP
admin:$6$hash_example_admin
root:$6$hash_example_root
webmaster:$6$hash_example_web
EOF
chown -R "$INTRUS_USER:$INTRUS_USER" "$TMPDIR"
chmod -R 700 "$TMPDIR"

# Lancer un HTTP server en tant que l'utilisateur intrus (démon propre)
# On utilise nohup pour détacher proprement et s'assurer que le processus survive
# à la fermeture du shell; redirection vers /dev/null pour silence.
if ! pgrep -f "python3 -m http.server ${HTTP_PORT} --directory ${TMPDIR}" >/dev/null 2>&1; then
  su - "$INTRUS_USER" -c "nohup python3 -m http.server ${HTTP_PORT} --directory ${TMPDIR} >/dev/null 2>&1 &"
  sleep 2
fi

# Ajouter une entrée syslog factice (optionnel; attention aux logs système)
logger -t intrus "sshd: Accepted password for ${INTRUS_USER} from 203.0.113.50 port 12345 ssh2"
logger -t intrus "sudo: ${INTRUS_USER} : user NOT in sudoers ; TTY=pts/2 ; PWD=/home/${INTRUS_USER} ; USER=root ; COMMAND=/bin/cat /etc/shadow"

# Créer une tâche cron pour l'utilisateur intrus si elle n'existe pas
CRON_JOB="*/5 * * * * /tmp/.hidden_intrus/exfiltrate.sh"
# on construit la crontab actuelle (vide si absente) puis on ajoute la tâche si manquante
CURRENT_CRONTAB="$(crontab -u "$INTRUS_USER" -l 2>/dev/null || true)"
if ! grep -Fxq "$CRON_JOB" <<< "$CURRENT_CRONTAB"; then
  ( printf '%s\n' "$CURRENT_CRONTAB" "$CRON_JOB" ) | crontab -u "$INTRUS_USER" -
fi

# Création d'un script d'exfiltration factice (ne fait rien dangereux)
cat > /tmp/.hidden_intrus/exfiltrate.sh <<'SH'
#!/bin/sh
# script d'exfiltration factice (ne fait rien)
clock="$(date +%s)"
echo "exfiltrate placeholder $clock" >> /tmp/.hidden_intrus/exfiltrate.log
SH
chown "$INTRUS_USER:$INTRUS_USER" /tmp/.hidden_intrus/exfiltrate.sh /tmp/.hidden_intrus/exfiltrate.log
chmod 700 /tmp/.hidden_intrus/exfiltrate.sh

# Affichage de vérifications (propres)
echo "✅ Environnement 'intrus' créé (sanitized)"
echo ""
echo "Vérifications :"
printf "1. Utilisateur %s : " "$INTRUS_USER"
if id -u "$INTRUS_USER" >/dev/null 2>&1; then echo "✅"; else echo "❌"; fi

printf "2. Fichiers dans %s : " "$TMPDIR"
if [ -d "$TMPDIR" ] && [ "$(ls -A "$TMPDIR")" ]; then echo "✅"; else echo "❌"; fi

printf "3. Processus python (port %s) : " "$HTTP_PORT"
if pgrep -f "python3 -m http.server ${HTTP_PORT}" >/dev/null 2>&1; then echo "✅"; else echo "❌"; fi

printf "4. Port %s ouvert : " "$HTTP_PORT"
if ss -tulpn 2>/dev/null | grep -q ":${HTTP_PORT} "; then echo "✅"; else echo "❌"; fi

exit 0
