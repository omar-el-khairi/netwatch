# Schéma de base de données (PostgreSQL)

## Connexion

```
Host: 127.0.0.1
Port: 5432
Database: supervision
User: supervision
Password: supervision
```

URL Prisma :
```
postgresql://supervision:supervision@127.0.0.1:5432/supervision?schema=public
```

## Voir les tables

### Option A — Prisma Studio
```bash
cd backend
npx prisma studio
```

### Option B — psql
```bash
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U supervision -h 127.0.0.1 -d supervision
```
Puis : `\dt` (lister), `SELECT * FROM "User";`

### Option C — pgAdmin 4
Connexion au serveur local → base `supervision` → Schemas → public → Tables

## Tables

### User
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | TEXT | PK |
| email | TEXT | UNIQUE, NOT NULL |
| passwordHash | TEXT | NOT NULL |
| name | TEXT | |
| role | TEXT | DEFAULT 'admin' |
| createdAt | TIMESTAMP | |

### Server
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | TEXT | PK |
| name | TEXT | NOT NULL |
| hostname | TEXT | NOT NULL |
| ipAddress | TEXT | NOT NULL |
| osType | TEXT | linux / windows |
| apiKey | TEXT | UNIQUE |
| status | TEXT | online / warning / critical / down / pending |
| lastSeenAt | TIMESTAMP | nullable |
| createdAt / updatedAt | TIMESTAMP | |

### Metric
| Colonne | Type |
|---------|------|
| id | TEXT PK |
| serverId | FK → Server |
| cpuPercent, ramPercent, diskPercent | FLOAT |
| pingMs | FLOAT nullable |
| uptimeSeconds | INT |
| servicesJson | TEXT |
| collectedAt | TIMESTAMP |

### Alert
| Colonne | Type |
|---------|------|
| id | TEXT PK |
| serverId | FK → Server |
| type | CPU_HIGH, RAM_HIGH, DISK_HIGH, SERVICE_DOWN, SERVER_DOWN |
| severity | warning / critical |
| message | TEXT |
| value | FLOAT nullable |
| acknowledged | BOOLEAN |
| createdAt | TIMESTAMP |

### Threshold
| Colonne | Type |
|---------|------|
| id | TEXT PK |
| serverId | FK nullable (null = global) |
| metricType | cpu / ram / disk |
| warning, critical | FLOAT |
| createdAt / updatedAt | TIMESTAMP |
