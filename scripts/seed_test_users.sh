#!/usr/bin/env bash
# =====================================================================
# seed_test_users.sh — Apply migration V117 against the configured DB.
# =====================================================================
#
# Context: PlatePilot V117 ships 5 deterministic test users (one per PRD
# persona). This script ensures the migration is applied against the target
# database regardless of whether the migrated environment was a clean install,
# a hot-add, or a fixture refresh.
#
# Usage:
#   export DATABASE_URL=postgres://user:pwd@host:port/platepilote
#   ./scripts/seed_test_users.sh
#
# Behaviour:
#   - Idempotent (uses ON CONFLICT DO NOTHING so re-running is safe).
#   - Prints the 5 credentials at the end so the operator can grab them.
#   - Exit code 0 = success; non-zero = migration failed (the bcrypt bootstrap
#     re-encoder runs at Spring boot to set the real hash; the placeholder
#     pattern in V117 is intentionally non-decodable so any login against the
#     placeholder would fail loudly).

set -euo pipefail

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "[seed_test_users] DATABASE_URL not set. Aborting." >&2
    exit 2
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATION="${REPO_ROOT}/BackEnd/src/main/resources/db/migration/V117__seed_test_users.sql"

if [[ ! -f "${MIGRATION}" ]]; then
    echo "[seed_test_users] Migration not found at ${MIGRATION}" >&2
    exit 2
fi

echo "[seed_test_users] Applying V117 to ${DATABASE_URL%/*}"
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -q -f "${MIGRATION}"

echo "[seed_test_users] ✓ V117 applied."
cat <<'EOF'

════════════ 5 test users ready ════════════
  u1-sarah         Busy Professional  (sarah.busypro@platepilote.test)        ROLE_USER
  u2-markjulia     Young Family         (family.youngparents@platepilote.test)  ROLE_USER
  u3-alex          Fitness/Vegetarian   (alex.fitness@platepilote.test)         ROLE_USER
  u4-emily         Budget/Vegetarian    (emily.budget@platepilote.test)         ROLE_USER
  u5-admin         Administrator        (admin@platepilote.test)                ROLE_USER + ADMIN + SUPER_ADMIN

Password (all five): Test123!

The BCrypt hashes are placeholders in V117. The Spring
CommandLineRunner TestUserHashBootstrap re-encodes them to a real
hash on first application boot (dev/test/default profiles).
═══════════════════════════════════════════════════
EOF
