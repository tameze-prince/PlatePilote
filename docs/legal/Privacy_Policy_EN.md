# Privacy Policy — PlatePilot

**Effective date: 2026-07-01**
**Last updated: 2026-07-01**

## 1. Who we are

PlatePilot is published by **PlatePilote SAS**, a *société par actions simplifiée* incorporated under French law.
Data Protection Officer contact: **dpo@platepilote.app**
Registered office: to be completed (RCS Paris).

## 2. What data we collect

We collect the following categories of data:

- **Account data**: email, password (BCrypt-hashed), display name, sign-up date.
- **Food preferences**: diet (omnivore, vegetarian, vegan, gluten-free, lactose-free), declared allergies, household size, cooking skill level.
- **Meal plan**: saved recipes, weekly schedule, consumed meals, generated shopping lists.
- **Pantry**: stored ingredients, add dates, quantities.
- **Usage data**: anonymized app events (opt-in analytics), technical logs (truncated IP, timestamp, error codes), app version, platform (iOS / Android).
- **Push notifications**: FCM token (Firebase Cloud Messaging) if you enable reminders.

## 3. Why we use them (purposes)

- Delivery of the core meal-planning and pantry management service.
- Personalization of recommendations based on your preferences and history.
- Product improvement (aggregated analytics, bug detection, performance metrics).
- Push notifications for reminders (only if you consented).
- Compliance with our legal and accounting obligations.

## 4. Legal basis

- **Contract performance** (PlatePilot Terms): for the meal-planning service, account management, preferences and pantry storage.
- **Consent** (GDPR art. 6.1.a): for analytics, push notifications, and any opt-in based processing.
- **Legitimate interest** (GDPR art. 6.1.f): for security (abuse prevention, logging), limited and proportionate.

## 5. Who can access them (processors and recipients)

Access restricted to authorized PlatePilot technical staff. Current processors:

- **Neon** — PostgreSQL database hosting (EU).
- **Firebase Cloud Messaging (Google)** — push notification delivery.
- **Stripe** — payment processing (only for future paid plans).
- **OpenAI / LLM providers** — *only if activated later* (Sprint 9+) for generative AI features, under a GDPR-compliant data processing agreement.

No transfers outside the EU without adequate safeguards (Standard Contractual Clauses, adequacy decision).

## 6. Retention periods

- **Active account**: data kept for as long as your account is active.
- **Soft-delete**: upon deletion request, your data enters a "deleted" state and is **graciously kept for 30 days** (cf. BR-008 — anti-impulse recovery window). After that, **hard-purge** is performed (irreversible deletion from primary database and backups).
- **Technical logs**: 90-day rolling window.
- **Accounting / invoicing data**: 10 years (French legal obligation).

## 7. Your GDPR rights

You have the following rights, exercisable at **dpo@platepilote.app**:

| Right | GDPR reference | Endpoint / action |
|---|---|---|
| Right of access | art. 15 | `GET /api/v1/me/data-export` |
| Right to rectification | art. 16 | `PATCH /api/v1/me/profile` |
| Right to erasure | art. 17 | `DELETE /api/v1/me/account` (triggers soft-delete 30d) |
| Right to restriction | art. 18 | `POST /api/v1/me/restrict-processing` |
| Right to portability | art. 20 | `GET /api/v1/me/data-export` (structured JSON export) |
| Right to object | art. 21 | `POST /api/v1/me/opt-out-analytics` |

Reply within **30 days**. In case of identity doubt, verification may be requested.

## 8. Security

- **Passwords** hashed with BCrypt (cost factor ≥ 12).
- **Authentication** via signed JWT, with planned key rotation.
- **Transport** encrypted (HTTPS / TLS 1.3).
- **Audit log** of personal data access.
- **Automated security tests** integrated into CI (cf. BR-007).
- **Security event logging** in `analytics_events` with category `security`.

## 9. Cookies and trackers

PlatePilot is a mobile application. We use only technically necessary local storage (auth token, local preferences). No advertising cookies, no third-party profiling trackers.

## 10. Changes to this policy

Any change will be published on this page with the header date updated. For material changes, you will be informed by email and/or in-app notification at least **30 days** before the new version takes effect.

---

*This document is provided for informational purposes and does not constitute legal advice. For any question, contact your DPO or your local data protection authority.*
