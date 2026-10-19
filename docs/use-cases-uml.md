# Cas d'utilisation

## UC01 — Connexion administrateur
- **Acteur** : Administrateur
- **Précondition** : Compte créé
- **Flux** : Saisie email/mot de passe → JWT → accès dashboard/API

## UC02 — Ajout d'un serveur
- **Acteur** : Administrateur
- **Flux** : Formulaire (hostname, IP, OS, clé agent) → enregistrement BDD → statut `pending` jusqu'à première métrique

## UC03 — Collecte et envoi de métriques
- **Acteur** : Agent
- **Flux** : Lecture CPU/RAM/disque/uptime/services → POST `/api/metrics` avec API key → stockage → évaluation seuils

## UC04 — Réception d'une alerte
- **Acteur** : Administrateur
- **Flux** : Seuil dépassé ou serveur down → création alerte → événement Socket.IO → affichage dashboard + notif mobile

## UC05 — Consultation liste des serveurs
- **Acteur** : Administrateur
- **Flux** : GET `/api/servers` → pastilles vert/orange/rouge selon statut

## UC06 — Consultation détail serveur (graphiques)
- **Acteur** : Administrateur
- **Flux** : Sélection serveur → historique métriques → courbes CPU/RAM/disque

## UC07 — Consultation historique des alertes
- **Acteur** : Administrateur
- **Flux** : Page alertes filtrable (sévérité, serveur, date) → acquittement optionnel

## UC08 — Configuration des seuils
- **Acteur** : Administrateur
- **Flux** : Modification seuils warning/critical → persistance → prise en compte immédiat

## UC09 — Détection serveur injoignable
- **Acteur** : Système
- **Flux** : Job périodique → si `lastSeenAt` trop ancien → statut `down` + alerte `SERVER_DOWN`

## Diagramme de cas d'utilisation (PlantUML)

```plantuml
@startuml
left to right direction
actor Admin as A
actor Agent as Ag
rectangle "Plateforme Supervision" {
  usecase "Se connecter" as UC1
  usecase "Ajouter serveur" as UC2
  usecase "Envoyer métriques" as UC3
  usecase "Recevoir alerte" as UC4
  usecase "Consulter serveurs" as UC5
  usecase "Voir graphiques" as UC6
  usecase "Historique alertes" as UC7
  usecase "Configurer seuils" as UC8
  usecase "Détecter serveur down" as UC9
}
A --> UC1
A --> UC2
A --> UC4
A --> UC5
A --> UC6
A --> UC7
A --> UC8
Ag --> UC3
UC9 ..> UC4 : <<include>>
@enduml
```

## Diagramme de séquence — flux agent → backend → dashboard

```plantuml
@startuml
actor Agent
participant "API Express" as API
participant "ThresholdService" as TS
database "PostgreSQL/SQLite" as DB
participant "Socket.IO" as IO
actor Dashboard

Agent -> API: POST /api/metrics {cpu, ram, disk...}
API -> DB: INSERT metric + UPDATE server.lastSeenAt
API -> TS: evaluate(metric, thresholds)
alt seuil dépassé
  TS -> DB: INSERT alert
  TS -> IO: emit alert:new
  IO -> Dashboard: push alerte
end
API -> IO: emit server:update / metric:new
IO -> Dashboard: mise à jour live
API --> Agent: 201 Created
@enduml
```

## Diagramme de classes (simplifié)

```plantuml
@startuml
class User {
  id
  email
  passwordHash
  role
}
class Server {
  id
  hostname
  ipAddress
  osType
  apiKey
  status
  lastSeenAt
}
class Metric {
  id
  serverId
  cpuPercent
  ramPercent
  diskPercent
  uptimeSeconds
  servicesJson
  collectedAt
}
class Alert {
  id
  serverId
  type
  severity
  message
  acknowledged
  createdAt
}
class Threshold {
  id
  serverId
  metricType
  warning
  critical
}
User "1" -- "*" Server : manages
Server "1" -- "*" Metric
Server "1" -- "*" Alert
Server "0..1" -- "*" Threshold
@enduml
```
