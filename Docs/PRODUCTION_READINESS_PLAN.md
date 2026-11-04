# PlatePilote — Production Readiness & Android Release Plan

> Status: execution plan, branch release/production-readiness
> Baseline: main at d5fab6b781b25426aa2c605cb51d2f7850ad65ef
> Scope: Flutter Android client, Spring Boot API, PostgreSQL/Flyway, CI/CD, release APK.
> This plan is a set of release gates, not a claim that the product is already production-ready.

## Product outcome

Ship a public Android application whose core user journeys work end-to-end against a deployed HTTPS API, with secure account handling, reliable data persistence, honest food/allergen information, recoverable failures, operational visibility, and a reproducible signed release build.

## Non-negotiable release principles

- Never suppress a failing analyzer, test, migration, or build to obtain a green badge.
- Never commit API keys, signing keys, passwords, production URLs containing credentials, or user data.
- Never use production Flyway migrations as a source of QA/demo accounts.
- Never claim allergen safety from incomplete or estimated ingredient data.
- Never ship debug-signed APKs as public release artifacts.
- Every security fix must include a regression test.
- Keep the modular monolith unless measured load or team boundaries justify a split.
- Keep existing migration history compatible; do not rewrite migrations that may already have run in deployed environments.

## Phase 0 — Baseline and product scope

**Deliverables**
- Confirm the exact Flutter app entry points, API contracts, enabled modules, environment variables, and current CI failures.
- Classify each feature as: public MVP, later release, or disabled until its dependency is configured.
- Add a feature-to-screen-to-endpoint acceptance matrix.
- Record baseline test/build results before changing behavior.

**Gate**
- All public MVP journeys have a defined owner, API contract, expected error states, and test path.
- No feature is presented as available if its backend/provider dependency is absent.

## Phase 1 — Critical backend security and data integrity

**Priority order**
1. JWT token-purpose separation: access, refresh, and password-reset tokens must have distinct claims and validators. Protected API requests accept access tokens only.
2. Account-state enforcement: disabled/deleted accounts cannot authenticate with previously issued access tokens.
3. Recipe authorization: public recipe endpoints expose only public, non-deleted recipes; private recipes are visible only to their owner. User-specific endpoints enforce ownership.
4. Meal-plan references: a user cannot add another user's private/deleted recipe to their plan.
5. Pantry quantity validation: consume amounts must be strictly positive and service-level validation must reject negative/zero quantities.
6. Rate limiting: trust forwarded IP headers only behind explicitly trusted proxies; bound/expire in-memory state and document that multi-instance deployments require a shared limiter.
7. Production seed hygiene: stop adding QA personas/admin accounts to production migration flow using a forward-only, compatibility-safe strategy.
8. Production persistence: Flyway owns schema changes; Hibernate validates rather than mutates production schema.
9. Error and log hygiene: no secrets or token-bearing query strings in logs; production errors do not disclose internals.

**Tests**
- Access token accepted; refresh/reset token rejected by bearer filter.
- Refresh rotation and revocation behavior remains valid.
- Disabled/deleted account cannot call authenticated endpoints.
- User A cannot read, update, or reference User B's private recipe.
- Public endpoints exclude private and deleted recipes.
- Pantry consume rejects zero/negative values and accepts valid positive amounts.
- Production profile starts with schema validation and does not create QA identities.

**Gate**
- Backend test suite passes, including regression tests for each P0/P1 finding.
- No known cross-account authorization issue remains in the MVP API surface.

## Phase 2 — Backend runtime and deployment reliability

**Deliverables**
- Fix the Docker build dependency-resolution failure without weakening dependency integrity.
- Align Docker image port, Spring profile, health check, and hosting platform expectations.
- Make production configuration explicit for DB, Redis, JWT, CORS, mail, storage, AI service, and Stripe.
- Validate required configuration at startup; optional integrations expose a clear unavailable state.
- Remove ddl-auto: update from production and use Flyway-only schema evolution.
- Verify Flyway version ordering and detect duplicate version numbers before release.
- Add readiness/liveness checks and avoid reporting healthy while critical dependencies are unavailable.
- Define backup, restore, migration rollback/forward-fix, and log-retention procedures.

**Gate**
- Reproducible Docker image builds.
- Production-profile startup succeeds with documented secrets/configuration.
- Health/readiness checks reflect actual application and database status.
- Migration test succeeds on a clean database and an upgrade fixture.

## Phase 3 — Food intelligence and catalog correctness

**Deliverables**
- Repair the empty recipe dataset input and the generator/migration version collision.
- Verify recipe, ingredient, recipe-ingredient, nutrition, and image referential integrity.
- Replace placeholder image paths with validated public asset URLs or a controlled storage strategy.
- Do not assert allergen flags as false when ingredient-level evidence is absent.
- Distinguish verified nutrition values from estimates and expose provenance/confidence.
- Add import validation, duplicate detection, and a reproducible catalog build.

**Tests**
- Every published recipe has required fields and valid ingredient links.
- Nutrition values are either sourced/marked estimated or absent.
- Unknown allergen status is not represented as allergen-free.
- Images resolve or gracefully fall back.

**Gate**
- Catalog has a documented source and licensing basis.
- Allergen and nutrition data are not marketed as medically reliable unless verified.

## Phase 4 — Flutter application completeness and resilience

**Deliverables**
- Remove runtime dependence on an untracked .env; define one documented build-time API URL mechanism.
- Ensure Android release builds cannot silently target localhost or an empty API URL.
- Fix token refresh to use a single-flight lock so simultaneous 401 responses do not race refresh-token rotation.
- Avoid logging request URLs containing tokens or sensitive query parameters.
- Verify secure storage behavior on Android and explicitly document the web token-storage limitation.
- Complete MVP screens and connect each action to its backend contract.
- Add loading, empty, offline, validation, permission-denied, and server-error states.
- Verify navigation, session restoration, logout, onboarding, and account deletion.
- Add accessibility checks for touch targets, semantics, contrast, and text scaling.

**Tests**
- Flutter analyzer exits non-zero on issues.
- Unit/widget tests cover the main flows and error states.
- API client tests cover expired access token, concurrent refresh, refresh failure, retry, and logout.
- Android smoke test exercises launch, login, core journey, and logout.

**Gate**
- No critical action is a dead button or mock-only screen in the public MVP.
- No API configuration failure is deferred until a user reaches an arbitrary screen.

## Phase 5 — CI/CD and Android release engineering

**Deliverables**
- Backend workflow: Maven verify, test reports, Docker build smoke test.
- Flutter workflow: pub get, format check, strict analyze, tests, Android release build.
- Run integration tests on an Android emulator (not only Linux-hosted unit tests).
- Replace debug APK artifact with release APK/AAB artifact.
- Configure release signing from CI secrets; do not commit keystore material.
- Add build metadata (version, build number, commit SHA) to release artifacts.
- Upload artifacts with checksums and retention policy.
- Protect main with required CI checks before merge.

**Gate**
- Required CI checks are green on the release branch and pull request.
- Signed release APK installs and launches on a clean Android device/emulator.
- The same commit can reproduce the release artifact.

## Phase 6 — Public beta and operational readiness

**Deliverables**
- Privacy policy, terms, support contact, account/data deletion instructions, and data-export scope.
- Verify consent, analytics, crash reporting, and retention behavior.
- Verify email verification/password reset in a real configured environment.
- Verify billing only if subscription purchase is enabled for the public MVP; otherwise disable entry points.
- Add crash/error telemetry with secrets and personal data redacted.
- Run API smoke tests, dependency checks, basic load tests, and a manual device matrix.
- Create rollback and incident-response notes.
- Publish a beta checklist and known-limitations page.

**Gate**
- No open critical/high security defect.
- No data-loss issue in core journeys.
- Privacy/legal content and support path are present.
- Public beta has monitoring and a tested rollback path.

## Release acceptance checklist

- [ ] Backend unit/integration tests pass.
- [ ] Flutter analyzer and tests pass without ignored failures.
- [ ] Docker image builds.
- [ ] Production profile starts with explicit configuration.
- [ ] Database migration succeeds on clean and upgrade fixtures.
- [ ] JWT purpose and account-state regression tests pass.
- [ ] Cross-user recipe access tests pass.
- [ ] Pantry quantity validation tests pass.
- [ ] Food catalog integrity and allergen provenance verified.
- [ ] Android integration smoke tests pass.
- [ ] Signed release APK/AAB installs and launches.
- [ ] Core MVP flows pass against the deployed HTTPS backend.
- [ ] Privacy, support, deletion, and operational documentation published.
- [ ] Release artifact checksum and commit SHA recorded.

## Known external prerequisites

The repository cannot supply these values. They must be configured by the owner in the hosting provider / GitHub secrets:
- Public HTTPS API base URL and allowed CORS origins.
- PostgreSQL and Redis production credentials.
- A unique, high-entropy Base64 JWT secret.
- SMTP credentials and verified sender/domain.
- R2/S3 credentials and public asset host if media upload is enabled.
- AI provider/service URL and credentials if AI features are enabled.
- Stripe keys/prices/webhook secret only if billing is enabled.
- Android upload keystore and passwords for signing.
- Privacy-policy URL, support email, and legal business details.

## Execution policy

Work in small, reviewable slices on release/production-readiness. Update this plan with evidence after each gate. Do not merge to main or publish a public release until the owner reviews the pull request and all release gates pass.

## Execution log — 2026-11-04

### Changes committed to `release/production-readiness`

- Account anonymization now removes the account's meal plans and all remaining references to its private recipes before deleting those recipes. This avoids foreign-key failures from `meal_plan_entries` and `user_interactions`.
- Added a service test asserting the required deletion order.
- Account deletion now revokes active refresh-token sessions immediately.
- Added a service test asserting refresh-token revocation during account deletion.
- The refresh endpoint now accepts the refresh token only in the JSON request body; the legacy query-parameter fallback was removed to avoid putting bearer-equivalent credentials in URLs.
- Removed the invalid production Flyway ignore pattern. Flyway ignore patterns use `type:status`; they do not support a migration-version segment.
- Clarified that historical migration V117 remains in the immutable migration chain and V119 disables the QA identities on production before the application serves requests.

### Verification status

The changes above are committed, but they are **not yet test-verified**.

- Backend Maven tests: not run in this environment.
- Docker image build: not run.
- Flutter analysis/tests: not run in this pass.
- PostgreSQL migration tests (clean and upgrade fixtures): not run.
- Android release APK/AAB: not built or signed.
- Android device installation/update tests: not run.
- The latest PR head has no GitHub Actions workflow runs visible through the connected GitHub status interface; the only reported commit status is the Vercel deployment status. Do not treat this as a passing CI result.

### Remaining release blockers discovered during implementation

1. Exercise the new billing cancellation outbox against PostgreSQL and Stripe test mode, including provider timeouts, duplicate delivery, retry exhaustion, and recovery after restart.
2. Verify the full V1–V123 migration chain against both a clean PostgreSQL database and a representative upgraded database. In particular, validate V117/V119 behavior with the actual production profile and Flyway version.
3. Verify the anonymization job against PostgreSQL foreign keys and every table introduced after V1; the current unit test is not a substitute for this integration test.
4. Configure production secrets and external services outside the repository: database, Redis, JWT, SMTP, storage, CORS, AI provider/service, Stripe (if billing is enabled), and the public HTTPS API URL.
5. Configure the Android upload keystore through GitHub Actions secrets, then run the release workflow and verify the APK/AAB signatures and installation.
6. Complete privacy/support/legal content, backup/restore verification, monitoring, and a real-device end-to-end test.

**Release decision:** keep PR #3 in draft. Do not merge or publish until the test and external-service gates above have evidence.

### Execution log — billing cancellation outbox — 2026-11-04

- Added migration V124 and a durable `billing_cancellation_requests` table. The request intentionally has no foreign key to the user so it survives account anonymization.
- Account deletion now writes or reuses a unique provider/subscription cancellation request in the same database transaction. It no longer calls Stripe synchronously.
- Premium entitlements are revoked immediately; the local subscription enters `CANCELLATION_PENDING` until the provider confirms cancellation.
- Added a scheduled worker that retries due requests with bounded exponential backoff. It marks successful requests `COMPLETED`; after 12 unsuccessful attempts it marks them `FAILED` and logs that manual action is required.
- Added unit tests for enqueueing the request and for worker success/retry behavior.

**Verification:** implementation and tests are committed, but no Maven or PostgreSQL test execution has been performed in this environment. The new migration, JPA mapping, pessimistic-lock behavior, Stripe idempotency under timeout, and recovery after worker restart still require integration verification.
