# Guide bascule SQLite → PostgreSQL

## Prérequis
- PostgreSQL 16+ installé et service démarré
- Base `supervision` créée
- Utilisateur avec mot de passe (ex. `postgres` / ton mot de passe)

## Étapes

1. Éditer `backend/.env` :

```env
DATABASE_URL="postgresql://postgres:MOT_DE_PASSE@localhost:5432/supervision?schema=public"
```

2. Dans `backend/prisma/schema.prisma` :

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

3. Appliquer le schéma + seed :

```powershell
cd backend
npx prisma migrate reset --force
# ou si première fois sur PG :
npx prisma migrate dev --name init_pg
npm run seed
npm run dev
```

4. Vérifier : http://127.0.0.1:4000/api/health puis login dashboard.

## Note
Les données SQLite (`prisma/dev.db`) ne sont **pas** migrées automatiquement.
Après bascule, recreer les serveurs dans le dashboard et remettre les `apiKey` dans les agents.
