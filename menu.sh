#!/usr/bin/env bash

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/loiclaforet/server-setup/main"

function show_menu() {
  echo "======================================"
  echo " 🛠️  Ecomdata - Déploiement Serveur"
  echo "======================================"
  echo "1. Installer les mises à jour automatiques (Unattended + Docker)"
  echo "2. Installer Lynis et lancer un audit de sécurité"
  echo "3. Quitter"
  echo "--------------------------------------"
}

while true; do
  show_menu
  read -rp "Choix [1-3] : " choice
  case $choice in
    1)
      echo "Téléchargement et exécution de setup-unattended-prod.sh..."
      bash <(curl -fsSL "$BASE_URL/setup-unattended-prod.sh")
      ;;
    2)
      echo "Téléchargement et exécution de setup-lynis.sh..."
      bash <(curl -fsSL "$BASE_URL/setup-lynis.sh")
      ;;
    3)
      echo "Sortie."
      exit 0
      ;;
    *)
      echo "⛔ Choix invalide, veuillez réessayer."
      ;;
  esac
done
