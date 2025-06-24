#!/usr/bin/env bash
# ------------------------------------------------------------------
# setup-unattended-prod.sh
# Configure unattended-upgrades + Docker CE sur une Ubuntu serveur
# Production : pas de reboot automatique
# ------------------------------------------------------------------

set -euo pipefail
CODENAME=$(lsb_release -sc)
EMAIL="l-laforet@loiclaforet.org"          # <-- adapte si besoin
BACKUP_DIR="/root/apt-backups-$(date +%F)"

echo "==> Installation des paquets requis"
apt-get update -qq
apt-get install -y unattended-upgrades bsd-mailx ca-certificates curl gnupg

echo "==> Sauvegarde des fichiers de conf existants"
mkdir -p "$BACKUP_DIR"
for f in /etc/apt/apt.conf.d/50unattended-upgrades \
         /etc/apt/apt.conf.d/20auto-upgrades; do
  [ -f "$f" ] && cp -a "$f" "$BACKUP_DIR/"
done

echo "==> Ajout (si absent) du dépôt Docker CE"
if ! grep -q "^deb .*download.docker.com" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
       gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $CODENAME stable" \
      > /etc/apt/sources.list.d/docker.list
fi

echo "==> Actualisation des index APT"
apt-get update -qq

echo "==> Écriture du fichier 50unattended-upgrades"
cat > /etc/apt/apt.conf.d/50unattended-upgrades <
// -----------------------------------------------------------------------------
// 50unattended-upgrades — Configuration production
// -----------------------------------------------------------------------------
Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}";
        "${distro_id}:${distro_codename}-security";
        "${distro_id}:${distro_codename}-updates";
        "Docker:${distro_codename}";
};
Unattended-Upgrade::Package-Blacklist {};
Unattended-Upgrade::DevRelease "false";
Unattended-Upgrade::Mail "$EMAIL";
//Unattended-Upgrade::MailReport "always"; pour test : sudo unattended-upgrade --debug
Unattended-Upgrade::MailReport "on-change";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::SyslogEnable "true";
Unattended-Upgrade::SyslogFacility "daemon";
EOF

echo "==> Écriture du fichier 20auto-upgrades"
cat > /etc/apt/apt.conf.d/20auto-upgrades <
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade  "1";
APT::Periodic::AutocleanInterval   "7";
EOF

echo "==> Activation (sans modifier l’horaire) des timers systemd"
systemctl enable --now apt-daily.timer apt-daily-upgrade.timer

echo "==> Test de syntaxe : unattended-upgrade --dry-run --debug"
unattended-upgrade --dry-run --debug | \
  grep -A2 "Allowed origins are"

echo "==> Test de simulation d’installation (dry-run complet)"
unattended-upgrade --dry-run --debug >/tmp/unattended-dry-run.log 2>&1
echo "  Log détaillé dans /tmp/unattended-dry-run.log"

echo "==> Récapitulatif des timers APT"
systemctl list-timers apt-daily\*

echo "==> Configuration terminée. Aucun redémarrage automatique n'est activé."