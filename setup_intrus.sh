#!/usr/bin/env bash
# setup_intrus.sh - Prépare l'environnement "intrus" pour TP (version propre)
# Sauvegarde le script localement, lis-le avant exécution. NE PAS pipe directement depuis internet sans vérif.
set -euo pipefail
IFS=$'\n\t'

# ---------- Configuration ----------
INTRUS_USER="hacker"
TMPDIR="/tmp/.hidden_intrus"
HTTP_PORT=8888
EXFIL_LOG="${TMPDIR}/exfiltrate.log"
EXFIL_SCRIPT="${TMPDIR}/exfiltrate.sh"
CRON_SCHEDULE="*/5 * * * *"

# ---------- Fonctions utilitaires ----------
err() { echo "Erreur: $*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "La commande requise '$1' est introuvable. Installe-la d'abord."
}

# ---------- Vérifications préalables ----------
# Doit être root
if [ "$(id -u)" -ne 0 ]; then
  err "Ce script doit être exécuté en root (sudo)."
fi

# Vérifier les commandes dont on a besoin
for c in useradd chpasswd su python3 ss crontab logger pgrep; do
  require_cmd "$c"
done

# ---------- Création de l'utilisateur intrus (si nécessaire) ----------
if id -u "$INTRUS_USER" >/dev/null 2>&1; then
  echo "Utilisateur '$INTRUS_USER' existe déjà — pas de création."
else
  echo "Création de l'utilisateur '$INTRUS_USER'..."
  useradd -m -s /bin/bash "$INTRUS_USER"
  # générer un mot de passe aléatoire mais ne pas l'afficher
  PASS="$(head -c 48 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | cut -c1-14)"
  echo "${INTRUS_USER}:${PASS}" | chpasswd
  # registre optionnel: on garde le mot de passe hors sortie visible (journal interne seulement si besoin)
  # echo "Mot de passe pour $INTRUS_USER généré (non affiché)."
fi

# ---------- Préparer le répertoire d'indices (permissions restreintes) ----------
mkdir -p "$TMPDIR"
chown "$INTRUS_USER:$INTRUS_USER" "$TMPDIR"
chmod 700 "$TMPDIR"

# Placer un fichier d'indices "sécurisé" (hashs ou indices), PAS de réponses en clair
cat > "$TMPDIR/data.txt" <<'EOF'
# Indices (exemples hachés) - ne contiennent pas les réponses directes
admin:$6$examplehash1
root:$6$examplehash2
service:$6$examplehash3
EOF
chown "$INTRUS_USER:$INTRUS_USER" "$TMPDIR/data.txt"
chmod 600 "$TMPDIR/data.txt"

# ---------- Script d'exfiltration factice (ne fait rien de dangereux) ----------
cat > "$EXFIL_SCRIPT" <<'SH'
#!/bin/sh
# Script factice d'exfiltration : n'exfiltre rien de sensible, écrit juste un horodatage local
echo "$(date +%s) - placeholder exfil" >> "${EXFIL_LOG}"
SH
chown "$INTRUS_USER:$INTRUS_USER" "$EXFIL_SCRIPT"
chmod 700 "$EXFIL_SCRIPT"
touch "$EXFIL_LOG"
chown "$INTRUS_USER:$INTRUS_USER" "$EXFIL_LOG"
chmod 600 "$EXFIL_LOG"

# ---------- Démarrer un serveur HTTP propre en arrière-plan sous l'utilisateur intrus ----------
# Vérifier si un serveur existe déjà
if pgrep -f "python3 -m http.server ${HTTP_PORT} --directory ${TMPDIR}" >/dev/null 2>&1; then
  echo "Serveur HTTP déjà en cours pour ${INTRUS_USER} sur le port ${HTTP_PORT}."
else
  echo "Démarrage du serveur HTTP (port ${HTTP_PORT}) sous l'utilisateur ${INTRUS_USER}..."
  # Utiliser su -c + nohup pour disparaitre proprement
  su - "$INTRUS_USER" -c "nohup python3 -m http.server ${HTTP_PORT} --directory ${TMPDIR} >/dev/null 2>&1 &"
  sleep 1
fi

# ---------- Ajouter une entrée cron factice (si absente) ----------
# On ajoute une tâche innocente exécutant le script factice toutes les 5 minutes
CRON_LINE="${CRON_SCHEDULE} ${EXFIL_SCRIPT}"
# Lire la crontab existante (silencieusement)
CURRENT_CRON="$(crontab -u "$INTRUS_USER" -l 2>/dev/null || true)"
if echo "$CURRENT_CRON" | grep -Fq "$EXFIL_SCRIPT"; then
  echo "La tâche cron factice existe déjà pour $INTRUS_USER."
else
  printf "%s\n%s\n" "$CURRENT_CRON" "$CRON_LINE" | crontab -u "$INTRUS_USER" -
  echo "Tâche cron factice ajoutée pour $INTRUS_USER."
fi

# ---------- Entrées de log factices (facultatives et non dangereuses) ----------
logger -t intrus "entry: simulated login for $INTRUS_USER from 203.0.113.50"
logger -t intrus "entry: simulated sudo attempt by $INTRUS_USER"

# ---------- Vérifications finales (affichées proprement) ----------
echo
echo "✅ Environnement 'intrus' prêt."
echo "Vérifications :"

printf "1) Utilisateur '%s' : " "$INTRUS_USER"
if id -u "$INTRUS_USER" >/dev/null 2>&1; then echo "OK"; else echo "MANQUANT"; fi

printf "2) Fichiers dans %s : " "$TMPDIR"
if [ -d "$TMPDIR" ] && [ "$(ls -A "$TMPDIR")" ]; then echo "OK"; else echo "VIDE"; fi

printf "3) Processus python (port %s) : " "$HTTP_PORT"
if pgrep -f "python3 -m http.server ${HTTP_PORT}" >/dev/null 2>&1; then
  echo "OK"
else
  echo "ABSENT"
fi

printf "4) Port %s écouté (tcp) : " "$HTTP_PORT"
if ss -tulpn 2>/dev/null | grep -q ":${HTTP_PORT} "; then echo "OK"; else echo "NON"; fi

echo
echo "Notes :"
echo "- Les réponses du TP ne sont PAS écrites en clair dans ${TMPDIR}."
echo "- Pour distribuer ce script à des étudiants : téléchargez, lisez, puis exécutez (ex : curl -o setup_intrus.sh <url> ; less setup_intrus.sh ; sudo bash ./setup_intrus.sh)."
exit 0
