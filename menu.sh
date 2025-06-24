#!/usr/bin/env bash

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/loiclaforet/server-setup/main"

function show_menu() {
  echo "======================================"
  echo " 🛠️  Ecomdata - Déploiement Serveur"
  echo "======================================"
  echo "1. Tout installer + Générer rapports (Unattended + Lynis + audits)"
  echo "2. Installer les mises à jour automatiques (Unattended + Docker)"
  echo "3. Installer Lynis et lancer un audit de sécurité"
  echo "4. Quitter"
  echo "--------------------------------------"
}

while true; do
  show_menu
  read -rp "Choix [1-4] : " choice
  case $choice in
    1)
      echo "Installation des mises à jour automatiques..."
      bash <(curl -fsSL "$BASE_URL/setup-unattended-prod.sh")
      echo "Génération du rapport Unattended immédiatement..."
      unattended-upgrade --dry-run --debug | grep -A2 "Allowed origins are" | mail -s "[UNATTENDED] Rapport immédiat" root

      echo "Installation de Lynis..."
      bash <(curl -fsSL "$BASE_URL/setup-lynis.sh")

      echo "Lancement d’un audit complet Lynis maintenant..."
      /usr/local/sbin/audit-lynis.sh
      ;;
    2)
      echo "Téléchargement et exécution de setup-unattended-prod.sh..."
      bash <(curl -fsSL "$BASE_URL/setup-unattended-prod.sh")
      ;;
    3)
      echo "Téléchargement et exécution de setup-lynis.sh..."
      bash <(curl -fsSL "$BASE_URL/setup-lynis.sh")
      ;;
    4)
      echo "Sortie."
      exit 0
      ;;
    *)
      echo "⛔ Choix invalide, veuillez réessayer."
      ;;
  esac
done
