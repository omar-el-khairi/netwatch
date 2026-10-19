# Notifications push (FCM) — NetWatch Mobile

## Mode démo (déjà actif)

L'app mobile utilise **Socket.IO + notifications locales** :
- dès qu'une alerte arrive (`alert:new`), une notification système s'affiche
- pas besoin de Firebase pour la soutenance

## Mode FCM complet (optionnel)

1. Créer un projet Firebase → ajouter app Android `ma.fst.settat.supervision_mobile`
2. Télécharger `google-services.json` → `mobile/android/app/`
3. Décommenter dans `mobile/pubspec.yaml` :
   - `firebase_core`
   - `firebase_messaging`
4. Backend :
   ```bash
   cd backend
   npm i firebase-admin
   ```
5. Dans `.env` :
   ```
   FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}
   ```
6. L'app enregistre le token via `POST /api/devices`

Sans l'étape Firebase, le canal Socket.IO suffit pour la démo live.
