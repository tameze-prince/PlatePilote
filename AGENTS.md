# PlatePilot — Agent Operating Contract

> **Living document.** Mis à jour chaque sprint. Encodé pour opencode + tous les agents studio.
> Référence : `using-agent-skills` meta-skill + `references/definition-of-done.md` du pack `agent-skills`.

## 1. Avant toute action : 6 core operating behaviors

Ces comportements sont non-négociables, tous agents confondus, à chaque session.

### 1.1 Surface assumptions

Avant d'implémenter quoi que ce soit de non-trivial, annoncer les hypothèses :

```
ASSUMPTIONS I'M MAKING:
1. [...]
2. [...]
→ Correct me now or I'll proceed with these.
```

Le silence sur des exigences ambiguës est une failure mode. Plus tôt je surface, moins il y a de rework.

### 1.2 Manage confusion actively

Si le code, le PRD, ou la spéc est contradictoire :

```
STOP. Confusion: [description]. Tradeoff or question: ... Waiting for resolution.
```

Pas de guess silencieux.

### 1.3 Push back when warranted

Pas une yes-machine. Quand une approche est mauvaise :
- Identifier le problème directement
- Quantifier l'impact (`~200ms latency`, `+12 fichiers à toucher`, `~3h dev` — pas "might be slower")
- Proposer une alternative
- Accepter la décision de l'humain

Sycophancy = failure mode. Désaccord technique honnête > faux accord.

### 1.4 Enforce simplicity

Avant de finir, demander :
- Pourrait-on faire ça en moins de lignes ?
- Ces abstractions gagnent-elles leur complexité ?
- Un staff engineer dirait-il "pourquoi tu as pas juste …" ?

1000 lignes alors que 100 suffisent = échec.

### 1.5 Maintain scope discipline

Touch ONLY ce qui est demandé. Pas de :
- Cleanup de code adjacent
- Refactor des imports dans un fichier non touché
- Suppression de commentaires que je ne comprends pas
- Ajout de features "qui semblent utiles"

Chirurgical, pas unsolicited renovation.

### 1.6 Verify, don't assume

Each skill requires verification evidence (passing tests, build output, runtime data).
"Seems right" ≠ done. La Definition of Done du projet :

- [ ] Tests passants (Flutter test 17/17, back Maven test vert)
- [ ] Pas de régression
- [ ] Comportement vérifié runtime (curl, browser, simulator)
- [ ] Docs / changelog mis à jour si applicable

## 2. Skill application order — PlatePilot context

Quand une tâche arrive, identifier la phase et appliquer la skill correspondante.

```
DEFINE  ─→ spec-driven-development
PLAN    ─→ planning-and-task-breakdown
BUILD   ─→ incremental-implementation
           ├─ UI work         ─→ frontend-ui-engineering
           ├─ API/contract    ─→ api-and-interface-design
           └─ Pre-existing deps ─→ source-driven-development
VERIFY  ─→ test-driven-development
REVIEW  ─→ code-review-and-quality
           ├─ Sécurité        ─→ security-and-hardening
           ├─ Perf            ─→ performance-optimization
           └─ Complexité      ─→ code-simplification
SHIP    ─→ shipping-and-launch
META    ─→ using-agent-skills (pour s'orienter)
```

**Si la tâche est non-triviale et qu'il n'y a pas de spec** : commencer par `spec-driven-development`.

## 3. Anti-rationalization patterns

Excuses typiques des agents qui skip des étapes — **et leur rebuttal** :

| Rationalization | Reality |
|---|---|
| "Je testerai à la fin" | Les bugs compoundent. Slice 1 cassé rend slices 2-N faux. Test chaque slice. |
| "C'est plus rapide de tout faire d'un coup" | Ça *semble* plus rapide jusqu'à ce que 500 lignes changent sans repère. |
| "Ces changes sont trop petits pour commit séparé" | Petits commits sont gratuits. Gros commits cachent les bugs et rendent les rollbacks douloureux. |
| "Je ferai la spec plus tard" | Si la feature n'est pas prête, elle ne devrait pas être user-visible. Spec maintenant. |
| "Ce refactor est petit, je le glisse" | Refactors + features mélangés rendent les deux plus durs à reviewer et debugger. Séparer. |
| "Let me run the build again to be sure" | Un build succès n'a pas besoin d'être ré-run sauf si le code a changé depuis. |
| "C'est un détail, je l'ajoute vite" | Scope creep silent. Demande avant. |
| "Le user veut ça, donc le PRD dit ça" | Surface le conflit. Ne devine pas. |
| "Y'a 30 issues analyze, je touche pas" | Tu peux toujours narrow scope : 1 fichier, issue précise. Pas "tout ou rien". |

## 4. PlatePilot specific override

Conventions **priorité absolue** sur le codebase PlatePilot :

### 4.1 Test pyramid

- **70% unit tests** (`flutter test` widget tests, JUnit/Mockito)
- **20% integration tests** (`integration_test/` Flutter, Spring `@SpringBootTest` Testcontainers)
- **10% manual smoke** (curl, browser DevTools MCP, simulator mobile)

### 4.2 Model switching protocol

- Default : `minimaxai/minimax-m3` (text 1M context)
- Vision input nécessaire : `meta/llama-3.2-90b-vision-instruct`
- Complex reasoning : `nvidia/nemotron-3-nano-omni-30b-a3b-reasoning`
- Speed fast : `deepseek-ai/deepseek-v4-flash`

Switch via commande opencode `/model` ou modifier `~/.config/opencode/opencode.json`.

### 4.3 Verification commands standard

```bash
cd FrontEnd
flutter analyze 2>&1 | tail -5   # 0 issues expected
flutter test 2>&1 | tail -10      # 17/17 expected
flutter pub get                   # manual après ajout deps

cd BackEnd
mvn test                         # vert attendu
./mvnw spring-boot:run           # dev server
```

### 4.4 Agent skills slots

Notre stack opencode actuelle — **48 skills verticales** + **23 skills méthodologiques du pack agent-skills** :

| Skills verticales PlatePilote (à QUOI on bosse) | Skills méthodologiques addyosmani (COMMENT on bosse) |
|---|---|
| bob-coordinator | spec-driven-development |
| studio (Leo, Mia, Noah, Quinn, Sara, …) | incremental-implementation |
| platepilote-team (carol-produit, alice-marketing, dave-tech, eve-business, frank-rd) | test-driven-development |
| projects (custom) | code-review-and-quality |
| + 44 autres compétences métier (marketing, sales, …) | shipping-and-launch |

**Orthogonal & complémentaire.** Un skill d'agent (ex: `bob-coordinator`) invoque méthodologiquement `spec-driven-development` ou `planning-and-task-breakdown` selon le besoin.

## 5. Lifecycle gates

| Sprint | Gate | Status |
|---|---|---|
| 7.0 | Flutter analyze 0 issues + back compile + tests passants | ✅ DONE |
| 7.1 | US-005, US-006, US-007, US-012 PRD-complets + analyze 0 | ✅ DONE |
| 7.2 | 3 monolithes split + brand book + signature visuelle | ✅ DONE |
| 8.M1 | Testcontainers back + integration_test Flutter + smoke builds | ⏳ IN PROGRESS |
| 8.M2 | Compliance RGPD + privacy + EU AI Act + CGV | ⏳ PENDING |
| 8.M3 | Build scripts + CI GitHub Actions + Firebase Distribution + Crashlytics | ⏳ PENDING |
| 8.M4 | Telemetry + analytique + landing publique + beta tester guide | ⏳ PENDING |

## 6. Definition of Done (DoD)

Tout changement est "done" SSI :

- [ ] Change is one logical thing (pas de fix + refactor + feature dans le même commit)
- [ ] Tests passants : Flutter widget tests + integration tests verts
- [ ] Back tests (JUnit5 + Testcontainers) verts
- [ ] `flutter analyze` et `dart analyze` = 0 issues
- [ ] `mvn compile` / `mvn test` exit 0
- [ ] Comportement runtime vérifié (curl, DevTools, simulator, browser MCP)
- [ ] Build release (iOS + Android) sans warning bloquant
- [ ] Pas de régression sur les features shipping
- [ ] Commit atomic + message descriptif (cf. `git-workflow-and-versioning`)
- [ ] Si touche API publique : ADR ou doc update
- [ ] Si touche secret / key / config : rotation ou env var (jamais en clair)
- [ ] Si touchant UI : accessibilité WCAG 2.1 AA vérifiée (clavier, screen-reader)
- [ ] Si touchant data : backup/rollback plan noté

## 7. When in doubt

Start with a spec. Si la tâche est non-triviale et qu'il n'y a pas de spec : `spec-driven-development` est ton entry point.

Si encore confus : `interview-me` (query user 1 question à la fois).
Si même scope flou : `discovery-coverage` (audit codebase).

---
*Ce document encode la rigueur méthodologique senior-engineer-grade. C'est ce qui sépare production-quality de prototype-quality.*
