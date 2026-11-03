# PlatePilote — Signature Android et livraison

**État :** la configuration Gradle et le workflow de release sont implémentés sur `release/production-readiness`.  
**Non réalisé :** le keystore réel n'a pas été créé et aucun APK signé par la clé du propriétaire n'a encore été produit.

## 1. Configuration Gradle déjà en place

`FrontEnd/android/app/build.gradle.kts` lit `FrontEnd/android/key.properties` et utilise le signing config `release`. Un build release ne retombe jamais sur la clé debug.

Le fichier local doit contenir :

```properties
storeFile=../upload-keystore.jks
storePassword=<STORE_PASSWORD>
keyPassword=<KEY_PASSWORD>
keyAlias=upload
```

Le chemin `storeFile` est résolu depuis le module Android `FrontEnd/android/app` et pointe donc vers `FrontEnd/android/upload-keystore.jks`.

Les fichiers suivants sont ignorés par Git :
- `FrontEnd/android/key.properties`
- `FrontEnd/android/upload-keystore.jks`

## 2. Générer le keystore

Depuis `FrontEnd/android`, avec un JDK installé :

```bash
keytool -genkeypair -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -dname "CN=PlatePilote, OU=Mobile, O=PlatePilote, C=CM"
```

La commande demande les mots de passe de façon interactive. Ne les passe pas comme arguments de commande, ne les colle pas dans le chat et ne commite jamais le keystore.

Conserve plusieurs sauvegardes chiffrées du keystore et des mots de passe dans un gestionnaire de secrets. Perdre la clé d'upload peut empêcher les mises à jour de l'application.

Ensuite, crée `FrontEnd/android/key.properties` à partir de `key.properties.example` et renseigne les vraies valeurs localement.

## 3. Build local

L'URL doit être l'URL HTTPS réellement déployée, avec le préfixe API attendu (généralement `/api/v1`). Ne remplace pas le domaine par une URL supposée.

```bash
PLATEPILOT_API_BASE_URL="https://<deployed-api-host>/api/v1" \
  ./deploy/scripts/build_android.sh prod
```

Le script produit :
- APKs signés par ABI dans `FrontEnd/build/app/outputs/flutter-apk/`
- AAB signé dans `FrontEnd/build/app/outputs/bundle/release/app-release.aab`

Vérifie la signature avec `apksigner verify --print-certs` et conserve les SHA-256 des artefacts.

## 4. Workflow GitHub Actions

Le workflow `.github/workflows/android-release.yml` se lance sur un tag `v*` ou manuellement. Configure avant de l'exécuter :

**Variable de dépôt**
- `PLATEPILOT_API_BASE_URL` : URL HTTPS publique et opérationnelle de l'API.

**Secrets de dépôt**
- `ANDROID_KEYSTORE_BASE64` : contenu base64 du fichier `upload-keystore.jks`.
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

Le workflow crée `key.properties` et le keystore uniquement dans le runner éphémère, construit les APKs/AAB, vérifie les signatures et téléverse les artefacts avec checksums. Ne stocke pas ces valeurs dans les fichiers suivis par Git.

Pour encoder le keystore localement avant de le placer directement dans le gestionnaire de secrets GitHub :

```bash
base64 -w 0 FrontEnd/android/upload-keystore.jks
```

Ne transmets pas le résultat dans une conversation. Colle-le uniquement dans le champ secret GitHub approprié.

## 5. Limites actuelles

- Aucun keystore du propriétaire n'a été fourni ou créé.
- Aucun secret GitHub de signature n'est présumé configuré.
- Aucun endpoint de production n'est présumé opérationnel.
- Un APK debug ou un APK signé avec une clé CI temporaire ne doit pas être distribué au public.
- La publication Play Store nécessite aussi la configuration Play App Signing et la validation de la fiche store.
