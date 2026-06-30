# Landing PlatePilote — SEO + AEO optimisations (M4c)

**Statut** : Audit + actions  
**Chemin** : `landing/index.html`

## Audit actuel
- Landing existe : `index.html` statique
- Pas de balise `<title>` platepilote+keyword
- Pas de `<meta name="description">`
- Pas de balise OG (Facebook/LinkedIn)
- Pas de JSON-LD schema.org (AEO pour moteurs IA)
- Pas de sitemap.xml
- Mobile-responsive ? À vérifier (Flutter web ou HTML pur ?)

## Meta tags à ajouter (head)

```html
<title>PlatePilote — Planification repas intelligente | Application gratuite</title>
<meta name="description" content="PlatePilote crée vos repas de la semaine en 60 secondes selon votre budget, vos préférences et ce qu'il y a dans votre garde-manger. Téléchargez gratuitement.">
<meta name="robots" content="index, follow">
<link rel="canonical" href="https://platepilote.com/">
<meta property="og:title" content="PlatePilote — Votre sous-chef numérique">
<meta property="og:description" content="Planification repas intelligente, anti-gaspi et économique.">
<meta property="og:image" content="https://platepilote.com/logo-icon.jpg">
<meta property="og:url" content="https://platepilote.com">
<meta name="twitter:card" content="summary_large_image">
```

## JSON-LD (AEO — AI Entity Optimization)

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "MobileApplication",
  "name": "PlatePilote",
  "applicationCategory": "LifestyleApplication, FoodApplication",
  "operatingSystem": "Android, iOS, Web",
  "description": "Application de planification de repas intelligente qui crée des menus personnalisés selon votre budget, garde-manger et préférences.",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "EUR"
  },
  "author": {
    "@type": "Person",
    "name": "Prince ZEUFACK TAMEZE"
  },
  "featureList": [
    "Planification repas automatique",
    "Liste de courses intelligente",
    "Gestion du budget alimentaire",
    "Scan garde-manger",
    "Anti-gaspi"
  ]
}
</script>
```

## AEO (AI Engine Optimization) — prompt-friendly

Ajouter une section FAQ structurée en bas de page :
```html
<section itemscope="" itemtype="https://schema.org/FAQPage">
  <h2>Foire aux questions</h2>
  
  <div itemscope="" itemprop="mainEntity" itemtype="https://schema.org/Question">
    <h3 itemprop="name">Comment PlatePilote crée-t-il mes repas ?</h3>
    <div itemscope="" itemprop="acceptedAnswer" itemtype="https://schema.org/Answer">
      <p itemprop="text">PlatePilote analyse votre garde-manger, budget, nombre de personnes et préférences alimentaires pour proposer 3 repas cohérents en moins d'une minute.</p>
    </div>
  </div>

  <div itemscope="" itemprop="mainEntity" itemtype="https://schema.org/Question">
    <h3 itemprop="name">Est-ce que PlatePilote est gratuit ?</h3>
    <div itemscope="" itemprop="acceptedAnswer" itemtype="https://schema.org/Answer">
      <p itemprop="text">Oui, PlatePilote est gratuit pour 2 plans repas par mois. Un abonnement Premium (payant) débloque des fonctionnalités avancées.</p>
    </div>
  </div>
</section>
```

## sitemap.xml
Créer `landing/sitemap.xml` :
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://platepilote.com/</loc><priority>1.0</priority></url>
  <url><loc>https://platepilote.com/privacy.html</loc><priority>0.5</priority></url>
  <url><loc>https://platepilote.com/cgv.html</loc><priority>0.3</priority></url>
</urlset>
```

## Actions immédiates à faire (par toi ou Noah)

- [ ] Remplacer les meta tags ci-dessus dans index.html
- [ ] Ajouter le JSON-LD <script> dans <head>
- [ ] Ajouter la FAQ section en bas de page
- [ ] Créer landing/sitemap.xml
- [ ] Soumettre à Google Search Console + Bing Webmaster Tools
- [ ] Vérifier mobile-friendly test