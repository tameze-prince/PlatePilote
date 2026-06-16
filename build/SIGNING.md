# PlatePilote — Signature Android (release / Play Store)

> **Statut :** template prêt. Le keystore réel (`upload-keystore.jks`) n'a PAS été créé ici — secret Prince.
> **Cible :** build prod release + déploiement Google Play Console.

---

## 1. Pourquoi ce fichier

Le projet est livré avec la config par défaut de Flutter (`signingConfigs.getByName("debug")`) qui **signe avec la clé debug** — inutilisable pour le Play Store. Pour publier :

1. Générer un keystore privé (`upload-keystore.jks`).
2. Stocker ses secrets dans `android/key.properties` (jamais commité).
3. Lire ce fichier depuis `android/app/build.gradle.kts` pour signer `release`.

---

## 2. Étape 1 — Générer le keystore

Utilise l'outil Java `keytool` (présent si JDK 17 installé — vérifié sur ton poste).

```bash
cd ~/Documents/PlatePilote/FrontEnd/android
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass 'TON_STORE_PASSWORD' \
  -keypass 'TON_KEY_PASSWORD' \
  -dname "CN=PlatePilote, OU=Mobile, O=PlatePilote, L=Paris, ST=IDF, C=FR"
```

- **`-validity 10000`** → ~27 ans (recommandé Google). Le Play Store exige une validité ≥ 25 ans.
- **`-alias upload`** → convention Play App Signing.
- **`-storepass` / `-keypass`** → garde-les secrets, ne les colle pas dans Slack/Discord.

> ⚠️ **Perdre ce keystore = perdre ton app sur le Play Store.** Fais un backup chiffré hors-ligne avant de continuer.

---

## 3. Étape 2 — Créer `android/key.properties`

```bash
cd ~/Documents/PlatePilote/FrontEnd/android
cp key.properties.example key.properties
# Édite key.properties et remplace les 3 valeurs REPLACE_WITH_* par tes vrais mots de passe.
```

Le fichier `key.properties` doit figurer dans `.gitignore` (à vérifier, déjà présent dans `.gitignore` racine Flutter standard).

---

## 4. Étape 3 — Brancher dans `android/app/build.gradle.kts`

Le snippet ci-dessous lit `key.properties` et charge le keystore. **Aucune modification n'a été faite ici** pour ne pas casser le build debug ; à appliquer par Prince quand le keystore est prêt.

**Ajouter AVANT le bloc `android {` :**

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) load(FileInputStream(file))
}
```

**Ajouter dans `android { ... }`** (avant `buildTypes`):

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
        storeFile = keystoreProperties["storeFile"]?.let { file(it) }
        storePassword = keystoreProperties["storePassword"] as String?
    }
}
```

**Modifier le bloc `buildTypes` :**

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true       // R8 / ProGuard
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

---

## 5. Étape 4 — Play App Signing (obligatoire depuis 2021)

Google exige désormais **Play App Signing** :

1. Upload ton `upload-keystore.jks` une seule fois dans Play Console (Setup → App signing).
2. Google génère la **app signing key** (leur clé maître) qu'ils gardent.
3. Tes APK/AAB par la suite sont signés seulement avec ton `upload key` ; Google les re-signe avec la app signing key avant distribution.

→ Voir : https://support.google.com/googleplay/android-developer/answer/9842756

---

## 6. Vérification locale après config

```bash
cd ~/Documents/PlatePilote/FrontEnd
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.platepilote.app

# Vérifier la signature
$ANDROID_HOME/build-tools/<version>/apksigner verify --print-certs \
  build/app/outputs/flutter-apk/app-release.apk
```

La sortie doit afficher ton certificat (CN=PlatePilote, O=PlatePilote, etc.) — et non plus le certificat debug Android.

---

## 7. Checklist Prince

- [ ] `keytool -genkey ...` exécuté, keystore sauvegardé dans un endroit sûr (gestionnaire de mots de passe + backup chiffré).
- [ ] `android/key.properties` créé, ajouté au `.gitignore`.
- [ ] Patch `android/app/build.gradle.kts` appliqué (sections ci-dessus).
- [ ] `play.keytool` upload fait dans Google Play Console.
- [ ] Premier `flutter build appbundle --release` signé → upload en **internal testing** pour valider.
