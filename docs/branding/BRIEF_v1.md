# PlatePilote — Brand Assets Brief v1

**Sprint**: 6 — Brand assets production for store + app interior rollout
**Owner**: Bob Coordinator (orchestration) → Kevin (production)
**Statut**: À valider par Henry (Brand) + Grace (Design Director) avant production
**Date**: Sprint 6 week 1
**Version**: v1

---

## 0. Note critique à Kevin — dépendance visuelle

Le modèle chargé de rédiger ce brief **ne supporte pas l'input visuel**. Les fichiers `PlatePilote_Campagne/assets/*.JPG` n'ont pas pu être inspectés programmatiquement.

**Kevin — tu DOIS faire ceci EN PREMIER, avant de toucher Figma :**

1. **Ouvrir visuellement** les trois fichiers suivants dans `PlatePilote_Campagne/assets/` :
   - `logo dark with text.JPG`
   - `logo light with text.JPG`
   - `logo light without text.JPG`
2. **Extraire la palette réelle** via le color picker Figma sur chaque logo (échantillonner minimum 5 zones : fond, mark, wordmark, accents, ombres éventuelles).
3. **Recadrer chaque élément** du logo (mark isolé / wordmark seule) en composants Figma séparés et exportables.
4. **Évaluer la complexité** : si le logo d'origine est plus complexes que monoline plat (dégradés multiples, ombres, textures), Kevin **simplifie** vers monoline flat outlined pour les usages app icon + empty states. Le logo officiel reste canonique pour les supports marketing.
5. **Comparer** la palette extraite aux tokens `AppColors` listés en §8 — si écart, signaler à Henry avant production.

Toute la section §2 (Logo treatment matrix) ci-dessous est **provisoire en attendant cette extraction**. Les hex définitifs seront confirmés après retour Kevin.

---

## 1. Brand foundation

### 1.1 Produit
- **Nom**: PlatePilote
- **Tagline canonique**: *"Decisions, not lists."* (voix Henry)
- **Mission implicite**: transformer la planification repas familiale d'une corvée de listes en une décision guidée, sereine et économe.
- **Métaphore produit**: un sous-chef dans la poche — calme, disponible, expert.

### 1.2 Audience
- **Cible primaire**: 18–45 ans, household cooks
- **Responsabilités quotidiennes**: courses + repas familiaux + budget + pantry + zéro gaspi
- **Douleurs**: surcharge décisionnelle, gaspillage, budget slippage, "qu'est-ce qu'on mange ce soir"
- **Désirs**: rapidité, confiance, fluidité,感觉自己 d'organiser sans effort

### 1.3 Tone of voice
- **Calme** — pas d'urgence, pas d'alerte permanente
- **Sous-chef de poche** — expert présent, jamais intrusif
- **Premium mais chaleureux** — la précision sans froideur, le soin sans luxe froid
- **Éviter**: jargon nutritionnel, moralisation alimentaire, ton startup "move fast"
- **Privilégier**: phrases courtes, second personne, décisions offertes plutôt que prescrites

### 1.4 Identité existante
- Trois logos source dans `PlatePilote_Campagne/assets/` (voir §0 – Kevin doit les extraire)
- Wordmark liée à la marque, à respecter dans toute production
- Pas encore de mascotte officielle — voir §7 (Sprint 7 option)

---

## 2. Logo treatment matrix

### 2.1 Variantes requises

| Variante | Usage | Background | Notes |
|----------|-------|------------|-------|
| **Full mark — light bg** | Marketing print, landing page light, docs | Cream `#F8FAFC` ou blanc | Couleurs originales du logo light + text |
| **Full mark — dark bg** | Landing dark, splash screen, paid ads dark | Noir `#020617` / slate-950 | Inverser les couleurs du wordmark si nécessaire |
| **No wordmark** (mark seul) | App icon, favicon, avatar social, intégration tiers | Transparent | Mark extrait seul — voir §0 |

### 2.2 Brand color tokens (à confirmer après extraction Kevin)

Les tokens **canoniques applicatifs** sont définis dans `FrontEnd/lib/app/theme/app_colors.dart`. Kevin doit vérifier que la palette extraite des logos est cohérente avec ces tokens :

| Token | Hex | Rôle |
|-------|-----|------|
| `primaryAccentGreen` | `#22C55E` | Vert principal (mark, CTA) |
| `deepGreen` / `primary` | `#16A34A` | Vert foncé (états actifs, header) |
| `primaryDark` | `#087A32` | Gradient start, hover |
| `premiumCyanAccent` / `tertiary` | `#67E8F9` | Accent premium (subtil) |
| `warmAccent` / `secondary` | `#F59E0B` | Accent chaud (budget, alerte douce) |
| `background` | `#F8FAFC` | Fond clair |
| `darkBackground` | `#020617` | Fond sombre |
| `onSurface` / `onBackground` | `#0F172A` | Texte principal |
| `outline` | `#E2E8F0` | Bordures |

**Pour branding Kevin** : utiliser ces hex directement. Les tokens `AppColors` sont la source de vérité cross-platform.

### 2.3 Safe area autour du mark
- **Safe area horizontale & verticale**: minimum **0.5× la hauteur de la lettre capitale du wordmark** de chaque côté
- **Le no-wordmark version** demande 1× le diamètre du mark en safe area (utilisé en favicon/avatar)
- Aucun texte, élément graphique, ou bord d'écran ne doit empiéter sur cette safe area

### 2.4 Minimum size render
| Variante | Web | Print | App context |
|----------|-----|-------|-------------|
| Full mark | 120px wide min | 25mm wide min | N/A (usage marketing uniquement) |
| Mark seul | 24px | 8mm | 24px (favicon tab) → 12px (favicon retina) |
| Wordmark seul | 80px wide | 15mm | N/A |

### 2.5 Backgrounds sombres — règles
- **Préférer les full marks à contraste inversé** sur fond sombre (logo dark with text)
- **Ne jamais** appliquer un full mark light sur fond très sombre sans vérifier contraste WCAG AA (texte ≥ 4.5:1)
- **Mark seul** fonctionne sur tout fond (silhouette fonctionne si mark est monochrome)

---

## 3. App icon (iOS + Android)

### 3.1 Concept
- **Sujet**: un seul élément food icon type "plate" intégré dans l'esthétique wordmark
- **Métaphore**: assiette vue de dessus avec un élément signature au centre (cuillère stylisée ? grain de cuisine ? arobase culinaire ?) — **Kevin décide** en s'inspirant du wordmark existant, après extraction §0
- **Direction artistique**: plat, moderne, monoline outlined avec gradient subtil

### 3.2 Style
- **Type**: outlined flat 1.5pt stroke, coin arrondis ~22% du radius iOS standard
- **Gradient**: `gradientStart = #087A32` → `gradientEnd = #22C55E` (du `AppColors`)
- **Monoline**: identique au wordmark pour cohérence familiale
- **Pas de**: glossy 3D, skeuomorphisme, photo, drop shadow internaute

### 3.3 Background options
- **Option A** (recommandée store) : cream `#F8FAFC` plein
- **Option B** : gradient soft `surfaceContainerHigh` → cream
- **À éviter**: fond noir, fond photo, fond multicolore

### 3.4 Deliverables app icon — 5 livrables

| # | Format | Spécifications |
|---|--------|----------------|
| 1 | Master | PNG 1024×1024, square, alpha background transparent mais BG cream appliqué, sRGB, no rounded corners (Apple/Google les ajoutent au système) |
| 2 | iOS | PNG aux sizes : 180, 167, 152, 120, 87, 60, 40 px (1× et 2×), @1x/@2x/@3x naming Apple |
| 3 | Android | PNG aux sizes : 512, 192, 144, 96, 72, 48 px |
| 4 | Adaptive FG | PNG 432×432, foreground seul, transparent BG, safe zone 66% du canvas (Android 8+ adaptive) |
| 5 | Adaptive BG | PNG 432×432, background seul, peut être plein cream ou gradient |

**Naming**: `platepilote_icon_<size>.png` (snake case)
**Export**: PNG optimisé, ≤ 150 KB chaque sauf master (≤ 500 KB)

---

## 4. Empty state illustrations (4)

Quatre illustrations pour les états vides suivants — situées en `app/lib/features/<feature>/presentation/widgets/empty_state_*.dart`.

### 4.1 Liste des illustrations

| # | Nom | Scène | Symbole clé |
|---|------|-------|-------------|
| 1 | **Empty pantry** | Étagère de cuisine avec un seul pot/bocal posé | Étagère + 1 jar |
| 2 | **Expiring soon** | Calendrier dont une date passe au rouge | Calendrier + coche rouge |
| 3 | **Budget celebration** | Pièce + check mark + ruban | Coin + check + ribbon |
| 4 | **Swap suggestion** | Deux assiettes face-à-face, mouvement de swipe | 2 plates + flèche swap |

### 4.2 Style canonique
- **Stroke**: monoline outlined **1.5pt** constant (pas de variation)
- **Pas de remplissage plein** sauf petites zones d'accent (background swatch)
- **Coins**: arrondis doux ~4px sur tous les angles
- **Palette obligatoire**:
  - Vert primary `#22C55E` (marque)
  - Soft mint (à dériver de primary + 30% white)
  - Cream `#F8FAFC` (fond)
  - Charcoal `#0F172A` (contours principaux)
  - Optionnel accent chaud `#F59E0B` pour célébration budget uniquement
- **Silhouette**: réduction favicon-like — doit rester lisible à 48×48 (test Kevin: redimensionner l'illustration à 48px dans Figma et vérifier reconnaissance)
- **Pas de** : visages humains, mains, perspectives complexes, détails microscopiques

### 4.3 Arrière-plan
- **Carré** ou **cercle** contenant la scène (frame soft, pas obligatoire)
- Fond transparent par défaut — la surface applicative fournit le cream BG
- Variante avec BG cream `#F8FAFC` livré également pour usage hors-app (docs, blog)

### 4.4 Deliverables par illustration

| Format | Spécifications |
|--------|----------------|
| SVG | Vectoriel, paths en `currentColor` ou tokens explicites, fichiers < 15 KB, viewBox `0 0 320 320` recommandé |
| PNG | 1× (320×320) et 2× (640×640), fond transparent + variante fond cream |
| Sprite sheet (optionnel) | 4 illustrations en un PNG 1280×320 avec spacing 80px, pour usage interne |

**Naming**: `platepilote_empty_<nom>.svg`, `platepilote_empty_<nom>_cream.png`

---

## 5. Feature graphic (PNG, 1024×500)

Spec Google Play standard pour store listing.

### 5.1 Composition hero
- **Texte hero principal** (centré ou droite): *"Your weekly meal plan, ready in 1 minute"*
- **Sous-texte** (optionnel): *"Decisions, not lists."* en secondary line plus discret
- **Device mockup**: iPhone (mockup Frame iPhone 15 Pro ou équivalent), affiché en 3/4, screen rendu avec une vue Meal Plan de l'app
- **Logo PlatePilote**: bottom-right corner, full mark dark variant
- **Background**: cream `#F8FAFC` avec une très subtile texture/wash gradient (optionnel)

### 5.2 Trois callouts rapides
Positionnés autour du device mockup ou en bande horizontale sous le hero:

| Callout | Texte | Symbol |
|---------|-------|--------|
| 1 | **Pantry smart** | Icône pantry (étagère ou pot) |
| 2 | **Budget optimized** | Icône budget (pièce ou wallet) |
| 3 | **Waste reduced** | Icône waste (poubelle ou feuille recycle) |

Chaque callout : pictogramme monoline outlined + label sans-serif (Inter ou équivalent).

### 5.3 Specs techniques
- **Dimensions**: 1024×500 px obligatoires (Google Play hard-reject sinon)
- **Couleurs**: palette §2.2 uniquement
- **Texte**: lisible à la prévisualisation (~300px wide sur Play Store), éviter body text dense
- **Safe area**: 16px margin tous côtés minimum (texte et éléments critiques)

**Naming**: `platepilote_feature_graphic_v1.png`

---

## 6. Promo video storyboard (30 secondes)

Spec store promo: format 16:9 (1920×1080) ou 9:16 (1080×1920) pour mobile — Kevin livrera master + 2 ratios.

### 6.1 Timeline

| Time | Segment | Visuel | Audio/Script |
|------|---------|--------|--------------|
| **0–5s** | **Logo reveal** | Fond cream vide → mark apparaît → wordmark fade in en dessous → gradient subtle pulse | Signature sound courte (2 sonneries), jingle 4 notes |
| **5–10s** | **Hero — "dinner tonight"** | Hero text: *"What's for dinner tonight?"* + cursor typing `"What's in my pantry?"` dans input field (animation frame-by-frame) | Voice-over: "You open PlatePilote. Ask what's in your pantry." |
| **10–18s** | **Results cascade** | 3 cards de recettes apparaissent en slide-up successif, chacune avec photo + name + prep time | Son cascade douce (3 notes montantes). Voice-over: "Three recipes, ready in under 20 minutes." |
| **18–25s** | **Meal swap** | Animation: assiette 1 ↔ assiette 2 avec flèche swap + check confirmation | "Bruit" swap satisfaisant (succès). Voice-over: "Swap, save, decide. No more lists." |
| **25–30s** | **CTA + logo** | CTA button *"Start your week →"* apparaît + PlatePilote logo centré en dessous + tagline *"Decisions, not lists."* | Jingle out identique à 0–5s. End card statique 1s puis fade. |

### 6.2 Specs techniques
- **Durée**: exactement 30s (hard limit store)
- **Master**: 1920×1080, 30fps, ProRes 422 ou H.264 high bitrate
- **Mobile variant**: 1080×1920 (9:16) pour TikTok/Reels/Shorts — recadrage du master
- **Format**: MP4 final, ≤ 100 MB
- **Captions**: sous-titres burned-in pour accessibilité
- **Pas de** : voix off agressive, musique forte copyright, transitions flashy

**Naming**: `platepilote_promo_video_30s_master.mp4`, `platepilote_promo_video_30s_9x16.mp4`

---

## 7. Mascot / illustration (optionnel — Sprint 7)

### 7.1 Concept : **PlatePilot**
Un petit chef "sous-chef" personnage — humanoïde stylisé, friendly, jamais enfantin.

### 7.2 Style
- **Cohérent avec §4** : monoline outlined 1.5pt
- **Couleurs**: palette §2.2 + tablier mint, toque cream
- **Proportions**: chibi-ish mais mature, pas baby-like
- **Expressions**: 3 variantes minimum (neutre / content / concentré)

### 7.3 Usages prévus
- Empty states premium (remplacement partiel des illustrations §4 si budget le permet)
- Onboarding success states (welcome, première recette ajoutée)
- Trust badges (substitut du photography dans les pages À propos)
- Social media occasional (Doodle threads)

### 7.4 Decision gate
**Ce brief marque la décision comme OPTIONNELLE**. Henry + Grace arbitreront en fin Sprint 7 si la mascotte est produite (Kevin ne la commence qu'après validation explicite post-Sprint 6 review).

---

## 8. Tech specs

### 8.1 Naming convention
- **Format canonique**: `platepilote_<asset>_<variant>.<ext>`
- **Snake case strict**, minuscules, pas de tirets, pas de CamelCase
- **Exemples valides**:
  - `platepilote_icon_master_1024.png`
  - `platepilote_empty_pantry.svg`
  - `platepilote_empty_pantry_cream.png`
  - `platepilote_full_mark_dark.svg`
  - `platepilote_feature_graphic_v1.png`
  - `platepilote_promo_video_30s_master.mp4`
- **Exemples INVALIDES** (rejetés en review):
  - `PlatePilote_Icon_v2.PNG` (CamelCase, casse uppercase)
  - `plate-pilote-logo-files.zip` (tirets)
  - `icon_white-bg.svg` (préfixe marque manquant, séparateurs incohérents)

### 8.2 Couleurs
- **HEX spec matched** aux `AppColors` listés §2.2
- **Kevin** : utiliser le color picker tokens du design system Figma (à lier au fichier DS) — pas de hex inventés
- **Source de vérité**: `FrontEnd/lib/app/theme/app_colors.dart` — si Kevin a besoin d'une nouvelle couleur, il demande à Henry (jamais d'ajout silencieux)

### 8.3 Render / export PNG
- **1× et 2×** livrés systématiquement pour les PNG
- **3×** requis uniquement pour app icon iOS (`@3x`)
- Format: PNG-24 (alpha) sauf indication contraire
- Profil colorimétrique: sRGB IEC61966-2.1
- Compression: optimisée via TinyPNG ou ImageOptim avant livraison

### 8.4 Fichiers sources
- **Toujours livrer le .fig source Figma** en parallèle des exports
- Format: Figma file link + export local `.fig` dans `PlatePilote_Campagne/assets/sources/`
- Variables Figma liées aux `AppColors` tokens

---

## 9. Sources à consulter AVANT production

### 9.1 Assets existants
- `PlatePilote_Campagne/assets/logo dark with text.JPG`
- `PlatePilote_Campagne/assets/logo light with text.JPG`
- `PlatePilote_Campagne/assets/logo light without text.JPG`

### 9.2 Design system
- **Tokens canoniques couleurs**: `FrontEnd/lib/app/theme/app_colors.dart` (172 lignes, palette complète — voir §2.2)
- **Premium components (visual templates)**: `FrontEnd/lib/core/premium_components.dart` — référence visuelle pour cohérence composants
- **Onboarding screens** (existants): chercher dans `FrontEnd/lib/app/features/onboarding/presentation/screens/` pour extraire le ton visuel déjà en place
- **Thème global**: `FrontEnd/lib/app/theme/app_theme.dart` (si présent) pour comprendre les élévations, radii, typographies déjà adoptées

### 9.3 Documentation complémentaire
- Brand book (à venir — Sprint 7) : positionné par Henry
- Charte éditoriale : voix Henry (consulter les copies existantes dans `/docs/marketing/` si présentes)

---

## 10. Timeline & Sprint planning

| Sprint | Scope | Livrables Kevin |
|--------|-------|------------------|
| **Sprint 6** (maintenant) | Brief finalisé + validation stakeholders | Ce brief livré et revu par Henry + Grace |
| **Sprint 7** | App icon production + extractions logo source | §3 — Master 1024 + iOS variants + Android variants + adaptive FG/BG. **Requis pour store submission.** |
| **Sprint 8** | Empty states + feature graphic + promo video storyboard | §4 (4 illustrations SVG + PNG), §5 (feature graphic PNG), §6 (video master + variant 9:16) |
| **Sprint 9** | Store submissions | Bob Coordinator gère upload + metadata, Kevin fournit variants finals et ajuste si rejek store |

### 10.1 Date gates critiques
- **Fin Sprint 7**: app icon **doit** être prêt — Google/Apple rejektent les submissions sans icon definitif
- **Mi Sprint 8**: feature graphic doit être validé Henry avant finalisation (sinon cascade retard)
- **Fin Sprint 8**: promo video master revu et approuvé — **pas d'extension possible** (budget promo)

### 10.2 Review gates
Chaque livrable passe :
1. **Self-review Kevin** contre checklist du brief (couleurs, naming, formats)
2. **Henry (Brand) review** — cohérence messaging + tone
3. **Grace (Design) review** — cohérence design system + qualité visuelle
4. **Bob (Coordination)** — sign-off final avant archive `PlatePilote_Campagne/`

---

## 11. Deliverables list — checklist exhaustive pour Kevin

Cocher en fin de production. Tout doit être livré pour clôture Sprint 9.

### 11.1 App icon (Sprint 7)
- [ ] `platepilote_icon_master_1024.png` (1024×1024)
- [ ] `platepilote_icon_ios_180.png` (180×180, @3x iPhone)
- [ ] `platepilote_icon_ios_167.png` (167×167, @2x iPad Pro)
- [ ] `platepilote_icon_ios_152.png` (152×152, @2x iPad)
- [ ] `platepilote_icon_ios_120.png` (120×120, @2x iPhone)
- [ ] `platepilote_icon_ios_87.png` (87×87, @3x Settings iPhone)
- [ ] `platepilote_icon_ios_60.png` (60×60, @2x Settings iPhone)
- [ ] `platepilote_icon_ios_40.png` (40×40, @2x Spotlight)
- [ ] `platepilote_icon_android_512.png` (512×512, Play Store)
- [ ] `platepilote_icon_android_192.png` (192×192, xxxhdpi)
- [ ] `platepilote_icon_android_144.png` (144×144, xxhdpi)
- [ ] `platepilote_icon_android_96.png` (96×96, xhdpi)
- [ ] `platepilote_icon_android_72.png` (72×72, hdpi)
- [ ] `platepilote_icon_android_48.png` (48×48, mdpi)
- [ ] `platepilote_icon_adaptive_fg_432.png` (Android adaptive foreground)
- [ ] `platepilote_icon_adaptive_bg_432.png` (Android adaptive background)
- [ ] `platepilote_icon_full_master.fig` (source Figma)

### 11.2 Empty states (Sprint 8)
- [ ] `platepilote_empty_pantry.svg`
- [ ] `platepilote_empty_pantry.png` (320×320)
- [ ] `platepilote_empty_pantry@2x.png` (640×640)
- [ ] `platepilote_empty_pantry_cream.png` (320×320 avec fond cream)
- [ ] `platepilote_empty_pantry_cream@2x.png` (640×640 avec fond cream)
- [ ] Idem ×3 pour : `expiring_soon`, `budget_celebration`, `swap_suggestion`
- [ ] `platepilote_empty_states_source.fig`

### 11.3 Feature graphic (Sprint 8)
- [ ] `platepilote_feature_graphic_v1.png` (1024×500, Google Play)
- [ ] `platepilote_feature_graphic_source.fig`
- [ ] Variante iOS App Store si nécessaire (1920×1080 ou 1242×2688 screenshot-style) — à confirmer Sprint 8

### 11.4 Promo video (Sprint 8)
- [ ] `platepilote_promo_video_30s_master.mp4` (1920×1080, 30fps, ≤100 MB)
- [ ] `platepilote_promo_video_30s_9x16.mp4` (1080×1920)
- [ ] `platepilote_promo_video_storyboard.pdf` (storyboard visuel 6 frames pour archive)
- [ ] `platepilote_promo_video_source.aep` ou `.mogrt` (After Effects / Premiere project file)

### 11.5 Logo extras (tous sprints, dès que §0 fait)
- [ ] `platepilote_full_mark_light.svg` + .png
- [ ] `platepilote_full_mark_dark.svg` + .png
- [ ] `platepilote_mark_only.svg` + .png (no wordmark, transparent BG)
- [ ] `platepilote_wordmark_only.svg` + .png
- [ ] `platepilote_safe_area_specs.pdf` (documentation des safe areas)

### 11.6 Mascot (Sprint 7 — optionnel, gated)
- [ ] `platepilote_mascot_platepilot_neutral.svg`
- [ ] `platepilote_mascot_platepilot_content.svg`
- [ ] `platepilote_mascot_platepilot_focused.svg`
- [ ] `platepilote_mascot_source.fig`
- [ ] Decision: OUI / NON à produire — décision Henry + Grace post-Sprint 6 review

---

## 12. Critères de qualité — acceptance criteria

Kevin auto-checke chaque livrable contre :

### 12.1 Technique
- [ ] Dimensions exactes (vérifiées via `identify` ou Figma inspect)
- [ ] Couleurs HEX matchent tokens §2.2 (vérifiées via color picker Figma)
- [ ] Naming snake_case respecte §8.1
- [ ] Source `.fig` livré en parallèle
- [ ] Poids fichier acceptable (§3.4 / §4.4 / §8.3)
- [ ] Pas de copyright artifacts (images vectorielles libres ou recréées)

### 12.2 Visuel
- [ ] Cohérence palette extraite logo §0 vs AppColors §2.2 — **CRITÈRE BLOQUANT** pour Sprint 7
- [ ] Test réduction 48×48 sur empty states (§4.2)
- [ ] Strokes 1.5pt consistants (pas de variation)
- [ ] Safe areas respectées (§2.3)
- [ ] Aucun texte/élément en bord d'image

### 12.3 Brand (Henry review)
- [ ] Tone "calme, sous-chef de poche" perceptible
- [ ] Pas de moralisation / urgence artificielle
- [ ] Decisions offertes vs prescrites (notamment empty states copy accompagnement)

---

## 13. Risques & dépendances

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Extraction palette logo (§0) révèle écart majeur vs AppColors | Bloquant Sprint 7 | Flag immédiat à Henry, alignement avant toute production icon |
| App icon concept ("assiette + élément central") jugé trop générique par Grace | Retard 1 sem | Présentation 3 concepts miniatures Sprint 6 fin, décision avant Sprint 7 |
| Promo video budget animation élevé | Décalage Sprint 8 | Recadrage en Lottie simple (animation seulement 0-5s et 25-30s) |
| Mascott bloquante | Sprints impactés | Décision Sprint 7 = NON, abandon §7 et recentrage §4 |
| Store rejekt sur app icon (Apple guidelines) | Soumission décalée | Anticiper guidelines iOS 18+ (rounded corners system, no transparency) |

---

## 14. Contacts & escalades

- **Production owner**: Kevin (kevin-illustrator)
- **Brand review**: Henry (henry-brand)
- **Design review**: Grace (grace-director)
- **Coordination & sign-off**: Bob (bob-coordinator)
- **Si contradiction brief vs design system existant**: Bob tranche, escalade Henry/Grace si décision stratégique

---

**FIN DU BRIEF v1**

Action immédiate Kevin : §0 (extraction visuelle logos) avant toute chose. Ensuite, validation par Henry + Grace du §2 (couleurs définitives). Puis Sprint 7 production §3.
