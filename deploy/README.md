# PlatePilote — Guide de déploiement production ($0 budget)

> 🎯 **Objectif** : faire tourner PlatePilote (backend Java + frontend Flutter + landing) en production **sans dépenser un centime**, en exploitant les free tiers généreux de Railway, Render, Neon, Upstash, Cloudflare R2, Vercel et GitHub Actions.

---

## 📐 Architecture cible

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Utilisateurs                                │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
       ┌──────────┐  ┌──────────┐  ┌──────────┐
       │ Landing  │  │ Frontend │  │   API    │
       │ Vercel   │  │ Flutter  │  │ Backend  │
       │ (gratuit)│  │ APK via  │  │ Railway  │
       │          │  │ GitHub   │  │   OU     │
       │          │  │ Releases │  │  Render  │
       └──────────┘  └──────────┘  └────┬─────┘
                                        │
                          ┌─────────────┼─────────────┐
                          ▼              ▼             ▼
                  ┌──────────────┐ ┌──────────┐ ┌──────────┐
                  │ Neon Postgres│ │  Upstash │ │Cloudflare│
                  │   (free)     │ │  Redis   │ │   R2     │
                  │              │ │  (free)  │ │ 10GB     │
                  └──────────────┘ └──────────┘ └──────────┘
                                        │
                                  ┌─────▼─────┐
                                  │ NVIDIA NIM│
                                  │  free API │
                                  └───────────┘
```

---

## 1️⃣ Backend — Railway (recommandé) ou Render

### Option A : Railway (recommandé)
- **Quotas free tier** : $5 de crédit/mois (≈ 500h runtime pour un service 512 MB). Le plan Hobby suffit pour démarrer.
- **One-click deploy** : détecte automatiquement le `railway.json` à la racine du repo (`BackEnd/railway.json`).
- **Pourquoi Railway plutôt que Render** : sleep-less sur le free tier, build image Docker plus rapide, logs en streaming, base PostgreSQL & Redis en add-ons (mais on va utiliser Neon/Upstash externes pour mieux contrôler le quota).

**Déploiement pas-à-pas :**
1. Crée un compte sur https://railway.app (sign-in GitHub).
2. `New Project` → `Deploy from GitHub Repo` → sélectionne `tamez-prince/platepilote` (ou ton fork).
3. Railway détecte `BackEnd/Dockerfile` automatiquement car le `railway.json` (Root Directory = `BackEnd`) lui indique.  
   *Si pas détecté :* `Settings` → `Root Directory` = `BackEnd` → `Dockerfile Path` = `Dockerfile`.
4. `Variables` (env vars Railway) — voir section 4️⃣.
5. `Settings` → `Networking` → `Generate Domain` → tu obtiens `*.up.railway.app`.  
   Plus tard : connecter un domaine custom via CNAME (Cloudflare gratuit, proxy orange ON pour HTTPS auto).

### Option B : Render (alternative)
- **Free tier** : service Web Docker gratuit **mais s'endort après 15 min d'inactivité** (cold start 30-60 s). OK pour dev/staging, **pas idéal prod**.
- Render blueprint : crée `render.yaml` à la racine (non inclus ici, mais Railway est prioritaire).

### Health check
Le backend expose `GET /actuator/health` (configuré dans `application.properties`). Dockerfile inclut un `HEALTHCHECK` wget. Railway/Render ping automatiquement ce path.

---

## 2️⃣ Frontend Flutter — APK via GitHub Releases (gratuit)

### Pourquoi pas Google Play ?
- $25 (one-time) + revue 3-7 jours + 30% de commission sur les achats in-app (à éviter pour MVP $0).
- Pas rentable avant d'avoir des utilisateurs payants.

### Distribution APK (gratuit, instantanée)
1. Build APK debug localement *ou* via GitHub Action `build-apk` job de `ci-frontend.yml` (artifact `platepilote-debug-apk`).
2. Sur GitHub : `Releases` → `Draft a new release` → tag `v0.1.0` → titre "PlatePilote v0.1.0 — Beta".
3. Upload `app-debug.apk` comme binaire attaché.
4. Publie → les utilisateurs reçoivent le lien direct `https://github.com/<user>/<repo>/releases/download/v0.1.0/app-debug.apk`.

### Pour la production (release APK signé)
À venir : signature avec keystore + Play Integrity. Pour MVP Flutter web ou iOS TestFlight sont aussi gratuits.

### Build automatique de release APK
Étendre le job `build-apk` une fois que tu auras ton keystore (à ajouter dans GitHub Secrets) :
```yaml
- run: flutter build apk --release --split-per-abi
- uses: softprops/action-gh-release@v2
  with:
    files: FrontEnd/build/app/outputs/flutter-apk/*.apk
```

---

## 3️⃣ Landing page — Vercel

- Tu as déjà `~/Documents/PlatePilote/landing/vercel.json`. Vercel sert `index.html` automatiquement.
- **Étapes** :
  1. Crée compte Vercel (sign-in GitHub).
  2. `Add New Project` → import le repo → `Root Directory` = `landing`.
  3. Framework auto-détecté : "Other" (HTML statique).
  4. `Deploy` → URL `*.vercel.app` instantanée.
- **Domaine custom** (`platepilote.com`) → gratuit sur Vercel, ajoute CNAME `cname.vercel-dns.com` chez ton registrar.

---

## 4️⃣ Variables d'environnement backend (production)

À configurer dans Railway → `Variables` :

| Variable | Source | Exemple |
|---|---|---|
| `SPRING_PROFILES_ACTIVE` | Hard-coded dans `railway.json` (`prod`) | `prod` |
| `DATABASE_URL` | Neon → Connection string (pooled) | `postgresql://user:pwd@ep-xxx-pooler.eu-central-1.aws.neon.tech/platepilote?sslmode=require` |
| `REDIS_URL` | Upstash → Redis URL | `rediss://default:xxx@xxx.upstash.io:6379` |
| `JWT_SECRET` | Génère avec `openssl rand -base64 64` | (base64 64 chars min) |
| `NVIDIA_NIM_API_KEY` | NVIDIA NIM free tier → https://build.nvidia.com | `nvapi-xxx...` |
| `R2_ACCESS_KEY_ID` | Cloudflare R2 → API tokens | `xxx` |
| `R2_SECRET_ACCESS_KEY` | idem | `xxx` |
| `R2_BUCKET` | Nom du bucket | `platepilote-images` |
| `R2_PUBLIC_URL` | Custom domain sur R2 | `https://cdn.platepilote.com` |
| `BREVO_API_KEY` | Brevo → SMTP & API | `xkeysib-xxx` |
| `BREVO_FROM_EMAIL` | Email expéditeur vérifié | `hello@platepilote.com` |
| `CORS_ALLOWED_ORIGINS` | Domaines frontend | `https://platepilote.com,https://www.platepilote.com` |

**⚠ Spring Boot convention** : `DATABASE_URL` est custom → ajoute dans `application-prod.properties` :
```properties
spring.datasource.url=${DATABASE_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
```
Ou bien utilise les vars standard `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`.

---

## 5️⃣ Bases de données & cache

### 🐘 Neon Postgres (free tier)
- 0.5 GB de stockage, autosuspend après 5 min d'inactivité (suffisant pour MVP).
- Crée : https://neon.tech → `New Project` → région proche (Frankfurt ou Paris).
- Récupère **2** connection strings :
  - `DATABASE_URL` (pooled, port 5432) → pour l'app via Railway.
  - `DATABASE_URL_DIRECT` (direct, port 5432) → pour les migrations Flyway/Liquibase.

### 🟥 Upstash Redis (free tier)
- 10 000 commands/jour, 256 MB max — largement suffisant pour cache + rate-limiting.
- Crée : https://upstash.com → `Create Database` → région EU.
- Utilise `rediss://` (TLS obligatoire).

---

## 6️⃣ Storage images — Cloudflare R2 (gratuit)

- 10 GB de stockage, **0 $ d'egress** (la killer feature vs S3).
- Setup :
  1. Cloudflare dashboard → `R2` → `Create Bucket` (nom : `platepilote-images`).
  2. `Settings` → `Public Access` → connecte un custom domain `cdn.platepilote.com` (gratuit via Cloudflare Registrar).
  3. Crée un API token R2 avec permission `Object Read & Write` sur ce bucket.
  4. Le backend Spring utilise `aws-sdk-java` pour pousser les images (le SDK est compatible S3-R2).
- Une config YAML R2 existe déjà côté backend (voir `application*.yml` côté `BackEnd/src/main/resources/`).

---

## 7️⃣ Emails transactionnels — Brevo (ex-Sendinblue)

- 300 emails/jour gratuits, forever.
- Setup :
  1. https://www.brevo.com → `Transactional` → `Settings` → `SMTP & API Keys`.
  2. Crée une clé API, note `BREVO_API_KEY`.
  3. Vérifie ton domaine d'envoi (`SPF` + `DKIM` records).
- **Pas de Brevo ?** Fallback Resend : 100 emails/jour gratuit.

---

## 8️⃣ Observabilité (basique, $0)

### Option A — Sentry (recommandé, **5 000 events/mois gratuits**)
Stack traces + release tracking + alertes email/Slack.
- Crée projet Java Spring Boot sur https://sentry.io.
- Ajoute la dépendance :
  ```xml
  <dependency>
    <groupId>io.sentry</groupId>
    <artifactId>sentry-spring-boot-starter</artifactId>
    <version>7.10.0</version>
  </dependency>
  ```
- Variable env : `SENTRY_DSN=https://xxx@sentry.io/xxx`.

### Option B — Logs JSON + Logtail (Better Stack) — **1 GB/mois gratuit**
- Logback JSON encoder (`net.logstash.logback:logstash-logback-encoder`) — produire du JSON structuré.
- Better Stack `Logtail` reçoit via HTTPS, query et alertes incluses.

### Option C — Axiom — **500 MB/mois gratuit**
- Très propre, query tipo SQL, dataset + dashboards en GG.

**Recommandation MVP** : **Sentry pour les erreurs**, **stdout JSON pour les logs** (Railway les capture nativement, queryables 7 jours gratuit).

---

## 9️⃣ Monitoring uptime — Upptime (gratuit, GitHub Pages)

`Upptime` = workflows GitHub qui ping `/actuator/health` toutes les 5 min, archivent les résultats et publient une status page sur GitHub Pages.

### Setup (1 fois, 5 min)
1. Crée un repo **`platepilote-status`** (public) ou utilise https://github.com/upptime/upptime en template.
2. Édite `upptime.yml` :
   ```yaml
   sites:
     - name: PlatePilote API
       url: https://api.platepilote.com/actuator/health
       check: "up"
     - name: PlatePilote Landing
       url: https://platepilote.com
   ```
3. Active GitHub Pages sur la branche `gh-pages` → status publique `https://<user>.github.io/platepilote-status/`.
4. Ajoute un `issue-rules` dans `.upptime/` pour ouvrir automatiquement une issue GitHub si downtime > 2 min (l'email GitHub t'alerte).

---

## 🔟 Lancement prod — checklist

- [ ] Compte Railway créé et repo lié → service déployé ✅
- [ ] Neon DB créée + connection strings notées
- [ ] Upstash Redis créé + URL notée
- [ ] Cloudflare R2 bucket créé + custom domain CDN
- [ ] Brevo expéditeur vérifié (SPF/DKIM)
- [ ] Sentry projet créé + DSN configuré
- [ ] Upptime repo créé + status page live
- [ ] Tous les env vars Railway complétés (voir 4️⃣)
- [ ] Domaine custom pointé vers Railway (CNAME proxy Cloudflare orange ON)
- [ ] Vercel landing déployé + domaine custom
- [ ] APK debug uploadé en GitHub Release → lien partagé aux premiers testeurs
- [ ] Premier utilisateur onboarded 🍽️

---

## 🔐 Sécurité — non négociable

1. **JWT_SECRET** : 64+ chars random, `openssl rand -base64 64`. Ne JAMAIS commit.
2. **Rotate API keys** tous les 90 jours minimum (cf. `RUNBOOK.md`).
3. **HTTPS partout** : Railway + Vercel + Cloudflare = Let's Encrypt automatique.
4. **CORS strict** : `CORS_ALLOWED_ORIGINS` liste blanche explicite (jamais `*` en prod).
5. **Headers** : configure `spring-security` pour `X-Content-Type-Options`, `X-Frame-Options`, etc.
6. **Database backups** : Neon fournit PITR (Point-in-time recovery) 7 jours sur le free tier.
7. **Secrets GitHub** : tous les secrets CI/CD dans `Settings → Secrets`, jamais dans le code.

---

## 💸 Récap budget mensuel

| Service | Coût | Capacité |
|---|---|---|
| Railway | $0 (credit $5) | 500h runtime |
| Neon Postgres | $0 | 0.5 GB |
| Upstash Redis | $0 | 10K req/jour |
| Cloudflare R2 | $0 | 10 GB, 0 egress |
| Brevo | $0 | 300 emails/jour |
| Vercel | $0 | 100 GB bandwidth |
| Sentry | $0 | 5K events/mois |
| GitHub Actions | $0 | 2000 min/mois |
| Upptime | $0 | illimité (workflows) |
| **TOTAL** | **$0** | Suffisant pour MVP + 100-500 users |

**Scaling** : à ~$5 de revenue/mois → upgrade Railway vers Pro. À $50/mois → Render + Neon paid + Datadog.

---

## 📞 Contacts providers

- **Railway support** : help@railway.app ou Discord https://discord.gg/railway
- **Neon support** : https://neon.tech/discord
- **Upstash support** : support@upstash.com
- **R2 support** : via Cloudflare dashboard → Support ticket
- **Brevo support** : https://help.brevo.com

---

_Dernière mise à jour : pipeline CI/CD mis en place, déploiement à valider sur Railway._
