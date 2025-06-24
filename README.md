# 🛠️ Server Setup Scripts

Scripts automatisés pour configurer rapidement un serveur Ubuntu en production avec :

- ✅ Mises à jour de sécurité automatisées (sans redémarrage)  
- 🔍 Audit de sécurité initial via Lynis

---

## 📜 Scripts disponibles

### 1. Unattended Upgrades + Docker CE

Installe automatiquement les mises à jour de sécurité et le dépôt Docker officiel.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/loiclaforet/server-setup/main/setup-unattended-prod.sh)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/loiclaforet/server-setup/main/setup-lynis.sh)

---

## 🧭 Menu interactif

Lance un menu de choix interactif pour exécuter l’un des scripts :

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/loiclaforet/server-setup/main/menu.sh)



📌 Pré-requis
Ubuntu Server 22.04 ou 24.04 recommandé

Droits root

🧰 Conseils
Ajoutez une tâche cron ou un systemd timer pour relancer l'audit régulièrement.

Pensez à centraliser vos rapports d'audit.

🔒 Auteur
Loïc Laforet – loiclaforet.org
