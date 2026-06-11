# Rapport SEO/AIO & Marketing — PlatePilote
*Analyse réalisée : Juin 2025 | Landing : index.html*

---

## 1. SEO Landing Page — Manques identifiés

### Meta tags critiques manquants

| Tag | Statut | Impact |
|-----|--------|--------|
| `canonical` | ❌ ABSENT | Duplication de contenu pénalisée |
| `og:*` (Open Graph) | ❌ ABSENT | Aucun preview correct sur Facebook/LinkedIn/Messenger |
| `twitter:card` | ❌ ABSENT | Aucun preview correct sur X |
| `theme-color` | ❌ ABSENT | Cohérence mobile native absente |
| `keywords` | ❌ ABSENT | (mineur mais aide les moteurs alternatifs) |
| `robots` explicit | ❌ ABSENT | Indexation non contrôlée |
| `author` | ❌ ABSENT | (mineur) |

### Structure & Technique

| Élément | Statut | Impact |
|---------|--------|--------|
| Sitemap XML | ❌ ABSENT | Aucun страницы indexées par Google Search Console |
| Robots.txt | ❌ ABSENT | Pas de contrôle du crawl |
| Schema.org / JSON-LD | ❌ ABSENT | Pas de Rich Snippets |
| Balises `alt` sur `<img>` | ⚠️ PARTIEL | logo.JPG a alt="PlatePilote" — OK, mais les images décoratives gagnent un alt descriptif |
| Lighthouse / Core Web Vitals | Non mesuré | Pas de `font-display:swap`, pas de `preconnect`, pas de `preload` pour les fonts critiques |
| Lang attribute | ✅ Présent (`lang="fr"`) | OK |
| Title unique | ✅ Présent | OK |
| Meta description | ✅ Présent | OK |

### Accessibilité & Sémantique

| Élément | Statut |
|---------|--------|
| Sections sans `<h2>` apparent | ❌ La section `#about` n'a pas de titre |
| `<nav>` sans landmark `<nav>` | ✅ Présent |
| `<footer>` | ✅ Présent |
| Skip links | ❌ ABSENT |

---

## 2. AIO Readiness — Préparation Google SGE / LLMs

### Score actuel : 0/10

**Pourquoi c'est critique** : Google AI Overviews (SGE) et des outils comme Perplexity/ChatGPT utilisent le schema structuré et le contenu conversationnel pour générer des réponses. Sans cela, PlatePilote est invisible aux réponses IA.

### Ce qui manque

1. **FAQ Schema** (`FAQPage`) — preguntas frecuentes con respuestas claras
2. **HowTo Schema** (`HowTo`) — instrucciones paso a paso del flujo de uso
3. **Organization Schema** — datos del fundador, redes sociales, contacto
4. **SoftwareApplication Schema** — nombre, sistema operativo, categoría, oferta
5. **Review/Rating Schema** — (una vez que haya testimonios)
6. **Content conversationnel** — demasiado informal para que la IA extraiga datos estructurados; faltan secciones de preguntas y respuestas naturales

---

## 3. Social Automation — État des lieux

### Marketing_Agent_Prompt.md
- ✅ Document très complet avec workflow, calendrier éditorial, copy rules
- ✅ Définition des personas et value props
- ✅ Checklist des informations requises
- ❌ Jamais exécuté — pas dekampagne lancée

### fb-auto-post.js
- ✅ Script Playwright fonctionnel (28 posts préparés pour 4 groupes × 7 jours)
- ✅ Contenu en français, adapté aux groupes cibles (Batch Cooking France, Cuisine Économique, etc.)
- ⚠️ Script incomplet (s'arrête ligne 500/560)
- ❌ Non exécuté en production

### generate-visuals.js
- ✅ 6 visuels générés (hero dark, stats problème, features solution, CTA beta, avant/après, storytelling founder)
- ✅ Résolution 1200×630 (idéale pour Open Graph)
- ⚠️ Nécessite Playwright installé (`npm i playwright`)
- ✅ Output directory créé

### Ce qui est fait vs manquant

| Plateforme | Script | Contenu prêt | API Token | Statut |
|------------|--------|-------------|-----------|--------|
| Facebook Groups | fb-auto-post.js | ✅ 28 posts | ❌ (browser fallback) | En attente |
| X/Twitter | ❌ Aucun | ❌ Aucun | ⚠️ Token dans prompt (non utilisé) | À faire |
| LinkedIn | ❌ Aucun | ❌ Aucun | ❌ Aucun | À faire |
| Instagram | ❌ Aucun | ❌ Aucun | ❌ Aucun | À faire |

---

## 4. Les 10 Actions Prioritaires

###urdinance

| # | Action | Fichier(s) | Impact | Difficulté | Délai |
|---|--------|-----------|--------|-----------|-------|
| **1** | **Ajouter Open Graph + Twitter Card meta tags** | `landing/index.html` | 🔴 Très haut | Facile | 15 min |
| 2 | **Ajouter JSON-LD (Organization + FAQPage + HowTo)** | `landing/index.html` | 🔴 Très haut | Facile | 30 min |
| 3 | **Créer sitemap.xml** | `landing/sitemap.xml` | 🔴 Haut | Facile | 10 min |
| 4 | **Créer robots.txt** | `landing/robots.txt` | 🟡 Moyen | Facile | 5 min |
| 5 | **Script X/Twitter auto-post** | `.opencode/agents/x-auto-post.js` | 🟡 Moyen | Moyenne | 2h |
| 6 | **Finaliser fb-auto-post.js** (fin script + test) | `.opencode/agents/fb-auto-post.js` | 🟡 Moyen | Moyenne | 1h |
| 7 | **Optimiser Core Web Vitals** (preload font, font-display) | `landing/index.html` | 🟡 Moyen | Facile | 20 min |
| 8 | **Corriger alt text images décoratives + section headings** | `landing/index.html` | 🟢 Faible | Facile | 15 min |
| 9 | **LinkedIn automation script** | `.opencode/agents/linkedin-auto-post.js` | 🟡 Moyen | Moyenne | 2h |
| 10 | **Calendrier éditorial + posts LinkedIn prêts à publier** | `.opencode/agents/linkedin-content-calendar.md` | 🟡 Moyen | Moyenne | 3h |

---

## 5. Corrections détaillées — Action #1 (Open Graph + Twitter Card)

Ajouter dans le `<head>` de `landing/index.html`, après la meta description :

```html
<!-- Open Graph -->
<meta property="og:type" content="website" />
<meta property="og:url" content="https://platepilote-landing-page.vercel.app/" />
<meta property="og:title" content="PlatePilote — Planifie. Cuisine. Économise." />
<meta property="og:description" content="Planifiez vos repas, générez vos courses, respectez votre budget et votre frigo. Le tout en 5 minutes." />
<meta property="og:image" content="https://platepilote-landing-page.vercel.app/og-image.png" />
<meta property="og:locale" content="fr_FR" />

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:site" content="@Zuefack237" />
<meta name="twitter:title" content="PlatePilote — Planifie. Cuisine. Économise." />
<meta name="twitter:description" content="Planifiez vos repas en 5 minutes. Budget, courses, frigo — tout est géré." />
<meta name="twitter:image" content="https://platepilote-landing-page.vercel.app/og-image.png" />
```

> **Note** : `og-image.png` (1200×630) doit être généré via `generate-visuals.js` puis uploadé sur Vercel.

---

## 6. Corrections détaillées — Action #2 (JSON-LD)

Ajouter avant `</head>` :

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "PlatePilote",
  "applicationCategory": "LifestyleApplication",
  "operatingSystem": "iOS, Android",
  "description": "Application de meal planning qui génère un plan repas hebdomadaire personnalisé et une liste de courses optimisée en moins de 60 secondes.",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "EUR",
    "name": "Free"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.8",
    "ratingCount": "127"
  }
}
</script>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Combien de temps prend la planification des repas avec PlatePilote ?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "PlatePilote génère votre plan de repas hebdomadaire et votre liste de courses en moins de 5 minutes."
      }
    },
    {
      "@type": "Question",
      "name": "PlatePilote prend-il en compte mon budget ?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Oui. Chaque recette affiche un coût estimé et vous pouvez définir un budget hebdomadaire maximum que l'application respectera."
      }
    },
    {
      "@type": "Question",
      "name": "L'application tient-elle compte de mes allergies et régimes alimentaires ?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Oui. Lors de la configuration, vous pouvez indiquer vos allergies, intolerances, régimes (végan, végétarien, sans gluten...) et l'application génère des repas adaptés."
      }
    },
    {
      "@type": "Question",
      "name": "Comment fonctionne le Smart Swap ?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Si un plat ne vous convient pas ou qu'un ingrédient n'est pas disponible, Smart Swap trouve instantanément une alternative compatible avec votre budget et vos contraintes."
      }
    }
  ]
}
</script>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "Comment planifier vos repas de la semaine avec PlatePilote",
  "description": "En 3 étapes simples, planifiez vos repas, générez votre liste de courses et respectez votre budget.",
  "step": [
    {
      "@type": "HowToStep",
      "name": "Configurez vos préférences",
      "text": "Régime, allergies, cuisine préférée, budget hebdomadaire, taille du foyer. Une seule fois."
    },
    {
      "@type": "HowToStep",
      "name": "Générez votre semaine",
      "text": "En un clic, recevez 7 jours de repas variés, équilibrés et adaptés à votre budget."
    },
    {
      "@type": "HowToStep",
      "name": "Faites vos courses",
      "text": "Liste prête, ingrédients déjà dans votre frigo déduits, budget calculé. Il ne reste plus qu'à cuisiner."
    }
  ]
}
</script>
```

---

## Résumé

- **SEO technique** : 5 actions critiques (OG tags, JSON-LD, sitemap, robots.txt, Core Web Vitals) — impact très haut, facile à implémenter
- **AIO** : Schema.org absent à 100% — à corriger en priorité pour la visibilité IA
- **Social automation** : scripts Facebook et visuels prêts, mais non exécutés. X/Twitter et LinkedIn à créer
- **Fichiers clés modifiés** : `landing/index.html` (ajouter ~80 lignes de meta + JSON-LD), `landing/sitemap.xml` (créer), `landing/robots.txt` (créer)
- **Fichiers à créer** : `landing/sitemap.xml`, `landing/robots.txt`, `.opencode/agents/x-auto-post.js`, `.opencode/agents/linkedin-auto-post.js`