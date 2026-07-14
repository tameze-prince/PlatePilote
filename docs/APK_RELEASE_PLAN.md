# PlatePilote Functional Beta APK Release Plan

## Assumptions

1. Functional APK means Android beta APK with usable auth, onboarding, meal
   planning, grocery, pantry, profile/settings, legal consent, telemetry, and
   crash capture.
2. Compliance gates are implemented before distribution.
3. AI Act stance is Limited Risk: deterministic recommendation scoring, not
   generated-by-AI output.
4. Beta analytics requires explicit acceptance before beta use.
5. Existing staged changes are user-owned and must be preserved (but in this
   session they were reconciled as prior-agent work, see handoff).

## Atomic Checklist

### Handoff

- [x] Create `docs/AI_HANDOFF_LOOP.md`.
- [x] Create `docs/APK_RELEASE_PLAN.md`.
- [x] Create `docs/SKILL_MANIFEST.md`.

### Phase 1 — Legal And Consent

- [x] Mark short legal docs as draft pointers to canonical July docs.
- [x] Add consent persistence keys for analytics and push consent.
- [x] Add `/consent` route.
- [x] Gate authenticated app access behind beta analytics consent.
- [x] Add Settings links for privacy policy, beta terms, algorithmic
  recommendations, data export, analytics opt-out, and delete account.

### Phase 1 — Backend DSR

- [x] Restore live `me` module for `GET /api/v1/me/data-export`.
- [x] Restore live `DELETE /api/v1/me/account`.
- [x] Add `POST /api/v1/me/restrict-processing`.
- [x] Add `POST /api/v1/me/opt-out-analytics`.
- [x] Add backend tests for authenticated and unauthenticated DSR behavior.
- [x] Add Flyway migration `V118__user_data_rights_flags.sql` (analytics_opt_out,
  processing_restricted on our_user).
- [x] Add `analyticsOptOut` and `processingRestricted` fields on `OurUser`.

### Phase 1 — Frontend DSR

- [x] Add `DataRightsRepository`.
- [x] Add data export action.
- [x] Add analytics opt-out action.
- [x] Add destructive delete-account confirmation.
- [x] Add algorithmic recommendations disclosure sheet in Settings.

### Phase 1 — Verification Evidence (2026-07-14)

- `cd FrontEnd && flutter analyze` -> 0 issues, 13.7s.
- `cd FrontEnd && flutter test` -> 28/28 passing.
- `cd BackEnd && mvn test` -> 79 tests run, 0 failures, 0 errors, 19 skipped,
  BUILD SUCCESS.
- `cd BackEnd && mvn -Dtest='MeControllerSecurityTest' test` -> 8/8 passing:
  - 4 unauthenticated endpoints return 403 (PreAuthorize).
  - 4 authenticated endpoints delegate to `MeService` with correct user id and
    return the documented envelope.
- Settings build-context-across-async-gap warning fixed in
  `lib/features/settings/settings_screen.dart:730`.

### Phase 2 — Security And Backend Readiness

- [ ] Confirm JWT production posture (HS256 placeholder removal / RS256 plan).
- [ ] Verify DSR integration tests cover both happy + unhappy paths.
- [ ] Wire Testcontainers gate.

### Phase 3 — Telemetry And Crash Reporting

- [ ] Add PostHog dependency and consent-aware analytics adapter.
- [ ] Normalize event names to PRD/legal list.
- [ ] Add backend `TelemetryService` abstraction.
- [ ] Add Crashlytics dependency and error handlers.
- [ ] Add tests for consent-aware analytics.

### Phase 4 — Product Completion For APK

- [ ] Make remaining dead Settings taps functional.
- [ ] Remove hard-coded demo user from settings where user state exists.
- [ ] Localize new legal/data strings for EN/FR/DE.
- [ ] Validate core journey against the APK.

### Phase 5 — CI, Distribution, And Deployment

- [ ] Make mobile CI fail on `flutter analyze` issues.
- [ ] Add signed Android release workflow using GitHub secrets.
- [ ] Add Firebase App Distribution step guarded by secrets.
- [ ] Verify Railway deployment config and env var checklist.
- [ ] Sync landing legal pages and sitemap with canonical docs.

### Verification

- [x] `cd FrontEnd && flutter analyze`.
- [x] `cd FrontEnd && flutter test`.
- [ ] `cd FrontEnd && flutter test integration_test`.
- [x] `cd BackEnd && mvn test`.
- [ ] `cd FrontEnd && flutter build apk --debug`.
- [ ] Manual APK smoke path documented.

## Current Status

Phase 1 (Legal + Consent + DSR) is fully implemented and verified:

- FrontEnd `flutter analyze` clean.
- FrontEnd `flutter test` 28/28.
- BackEnd `mvn test` 79/0/19 with the new `MeControllerSecurityTest` (8 tests).
- The `me/` package compiles, integrates, and routes through the security
  filter chain with `PreAuthorize` enforcement.

Next phase (telemetry/Crashlytics) requires Flutter package additions
(posthog_flutter, firebase_crashlytics) AND secrets (PostHog EU API key,
real `firebase_options.dart`, Firebase project access). Those are not available
locally, so Phases 3–5 must be picked up by a future agent with secret
access or be staged by the user first.

## Blockers — Manual Inputs Required

- Firebase project access and real `firebase_options.dart`.
- Android signing keystore/secrets for signed release APK/AAB.
- PostHog EU API key.
- Backend production env vars.
- Railway deployment credentials.
- Legal entity fields still incomplete in canonical docs (registered office, RCS).
