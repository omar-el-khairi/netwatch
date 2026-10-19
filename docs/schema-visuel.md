# Schéma visuel — Base de données PostgreSQL (NetWatch)

## Diagramme entité-relation (Mermaid)

Copie ce bloc sur [https://mermaid.live](https://mermaid.live) → **Export PNG/SVG** pour Word.

```mermaid
erDiagram
    User {
        uuid id PK
        string email UK
        string passwordHash
        string name
        string role
        datetime createdAt
    }

    Server {
        uuid id PK
        string name
        string hostname
        string ipAddress
        string osType
        string apiKey UK
        string status
        datetime lastSeenAt
        datetime createdAt
        datetime updatedAt
    }

    Metric {
        uuid id PK
        uuid serverId FK
        float cpuPercent
        float ramPercent
        float diskPercent
        float pingMs
        int uptimeSeconds
        string servicesJson
        datetime collectedAt
    }

    Alert {
        uuid id PK
        uuid serverId FK
        string type
        string severity
        string message
        float value
        boolean acknowledged
        datetime createdAt
    }

    Threshold {
        uuid id PK
        uuid serverId FK "nullable"
        string metricType
        float warning
        float critical
        datetime createdAt
        datetime updatedAt
    }

    Device {
        uuid id PK
        string token UK
        string platform
        uuid userId
        datetime createdAt
        datetime updatedAt
    }

    Server ||--o{ Metric : "envoie"
    Server ||--o{ Alert : "génère"
    Server ||--o{ Threshold : "seuils"
```

## Légende des relations

| Relation | Signification |
|----------|---------------|
| Server → Metric | 1 serveur, N métriques (historique CPU/RAM/disque) |
| Server → Alert | 1 serveur, N alertes |
| Server → Threshold | 1 serveur, 0..N seuils (null = global) |
| User | Comptes administrateurs (JWT) |
| Device | Tokens push mobile (FCM optionnel) |

## Statuts serveur (`Server.status`)

`pending` · `online` · `warning` · `critical` · `down`

## Types d'alerte (`Alert.type`)

`CPU_HIGH` · `RAM_HIGH` · `DISK_HIGH` · `SERVICE_DOWN` · `SERVER_DOWN`

## Index principaux

- `Metric(serverId, collectedAt)`
- `Alert(serverId, createdAt)`
- `Threshold(serverId, metricType)`
- `Server(apiKey)` UNIQUE

## Vue d'ensemble (architecture données)

```
┌─────────┐     ┌──────────┐     ┌─────────┐
│  User   │     │  Device  │     │Threshold│
└─────────┘     └──────────┘     └────┬────┘
                                      │ serverId?
                                      ▼
                               ┌──────────────┐
                               │    Server    │
                               └──────┬───────┘
                    ┌────────────────┼────────────────┐
                    ▼                ▼                ▼
              ┌─────────┐     ┌─────────┐     (seuils)
              │ Metric  │     │  Alert  │
              └─────────┘     └─────────┘
```
