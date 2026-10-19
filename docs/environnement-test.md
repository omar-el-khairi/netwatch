# Environnement de test (Phase 2)

## Prérequis machine de développement

- Node.js 20+
- Python 3.10+
- Git
- Flutter (pour le mobile)
- VirtualBox ou VMware (pour les VM cibles)
- Optionnel : Docker (PostgreSQL) / PostgreSQL natif

## Réseau VM recommandé

1. Créer un réseau **Host-Only** ou **Bridge** dans VirtualBox.
2. VM Ubuntu Server × 2–3 : IP fixes (ex. `192.168.56.10`, `.11`, `.12`).
3. VM Windows Server × 1–2 : IP fixes (ex. `192.168.56.20`).
4. Machine host (dev) : backend sur `0.0.0.0:4000` pour être joignable depuis les VM.

Dans `agents/config.json` sur chaque VM :

```json
{
  "backendUrl": "http://192.168.56.1:4000",
  "apiKey": "<clé du serveur créé dans le dashboard>",
  "intervalSeconds": 5
}
```

## Installation agent Ubuntu

```bash
sudo apt update && sudo apt install -y python3 python3-venv python3-pip
cd /opt && sudo git clone <repo> supervision && cd supervision/agents
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp config.example.json config.json
# éditer config.json
python agent.py
# ou systemd : voir agents/supervision-agent.service
```

## Installation agent Windows

```powershell
cd C:\supervision\agents
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
copy config.example.json config.json
# éditer config.json
python agent.py
```

## Simulations de panne (Phase 7)

Voir `scripts/simulate-failures.md`.
