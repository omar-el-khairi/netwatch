#!/usr/bin/env python3
"""
Agent de supervision — collecte CPU, RAM, disque, uptime, services
et envoie les métriques au backend (Linux & Windows).
"""

from __future__ import annotations

import json
import platform
import socket
import sys
import time
from pathlib import Path

try:
    import psutil
    import requests
except ImportError:
    print("Installez les dépendances: pip install -r requirements.txt", file=sys.stderr)
    sys.exit(1)

CONFIG_PATH = Path(__file__).with_name("config.json")


def load_config() -> dict:
    if not CONFIG_PATH.exists():
        example = Path(__file__).with_name("config.example.json")
        raise FileNotFoundError(
            f"Fichier {CONFIG_PATH} manquant. Copiez {example.name} vers config.json"
        )
    with CONFIG_PATH.open(encoding="utf-8") as f:
        return json.load(f)


def disk_usage_percent() -> float:
    system = platform.system().lower()
    root = "C:\\" if system == "windows" else "/"
    try:
        return float(psutil.disk_usage(root).percent)
    except Exception:
        # fallback first partition
        parts = psutil.disk_partitions(all=False)
        if not parts:
            return 0.0
        return float(psutil.disk_usage(parts[0].mountpoint).percent)
    


def check_services(required: list[str]) -> list[dict]:
    """Vérifie si des services/processus requis sont actifs."""
    results = []
    running_names = {p.info["name"].lower() for p in psutil.process_iter(["name"]) if p.info["name"]}

    for name in required:
        key = name.lower()
        running = any(key in n for n in running_names)
        # Sur Windows, tenter aussi via service name si possible
        if not running and platform.system().lower() == "windows":
            try:
                import subprocess

                out = subprocess.check_output(
                    ["sc", "query", name],
                    stderr=subprocess.DEVNULL,
                    text=True,
                    timeout=5,
                )
                running = "RUNNING" in out
            except Exception:
                pass
        results.append({"name": name, "running": running, "required": True})
    return results

def collect_metrics(required_services: list[str]) -> dict:
    # Première lecture CPU pour initialiser (non bloquante ensuite)
    cpu = psutil.cpu_percent(interval=0.5)
    ram = psutil.virtual_memory().percent
    disk = disk_usage_percent()
    boot = psutil.boot_time()
    uptime = int(time.time() - boot)

    return {
        "hostname": socket.gethostname(),
        "os": platform.system().lower(),
        "cpuPercent": round(cpu, 2),
        "ramPercent": round(ram, 2),
        "diskPercent": round(disk, 2),
        "uptimeSeconds": uptime,
        "services": check_services(required_services),
        "collectedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }



def send_metrics(backend_url: str, api_key: str, payload: dict) -> None:
    url = backend_url.rstrip("/") + "/api/metrics"
    headers = {
        "Content-Type": "application/json",
        "X-API-Key": api_key,
    }
    resp = requests.post(url, json=payload, headers=headers, timeout=10)
    resp.raise_for_status()
    data = resp.json()
    print(
        f"[{payload['collectedAt']}] CPU={payload['cpuPercent']}% "
        f"RAM={payload['ramPercent']}% DISK={payload['diskPercent']}% "
        f"-> status={data.get('status')}",
        flush=True,
    )


def main() -> None:
    config = load_config()
    backend_url = config.get("backendUrl", "http://127.0.0.1:4000")
    api_key = config.get("apiKey", "")
    interval = max(2, int(config.get("intervalSeconds", 5)))
    required = config.get("requiredServices") or []

    if not api_key or api_key.startswith("REPLACE"):
        print(
            "Configurez apiKey dans agents/config.json (clé affichée après npm run seed).",
            file=sys.stderr,
        )
        sys.exit(1)

    print(f"Agent demarre -> {backend_url} (intervalle {interval}s)", flush=True)
    print(f"Host={socket.gethostname()} OS={platform.system()}", flush=True)

    # Warm-up CPU counter
    psutil.cpu_percent(interval=None)

    while True:
        try:
            metrics = collect_metrics(required)
            send_metrics(backend_url, api_key, metrics)
        except requests.RequestException as exc:
            print(f"[erreur reseau] {exc}", file=sys.stderr)
        except Exception as exc:
            print(f"[erreur] {exc}", file=sys.stderr)
        time.sleep(interval)


if __name__ == "__main__":
    main()
