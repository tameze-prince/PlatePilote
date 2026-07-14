# ADR-0001 — JWT signing algorithm: stay HS256 for Beta, migrate to RS256 before public launch

Status: Accepted (2026-07-14)
Owners: Pierre (security), Mia (backend), Leo (eng manager)
Reviewers: Yara (legal/RGPD), Sara (PM)

## Context

PlatePilote currently signs JWT access and refresh tokens with HS256
(SecretKey derived from a shared Base64 secret in `app.jwt.secret`). The Pi0
audit (Jun 10 / Jun 16 / Jul 4) flagged this as the single highest-priority
security debt:

- A single shared secret travels across every backend service that must mint
  or verify tokens.
- The shared secret must live somewhere operationally (Kubernetes secret,
  Railway env, GitHub Actions secret) and is therefore a long-lived
  secret in many places.
- Compromise of any one component exposes signing to attackers who can then
  forge arbitrary tokens.

For the immediate Beta APK gate, this ADR records the decision to **keep
HS256 with strict operational guardrails** and schedule the **RS256
migration as a public-launch prerequisite**.

## Decision

### For Beta (now → public launch)

1. The Spring context **fails to start** if `app.jwt.secret` is empty or
   shorter than 64 Base64 chars. Implemented via `@PostConstruct` in
   `JwtService.requireJwtSecret()` and pinned by
   `JwtSecretFailFastTest`.
2. `.env.example` no longer ships a placeholder secret. Operators must
   source `JWT_SECRET` from a vault.
3. Production `JWT_SECRET` rotation requires redeploy + rolling restart.
   Documented in the deployment runbook.
4. Minimum rotation cadence: every 90 days during Beta.

### Migration path (deferred, NOT for this APK cycle)

Before public launch, switch to **RS256 (asymmetric)**:

- Generate an RSA 2048 key pair at deploy time (or load pre-existing PEMs
  from the vault). Public key is exposed via a JWKS endpoint
  (`/.well-known/jwks.json`) for any third-party that needs to verify
  tokens.
- `JwtService` switches `Jwts.builder().signWith(privateKey, Jwts.SIG.RS256)`
  and verification becomes `Jwts.parser().verifyWith(publicKey)`.
- Tokens issued before the cutover must remain verifiable for the
  longest refresh-window lifetime that overlaps the cutover (7 days),
  requiring a key-id (`kid`) header and a JWKS that exposes both old and
  new public keys for a transition window.
- Rollout: dual-signing for the transition window (a new token is signed
  with RS256; verification accepts RS256 first, then HS256 as fallback),
  then HS256 disabled.

## Consequences

### Positive (Beta stays on HS256)

- Zero operational change today; APK delivery date is not blocked.
- Refresh-token JWT flow is unchanged; clients do not need a new build for
  the algorithm switch.
- Existing DSR (`/api/v1/me`) module wires the same auth filter chain and
  inherits the hardening (PreAuthorize + JwtAuthenticationFilter).

### Negative

- The single shared secret still has blast radius if leaked. Mitigation:
  script-generated secret + vault + force rotation on any operator change.
- Until RS256 lands, third-party integrations (e.g. a future API public to
  partners) cannot verify PlatePilote tokens without the shared secret.

### Open items (RS256 migration)

- ADR review on cut-over mechanics (kid strategy, JWKS hosting,
  dual-sign window length).
- CI secrets hygiene audit for the HS256 window.
- Threat model update with Pierre + Yara.

## References

- AGENTS.md §6 (DoD: Si touche secret / key / config → rotation ou env var,
  jamais en clair).
- `BackEnd/.env.example` headers now empty (operators fill from vault).
- `BackEnd/src/.../JwtService.java::requireJwtSecret`.
- `BackEnd/src/test/.../JwtSecretFailFastTest.java` (3 tests).
- Audit log: `docs/AUDIT_BOB_2026-06-16.md` §"Top 5 P0".
