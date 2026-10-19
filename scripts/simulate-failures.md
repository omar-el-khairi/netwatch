# Simulations de pannes (Phase 7) — KPI temps de réaction

Objectif : mesurer le délai entre l'incident et l'alerte sur dashboard/mobile (**cible < 30 s**).

Prérequis :
- Backend lancé (`cd backend && npm run dev`)
- Dashboard ouvert (http://localhost:5173)
- Agent actif sur la machine ciblée

---

## 1. Charge CPU élevée — CentOS (VM)

```bash
# Installer l'outil de stress
sudo dnf install -y stress-ng
# ou : sudo yum install -y stress-ng

# Lancer une charge CPU pendant 60 secondes
date '+%H:%M:%S.%N'   # <-- noter l'heure de début
stress-ng --cpu 4 --timeout 60s
```

**Attendu** : alerte `CPU_HIGH` (warning puis critical) sur le dashboard en < 30 s.

Remplir le tableau KPI :

| Incident | Heure début | Heure alerte | Δt (s) |
|----------|-------------|--------------|--------|
| CPU_HIGH |             |              |        |

---

## 2. Charge CPU — Windows (Serveur Démo Local)

PowerShell :

```powershell
Get-Date -Format 'HH:mm:ss.fff'   # heure début
1..4 | ForEach-Object {
  Start-Job { while ($true) { $null = 1..5e5 | ForEach-Object { $_ * $_ } } }
}
Start-Sleep -Seconds 60
Get-Job | Stop-Job
Get-Job | Remove-Job
```

---

## 3. Arrêt d'un service surveillé (CentOS)

1. Dans `~/supervision/agents/config.json` :

```json
"requiredServices": ["sshd"]
```

2. Redémarrer l'agent, puis :

```bash
date '+%H:%M:%S'
sudo systemctl stop sshd
# ⚠ tu perdras SSH : utilise la console VMware pour relancer :
# sudo systemctl start sshd
```

Pour un test plus sûr, surveille un service non critique (ex. `chronyd`) :

```bash
sudo systemctl stop chronyd
```

**Attendu** : alerte `SERVICE_DOWN`.

---

## 4. Serveur injoignable

```bash
# Sur CentOS : arrêter l'agent (Ctrl+C)
# Noter l'heure
date '+%H:%M:%S'
```

Attendre ~30 s (`HEARTBEAT_TIMEOUT_SECONDS` dans `backend/.env`).

**Attendu** : statut `down` + alerte `SERVER_DOWN` sur dashboard.

Relancer ensuite :

```bash
cd ~/supervision/agents
source .venv/bin/activate   # si venv
python3 -u agent.py
```

---

## 5. Fiche KPI soutenance (à copier dans le rapport)

| # | Scénario | Machine | Δt mesuré | Résultat |
|---|----------|---------|-----------|----------|
| 1 | CPU élevé | CentOS | … s | OK / KO |
| 2 | CPU élevé | Windows | … s | OK / KO |
| 3 | Service down | CentOS | … s | OK / KO |
| 4 | Serveur down | CentOS | … s | OK / KO |

Critère de réussite : **Δt < 30 secondes** pour chaque scénario.
