#!/bin/bash
# Script d'installation et de configuration de l'audit Lynis avec envoi de rapport par mail

set -e

HOSTNAME=$(hostname -f)
MAILTO="l-laforet@loiclaforet.org"
SCRIPT_PATH="/usr/local/sbin/audit-lynis.sh"
SERVICE_PATH="/etc/systemd/system/audit-lynis.service"
TIMER_PATH="/etc/systemd/system/audit-lynis.timer"

echo "==> Installation de Lynis si absent"
apt-get update -qq
apt-get install -y lynis mailutils

echo "==> Création du script d'audit : $SCRIPT_PATH"
cat <<EOF > "$SCRIPT_PATH"
#!/bin/bash
# Script d'audit de sécurité via Lynis avec rapport par mail

HOSTNAME=\$(hostname -f)
DATE=\$(date +"%Y-%m-%d %H:%M")
MAILTO="$MAILTO"

RESULT=\$(lynis audit system --cronjob 2>&1)

printf "%s\\n\\n%s" "[LYNIS] Audit du \$DATE sur \$HOSTNAME" "\$RESULT" \
    | mail -s "[LYNIS] Audit de sécurité sur \$HOSTNAME" "\$MAILTO"
EOF
chmod +x "$SCRIPT_PATH"

echo "==> Création de l'unité systemd : $SERVICE_PATH"
cat <<EOF > "$SERVICE_PATH"
[Unit]
Description=Audit de sécurité via Lynis

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
EOF

echo "==> Création du timer systemd : $TIMER_PATH"
cat <<EOF > "$TIMER_PATH"
[Unit]
Description=Audit hebdomadaire Lynis chaque semaine à 4h

[Timer]
OnCalendar=weekly
Persistent=true
AccuracySec=1h
RandomizedDelaySec=30m

[Install]
WantedBy=timers.target
EOF

echo "==> Activation et démarrage du timer"
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now audit-lynis.timer

echo "==> État du timer"
systemctl list-timers audit-lynis.timer

echo "==> Installation et configuration terminées pour Lynis avec audit hebdomadaire à 4h"
