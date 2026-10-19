# Guide de soutenance — démonstration

## Compte démo
- Email : `admin@supervision.local`
- Mot de passe : `Admin123!`

## Scénario recommandé (10–12 min)

1. **Contexte** (1 min) — problème réactif vs supervision proactive.
2. **Architecture** (2 min) — agents → backend → dashboard/mobile (schéma docs/).
3. **Live dashboard** (3 min) — login, liste serveurs (vert), détail graphiques live.
4. **Simulation panne** (3 min) — stress CPU ou arrêt agent → alerte rouge < 30 s.
5. **Mobile** (2 min) — liste serveurs + alertes sur Android.
6. **Bilan** (1 min) — KPI temps de réaction, perspectives (FCM, PostgreSQL, SNMP).

## Démarrage rapide Windows

```bat
scripts\start-all.bat
```

Ou manuellement 3 terminaux :
1. `cd backend && npm run dev`
2. `cd dashboard && npm run dev`
3. `cd agents && python -u agent.py`

Dashboard : http://localhost:5173
