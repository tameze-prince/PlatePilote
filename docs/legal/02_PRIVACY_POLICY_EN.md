# Privacy Policy — PlatePilot

> Draft reference only. Canonical legal copy for implementation and publication is `docs/legal/Privacy_Policy_EN.md`.

**Last updated** : June 28, 2026  
**Data Controller** : Prince ZEUFACK TAMEZE — zeufacktameze@gmail.com

## 1. Data collected

| Category | Data | Legal basis | Max retention |
|---|---|---|---|
| Account | Email (or OAuth hash), display name, language | Art. 6(1)(b) contract | Account duration + 12 months |
| Food profile | Preferences, allergies, household size, weekly budget | Art. 6(1)(b) | Account duration |
| Meals & groceries | Generated meal plans, grocery lists, pantry inventory | Art. 6(1)(b) | Account duration |
| Payment | Stripe Customer ID (no card storage) | Art. 6(1)(b) | Account duration |
| Usage (analytics) | Page views, sessions, anonymized crash | Art. 6(1)(a) consent | 24 months |
| Push notification | FCM token | Art. 6(1)(a) consent | Until revocation |

## 2. Purposes

- Provide meal planning service
- Improve the app (anonymous stats)
- Send push notifications (with consent)
- Process payments via Stripe

## 3. Sub-processors

- **Backend hosting** : Railway / Render (EU/US — DPA signed)
- **Database** : Neon (Postgres, EU)
- **Cache** : Upstash (Redis, EU)
- **Images** : Cloudflare R2 (EU)
- **Analytics** : PostHog Cloud EU
- **Payments** : Stripe (PCI DSS certified)
- **Notifications** : Firebase Cloud Messaging (USA — SCC signed)

## 4. Your rights

Access, rectification, erasure, portability, objection, restriction.
Contact : zeufacktameze@gmail.com — response within 30 days.

## 5. Cookies

No third-party cookies. Session via JWT access tokens.

## 6. International transfers

Stripe (USA) and FCM (USA) — Standard Contractual Clauses (SCC) in place.

## 7. Security

HTTPS everywhere, short-lived JWT (15m access, 7d refresh), AES-256 encrypted refresh tokens.
