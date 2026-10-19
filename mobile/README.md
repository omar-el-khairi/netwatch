# Notifications push (Firebase Cloud Messaging)

Pour activer les push sur Android :

1. Créer un projet Firebase et ajouter l'app Android (`ma.fst.settat.supervision_mobile`).
2. Télécharger `google-services.json` dans `android/app/`.
3. Décommenter `firebase_core` et `firebase_messaging` dans `pubspec.yaml`.
4. Initialiser Firebase dans `main.dart` avant `runApp`.
5. Côté backend, ajouter l'envoi FCM lors de `alert:new` (token device stocké via un endpoint `/api/devices`).

En V1 démo soutenance, le polling / refresh manuel des alertes suffit ; le canal temps réel complet est déjà sur le dashboard web (Socket.IO).
