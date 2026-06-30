# Signing Configuration — PlatePilote Mobile Beta

## Android Signing (Keystore)

**Générer le keystore (local, une fois) :**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -alias platepilote -keyalg RSA -keysize 2048 \
  -validity 10000 -storetype JKS
```
Note : `storetype JKS` est déprécié mais compatible CI. Si tu veux PKCS12 : `-storetype PKCS12`

**Configurer Android dans CI :**
Dans `FrontEnd/android/key.properties` (gitignoré) :
```properties
storePassword=${ANDROID_KEYSTORE_PASS}
keyPassword=${KEYSTORE_KEY_PASS}
keyAlias=${KEYSTORE_KEY_ALIAS}
storeFile=${ANDROID_KEYSTORE_PATH}
```

**GitHub Secrets requis :**
- `ANDROID_KEYSTORE_BASE64` : keystore encodé en base64 (`base64 ~/upload-keystore.jks`)
- `ANDROID_KEYSTORE_PASS` : mot de passe du keystore
- `KEYSTORE_KEY_ALIAS` : alias de la clé (ex: `platepilote`)
- `KEYSTORE_KEY_PASS` : mot de passe de la clé

**Dans CI-backend ajouter une étape :**
```yaml
- name: Decode keystore
  run: |
    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > keystore.jks
  working-directory: FrontEnd/android/app
```

## iOS Signing (Apple Distribution)

**Requis** : Compte Apple Developer ($99/an — pas de contournement)

**Certificat de distribution :**
1. Apple Developer → Certificates → Créer un `iOS Distribution` cert
2. Télécharger le `.cer`, double-cliquer pour installer dans le trousseau
3. Exporter le certificat + clé privée : Trousseau → clic droit → Exporter → `.p12`
4. Base64 : `base64 Certificats.p12`
5. Stocker dans GitHub Secret `IOS_P12` + `IOS_P12_PASS`

**Provisioning Profile :**
1. Apple Developer → Profiles → `Ad Hoc` ou `Development` (selon beta)
2. Ajouter les UDID des testeurs
3. Télécharger le `.mobileprovision`
4. Le mettre dans `FrontEnd/ios/Runner/` (commit-ignoré) ou le décoder en CI

**ExportOptions.plist** (pour build_ios.sh) :
Créer `FrontEnd/build/ios/ExportOptions.plist` :
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>ad-hoc</string>  <!-- development pour dev, app-store pour prod -->
  <key>uploadSymbols</key>
  <true/>
  <key>teamID</key>
  <string>${IOS_TEAM_ID}</string>
</dict>
</plist>
```

GitHub Secret : `IOS_TEAM_ID` (Apple Team ID, 10 caractères alphanumériques)

## Firebase App Distribution (Android)

1. `flutterfire configure` (remplace firebase_options.dart placeholder)
2. `firebase init appdistribution`
3. Dans CI : `firebase appdistribution:distribute app/build/outputs/apk/release/app-release.apk --app <FIREBASE_APP_ID> --testers-file testers.txt`
4. Ajouter les emails des beta testeurs dans `FrontEnd/testers.txt` (git-ignored)