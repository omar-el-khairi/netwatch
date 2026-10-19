# Plateforme de Supervision Réseau en Temps Réel

Projet de Fin d'Année — **MST-RSI**, FST Settat  
Étudiant : **Omar El Khairi**

Surveillance continue de serveurs Linux & Windows : agents → backend → dashboard web + application mobile, avec alertes temps réel.

## Architecture

```
[Agents Python] --HTTP POST /api/metrics--> [Backend Express + Socket.IO]
                                                    |
                                              [PostgreSQL]
                                                    |
                    +-------------------------------+-------------------------------+
                    |                                                               |
            [Dashboard React]                                              [App Flutter]
            REST + WebSocket                                               REST + FCM
```

## Stack

| Composant | Technologie |
|-----------|-------------|
| Agents | Python 3 + psutil |
| Backend | Node.js, Express, Prisma, Socket.IO, JWT |
| Base de données | **PostgreSQL** |
| Dashboard | React (Vite) + Recharts + Socket.IO client |
| Mobile | Flutter + BLoC |

## Démarrage rapide (machine de développement)

### 0. PostgreSQL
Service `postgresql-x64-16` démarré. Base `supervision` / user `supervision` / mdp `supervision`.  
Voir les tables : `cd backend && npx prisma studio` ou pgAdmin 4.

### 1. Backend

```bash
cd backend
npm install
npx prisma migrate dev
npm run seed
npm run dev
```

API : http://localhost:4000  
Health : http://localhost:4000/api/health

Compte démo : `admin@supervision.local` / `Admin123!`

### 2. Dashboard

```bash
cd dashboard
npm install
npm run dev
```

UI : http://localhost:5173

### 3. Agent (sur cette machine ou une VM)

```bash
cd agents
python -m venv .venv
# Windows:
.venv\Scripts\activate
pip install -r requirements.txt
copy config.example.json config.json
python agent.py
```

### 4. Mobile Flutter

```bash
cd mobile
flutter pub get
flutter run
```

## Structure du dépôt

```
PFA/
├── docs/           # Cahier des charges, use cases, schéma DB, UML
├── backend/        # API REST + Socket.IO + Prisma
├── agents/         # Collecte métriques Linux/Windows
├── dashboard/      # Interface web React
├── mobile/         # Application Flutter
├── scripts/        # Simulations de panne / stress
└── docker-compose.yml
```

## Endpoints principaux

| Méthode | Route | Description |
|---------|-------|-------------|
| POST | `/api/auth/login` | Connexion JWT |
| GET | `/api/servers` | Liste des serveurs |
| POST | `/api/servers` | Enregistrer un serveur |
| GET | `/api/servers/:id` | Détail + dernières métriques |
| POST | `/api/metrics` | Réception métriques (agent) |
| GET | `/api/alerts` | Historique des alertes |
| GET/PUT | `/api/thresholds` | Seuils d'alerte |
| GET | `/api/metrics/:serverId` | Historique pour graphiques |

## Événements Socket.IO

- `alert:new` — nouvelle alerte
- `server:update` — statut / dernière métrique d'un serveur
- `metric:new` — point de métrique pour graphiques live

## Phases du projet

Voir `docs/` pour le détail Phase 1 → 7 (conception, VMs, backend, agents, dashboard, mobile, tests).

## Licence

Projet académique — FST Settat / MST-RSI.
