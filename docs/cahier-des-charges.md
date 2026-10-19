# Cahier des charges — Plateforme de Supervision Réseau

## 1. Contexte

Dans les infrastructures informatiques, la disponibilité des serveurs conditionne la continuité d'activité. Un mode purement réactif (constat après signalement utilisateur) expose l'organisation à des pertes de productivité. Ce projet propose une plateforme de supervision temps réel pour Linux et Windows.

## 2. Objectifs

1. Collecte continue des métriques (CPU, RAM, disque, latence, services, uptime).
2. Centralisation et traitement temps réel côté backend.
3. Alertes automatiques dès dépassement de seuil ou indisponibilité.
4. Dashboard web (graphiques, statuts, historique).
5. Application mobile (consultation + notifications push).

## 3. Exigences fonctionnelles

| ID | Exigence | Priorité |
|----|----------|----------|
| RF01 | Enregistrement / gestion des serveurs surveillés | Haute |
| RF02 | Réception périodique des métriques depuis les agents | Haute |
| RF03 | Comparaison aux seuils (CPU, RAM, disque) | Haute |
| RF04 | Détection serveur injoignable (absence de heartbeat) | Haute |
| RF05 | Génération et historisation des alertes | Haute |
| RF06 | Diffusion temps réel des alertes (WebSocket) | Haute |
| RF07 | Authentification des administrateurs (JWT) | Haute |
| RF08 | Visualisation liste + détail serveur avec graphiques | Haute |
| RF09 | Consultation historique des alertes | Moyenne |
| RF10 | Configuration des seuils par défaut / par serveur | Moyenne |
| RF11 | Application mobile : liste serveurs et alertes | Moyenne |
| RF12 | Notifications push sur alerte critique | Moyenne |

## 4. Exigences non fonctionnelles

| ID | Exigence |
|----|----------|
| RNF01 | Temps de réaction alerte < 30 s (KPI soutenance) |
| RNF02 | Support multi-OS agents (Linux + Windows) |
| RNF03 | API REST documentée et sécurisée (JWT) |
| RNF04 | Scalabilité : au moins 10 serveurs simultanés en environnement de test |
| RNF05 | Interface dashboard démontrable en soutenance |
| RNF06 | Code versionné Git, structure modulaire |

## 5. Périmètre hors scope (V1)

- Découverte automatique SNMP avancée
- Intégration Zabbix/Nagios
- Haute disponibilité multi-nœuds du backend
- iOS (focus Android pour la démo)

## 6. Acteurs

- **Administrateur** : gère serveurs, seuils, consulte dashboard/mobile
- **Agent** : logiciel installé sur chaque machine surveillée
- **Système** : moteur de seuils et de détection d'indisponibilité

## 7. Stack technique retenue

- Agents : Python + psutil
- Backend : Node.js + Express + Prisma + Socket.IO + JWT
- BDD : PostgreSQL (prod) / SQLite (dev)
- Dashboard : React (Vite) + Recharts
- Mobile : Flutter + BLoC (+ FCM optionnel)
