# PlatePilote — RUNBOOK (incident response playbook)

> 📞 Référence rapide en cas d'incident : à imprimer / mettre en favori / ajouter dans le repo `On-Call`.
> 🎯 Cible : < 5 minutes pour identifier le niveau de sévérité, < 30 minutes pour restaurer le service.

---

## 👥 Annuaire & escalade

| Niveau | Qui | Délai | Canal |
|---|---|---|---|
| **L1** — Solo dev (Tamez) — owner prod | @tamez-prince (GitHub) | 0-15 min | GitHub Issues + email `ops@platepilote.com` |
| **L2** — Backup SRE | Volunteer #1 | 15-60 min | Phone/SMS (rotating weekly) |
| **L3** — Provider support | Railway / Neon / Upstash | > 60 min | Tickets support |
| **External** — Status page public | Visiteurs | live | https://<user>.github.io/platepilote-status/ (Upptime) |

### Premier réflexe (dans cet ordre)
1. Ouvre **Upptime status page** — confirme scope (API down? Landing down? Storage down?).
2. Ouvre **Railway dashboard** → onglet `Logs` — reproduire l'erreur.
3. Si erreur Spring Boot → Sentry → release suspecte identifiée en < 2 min.

---

## 🚨 Matrice de sévérité

| Sévérité | Critère | SLT restore | Action immédiate |
|---|---|---|---|
| **SEV-1** | API totalement down > 5 min, impossibilité d'utiliser l'app | < 30 min | Rollback Railway + status publique down |
| **SEV-2** | Endpoint(s) partiel(s) down, login cassé, > 25% users impactés | < 2h | PR hotfix urgent |
| **SEV-3** | Bug isolé, performance dégradée, < 5% users | < 24h | Issue GitHub standard |
| **SEV-4** | Cosmétique, typo, non-bloquant | backlog | Issue GitHub |

---

## 🔄 Procédures de rollback

### Rollback Railway (backend)
**Cas** : dernier déploiement a introduit un bug → on revient au commit précédent.

```bash
# Option 1 — via Dashboard
# 1. railway.app → projet PlatePilote → service Backend
# 2. Onglet "Deployments" → repérer le déploiement vert précédent
# 3. Menu kebab → "Redeploy" (le repo se rebuilde à l'identique mais avec l'ancien SHA peut nécessiter un revert git d'abord)

# Option 2 — via CLI (plus rapide)
npm i -g @railway/cli
railway login
railway link
railway down --service backend   # stop le service (optionnel, dépend si crash-loop)
git revert HEAD                   # créer un commit de revert
git push origin main              # Railway rebuilde automatiquement
```

### Rollback Vercel (landing)
```bash
# Dashboard → Deployments → "Promote to Production" un déploiement précédent
# Ou via CLI
vercel rollback
```

### Rollback frontend Flutter APK
GitHub Releases → marquer la release buggée comme `pre-release` et **ne PAS la supprimer** (les utilisateurs gardent la dernière stable). Re-uploade la release précédente comme Latest.

---

## 🔑 Rotation des API keys / secrets

| Secret | Source | Fréquence | Procédure |
|---|---|---|---|
| `JWT_SECRET` | Généré local | 90 jours | `openssl rand -base64 64` → Railway var → force logout tous users (token invalide) |
| `DATABASE_URL` (Neon) | Neon dashboard | 180 jours | Reset password → update Railway var → smoke test app |
| `REDIS_URL` (Upstash) | Upstash dashboard | 180 jours | Rotate credential → update Railway var → restart |
| `NVIDIA_NIM_API_KEY` | build.nvidia.com | 180 jours | Re-create key → update Railway var + var front |
| `BREVO_API_KEY` | Brevo dashboard | 90 jours | Create new → update Railway var → verifier SPF/DKIM |
| `R2_ACCESS_KEY_ID/SECRET` | Cloudflare | 90 jours | Create new token → roll in backend → revoke old |
| Railway deploy token | railway.app | annuel | My Account → Tokens → Revoke all + recreate |

### Procédure générique
1. **NEVER** commit un nouveau secret avant qu'il soit déployé.
2. Sur Railway : `Variables` → éditer → `Save` → Railway restart automatiquement le service.
3. Smoke test : `curl https://api.platepilote.com/actuator/health`.
4. Vérifier Sentry : nouvelle release déployée, pas de nouvelle exception.
5. **Révocation** de l'ancien secret (ne pas garder en parallèle plus de 24h).
6. Mettre à jour le 1Password / Vault personnel.

---

## 🗄️ Backup & restore

### Neon Postgres
- **PITR automatique** : 7 jours, branch instantané via UI Neon.
- Backup manuel :
  ```bash
  pg_dump $DATABASE_URL_DIRECT -Fc -f backup_$(date +%Y%m%d).dump
  # Upload vers R2 glacier-equivalent ou GitHub LFS
  ```
- Restore : Neon UI → "Restore" → choisir le point. Ou `pg_restore -d $NEW_DB backup.dump`.

### Cloudflare R2
- **Versioning** activé sur le bucket (UI R2).
- Backup cross-region : `rclone sync` vers un second bucket R2 (toujours gratuit, 0 egress).

---

## 📊 Diagnostic rapide

### "L'API est down"
```bash
# 1. Health check
curl -v https://api.platepilote.com/actuator/health

# 2. Logs Railway (CLI)
railway logs --tail 200 --service backend

# 3. Logs filtres erreurs
railway logs --tail 200 | grep -i "error\|exception\|caused by"

# 4. CPU/Memory
railway status  # ou dashboard → Metrics
```

### "Lenteur générale"
1. Railway → Metrics : CPU > 80% ou RAM > 90% → upgrade plan (pas en $0).
2. Neon → Monitoring : Connection count saturé ? Check `pg_stat_activity`.
3. Upstash → Dashboard : commands/sec > 8000/jour → tu vas taper la limite free (10K).
4. NVIDIA NIM rate limit ? → regarde header `x-ratelimit-remaining` dans la réponse API.

### "Emails ne partent pas"
1. Brevo UI → `Transactional` → `Logs` → statut "delivered" / "blocked" / "queued".
2. Vérifier SPF/DKIM (`dig TXT platepilote.com`).
3. Quota 300/jour dépassé ? → upgrade ou fallback Resend.

### "Storage images cassées"
1. Ouvre `https://cdn.platepilote.com/test.jpg` directement dans le navigateur → 403/404 ?
2. R2 bucket → vérifie custom domain DNS (proxy Cloudflare orange est-il ON ?).
3. Token R2 expiré → rotate (procédure ci-dessus).

---

## 📞 Contact support providers

| Provider | Tier | Délai SLA | Canal | Notes |
|---|---|---|---|---|
| Railway | Free/Hobby | Discord (comm.) | https://discord.gg/railway | Réponse typique 1-4h |
| Neon | Free | Discord | https://discord.gg/neon | Réponse typique < 2h |
| Upstash | Free | Email | support@upstash.com | Réponse typique 24h |
| Cloudflare R2 | Free | Dashboard tickets | Support form | 48-72h |
| Brevo | Free | Help center + email | https://help.brevo.com | 24-48h |
| Vercel | Hobby | Dashboard + email | vercel.com/support | 24h |
| GitHub Actions | Free | GitHub Support | https://support.github.com | Tiered |
| Sentry | Developer | Email | support@sentry.io | 24h |
| NVIDIA NIM | Free tier | Discord | https://discord.gg/nvidia | Variable |

---

## 📣 Communication en cas d'incident SEV-1

1. **Status page Upptime** passe automatiquement en rouge (preconfigured).
2. **GitHub issue** sur repo public avec label `down-incident` + template :
   ```
   ## 🚨 Incident SEV-1 — <Date>
   - **Started** : <heure>
   - **Symptom** : <description impact user>
   - **Root cause** : <root cause, si connu>
   - **Mitigation** : <rollback/restart/etc>
   - **Resolved** : <heure + fix permanent>
   ```
3. **Email aux early users** via Brevo (template préservé) → "We're back online, root cause: X, prevention: Y."
4. **Post-mortem** (publique, sans noms) → `docs/postmortems/YYYY-MM-DD.md` dans 7 jours.

---

## 🛡️ Checklist post-incident

- [ ] 5-whys documenté dans l'issue GitHub ou `docs/postmortems/`
- [ ] Tests de non-régression ajoutés (le bug ne reviendra pas)
- [ ] Alerte monitoring ajoutée (Upptime rule ou Sentry alert)
- [ ] Runbook mis à jour si nouvelle procédure
- [ ] Secrets rotés si root cause lié à leak
- [ ] Backup vérifié fonctionnel

---

_Last updated : déploiement initial $0 stack — Railway + Neon + Upstash + R2 + Vercel + Sentry + Upptime._
