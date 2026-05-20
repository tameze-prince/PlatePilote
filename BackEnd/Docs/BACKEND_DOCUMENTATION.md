# PlatePilot Backend — Complete Technical Documentation

**Version:** 2.0.0  
**Last Updated:** 20 May 2026  
**Repository:** `BackEnd/`  
**Status:** Production-Ready MVP

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Architecture Overview](#2-architecture-overview)
3. [Technology Stack](#3-technology-stack)
4. [Bounded Contexts & Modules](#4-bounded-contexts--modules)
5. [API Reference](#5-api-reference)
6. [Database Schema](#6-database-schema)
7. [Authentication & Authorization](#7-authentication--authorization)
8. [Recommendation Engine](#8-recommendation-engine)
9. [Core Business Logic](#9-core-business-logic)
10. [Performance Optimizations](#10-performance-optimizations)
11. [Security Architecture](#11-security-architecture)
12. [Infrastructure & Deployment](#12-infrastructure--deployment)
13. [Development Workflow](#13-development-workflow)
14. [Error Handling & Validation](#14-error-handling--validation)
15. [Testing Strategy](#15-testing-strategy)
16. [Frontend Integration Guide](#16-frontend-integration-guide)
17. [Monitoring & Observability](#17-monitoring--observability)
18. [Change Log](#18-change-log)

---

## 1. Executive Summary

### 1.1 Product Vision

PlatePilot is a mobile-first meal planning and grocery optimization platform that automates weekly meal planning, generates intelligent grocery lists, and manages pantry inventory — all in under 60 seconds of user interaction.

### 1.2 Backend Role

The backend is a **modular monolith** built with Spring Boot 3.2.5 and Java 21, implementing Domain-Driven Design (DDD) with 14 bounded contexts. It serves as the single source of truth for:

- **User identity & authentication** (JWT + OAuth2 Google/Apple)
- **Recipe intelligence** (canonical ingredient resolution, allergen mapping, pricing)
- **Meal plan generation** (multi-factor recommendation engine with <3s response time)
- **Grocery list generation** (ingredient aggregation, pantry subtraction, unit conversion)
- **Subscription & billing** (Stripe integration, freemium model)
- **Admin operations** (audit logs, feature flags, data imports)

### 1.3 Key Metrics

| Metric | Value |
|--------|-------|
| Total REST endpoints | 93 |
| Database tables | 46+ |
| Java source files | 131 |
| Test coverage | 27 unit tests |
| Recommendation response time | <3 seconds (target met) |
| DB queries per recommendation | ~8 (optimized from ~320) |
| Concurrent request capacity | 1,000+ (per PRD) |

---

## 2. Architecture Overview

### 2.1 Architectural Style

**Modular Monolith with Domain-Driven Design**

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  (REST Controllers — /api/v1/*)                         │
├─────────────────────────────────────────────────────────┤
│                   Application Layer                      │
│  (Services, DTOs, Use Cases)                            │
├─────────────────────────────────────────────────────────┤
│                     Domain Layer                         │
│  (Entities, Value Objects, Domain Services, Repos)      │
├─────────────────────────────────────────────────────────┤
│                  Infrastructure Layer                    │
│  (PostgreSQL, Redis, Stripe, SMTP, External APIs)       │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Module Dependency Graph

```
                    ┌──────────┐
                    │  Common   │
                    │ (kernel,  │
                    │  config,  │
                    │ security) │
                    └────┬─────┘
                         │
    ┌────────────────────┼────────────────────┐
    │                    │                    │
┌───┴────┐        ┌─────┴─────┐        ┌─────┴─────┐
│  Auth   │        │  Profile  │        │Preferences│
└───┬────┘        └─────┬─────┘        └─────┬─────┘
    │                   │                    │
    └───────────────────┼────────────────────┘
                        │
    ┌───────────────────┼────────────────────┐
    │                   │                    │
┌───┴────┐        ┌─────┴─────┐        ┌─────┴─────┐
│ Budget │        │  Pantry   │        │Ingredients│
└───┬────┘        └─────┬─────┘        └─────┬─────┘
    │                   │                    │
    └───────────────────┼────────────────────┘
                        │
    ┌───────────────────┼────────────────────┐
    │                   │                    │
┌───┴────┐        ┌─────┴─────┐        ┌─────┴─────┐
│Recipes │        │  Pricing  │        │Optimization│
└───┬────┘        └─────┬─────┘        └─────┬─────┘
    │                   │                    │
    └───────────────────┼────────────────────┘
                        │
              ┌─────────┴─────────┐
              │                   │
        ┌─────┴─────┐       ┌─────┴─────┐
        │Recommend  │       │Meal Plan  │
        │  Engine   │       │           │
        └─────┬─────┘       └─────┬─────┘
              │                   │
              └─────────┬─────────┘
                        │
                  ┌─────┴─────┐
                  │  Grocery  │
                  │   List    │
                  └───────────┘

    ┌─────────────────────────────────────────┐
    │  Cross-Cutting: Subscription, Billing,  │
    │  Notification, Admin, Imports           │
    └─────────────────────────────────────────┘
```

### 2.3 Package Structure

```
src/main/java/com/PlatePilot/PlatePilot/
├── PlatePilotApplication.java          # Spring Boot entry point
├── admin/                               # Admin dashboard & audit
│   ├── application/service/
│   ├── domain/entity/
│   ├── domain/repository/
│   └── presentation/
├── authentication/                      # Auth: register, login, OAuth2
│   ├── application/dto/
│   ├── application/service/
│   ├── application/config/
│   ├── domain/entity/
│   ├── domain/repository/
│   └── presentation/
├── billing/                             # Stripe billing integration
├── budget/                              # Budget tracking
├── common/                              # Shared infrastructure
│   ├── config/                          # CORS, JPA, OpenAPI, Mail, RestTemplate
│   ├── dto/                             # ApiResponse, PagedResponse
│   ├── exception/                       # GlobalExceptionHandler
│   ├── kernel/                          # BaseEntity, AuditableEntity, exceptions
│   └── security/                        # JWT, SecurityConfig, SecurityUtils
├── grocery/                             # Grocery list generation
├── ingredients/                         # Canonical ingredient resolution
├── mealplanning/                        # Meal plan CRUD + generation
├── notification/                        # Notification management
├── optimization/                        # Budget optimizer, pantry scorer
├── pantry/                              # Pantry inventory
├── preferences/                         # Dietary preferences & allergies
├── pricing/                             # Ingredient pricing & barcode lookup
├── recipes/                             # Recipe CRUD
├── recommendation/                      # Multi-factor recommendation engine
├── subscription/                        # Free/Premium subscription management
└── userprofile/                         # User profile management
```

---

## 3. Technology Stack

### 3.1 Core

| Component | Version | Purpose |
|-----------|---------|---------|
| Java      | 21      | Runtime language |
| Spring Boot | 3.2.5 | Application framework |
| Maven     | 3.9+    | Build tool |
| PostgreSQL | 16     | Primary database |
| Redis     | 7       | Cache layer |
| Flyway    | Latest  | Database migrations |

### 3.2 Libraries

| Library | Version | Purpose |
|---------|---------|---------|
| JJWT    | 0.12.5  | JWT token generation & validation |
| MapStruct | 1.5.5.Final | DTO mapping |
| Lombok  | Latest  | Boilerplate reduction |
| SpringDoc OpenAPI | 2.5.0 | Swagger/API documentation |
| Hibernate Envers | Latest | Entity auditing |
| Stripe Java SDK | 29.0.0 | Payment processing |
| EhCache | Latest | Hibernate L2 cache provider |
| Micrometer Prometheus | Latest | Metrics export |

### 3.3 Infrastructure

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| PostgreSQL | `postgres:16-alpine` | 5432 | Primary data store |
| Redis | `redis:7-alpine` | 6379 | Cache layer |
| Mailpit | `axllent/mailpit:latest` | 1025/8025 | Local email testing |

### 3.4 External Integrations

| Service | Purpose | Configuration |
|---------|---------|---------------|
| Google OAuth2 | Social login | `GOOGLE_OAUTH_CLIENT_IDS` |
| Apple Sign-In | Social login | `APPLE_OAUTH_CLIENT_IDS` |
| Stripe | Billing & subscriptions | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` |
| Brevo SMTP | Production email | `BREVO_SMTP_USERNAME`, `BREVO_SMTP_KEY` |
| USDA FoodData Central | Ingredient data import | `USDA_API_KEY` |
| Open Food Facts | Product data import | (no key required) |
| TheMealDB | Recipe data import | `THEMEALDB_API_KEY` |

---

## 4. Bounded Contexts & Modules

### 4.1 Authentication (`authentication/`)

**Responsibility:** User registration, login, session management, email verification, OAuth2.

**Entities:**
- `OurUser` — Core user account (email, password hash, roles, emailVerified)
- `Role` — RBAC role (USER, PREMIUM_USER, ADMIN, SUPER_ADMIN, etc.)
- `RefreshToken` — SHA-256 hashed refresh tokens
- `EmailVerificationToken` — One-time email verification tokens

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/auth/register` | No | Register with email/password |
| POST | `/api/v1/auth/login` | No | Login with email/password |
| POST | `/api/v1/auth/oauth2` | No | Login with Google/Apple ID token |
| POST | `/api/v1/auth/refresh` | No | Refresh access token |
| POST | `/api/v1/auth/logout` | No | Revoke a refresh token |
| POST | `/api/v1/auth/logout-all` | No | Revoke all refresh tokens |
| GET | `/api/v1/auth/verify-email` | No | Verify email with token |
| POST | `/api/v1/auth/resend-verification` | No | Resend verification email |

**Security Details:**
- Passwords hashed with BCrypt (10 rounds)
- Access tokens: JWT HS512, 1-hour TTL
- Refresh tokens: SHA-256 hashed, 7-day TTL
- OAuth2: OIDC JWT verification for Google + Apple
- Email verification tokens: 24-hour TTL, single-use

### 4.2 User Profile (`userprofile/`)

**Responsibility:** Physical attributes, health goals, location, cooking skill.

**Entity:** `UserProfile` — one-to-one with `OurUser`

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| `dateOfBirth` | LocalDate | — | null |
| `gender` | String | max 20 chars | null |
| `heightCm` | BigDecimal | 50–300 | null |
| `weightKg` | BigDecimal | 20–500 | null |
| `activityLevel` | String | max 30 chars | null |
| `healthGoals` | String | TEXT | null |
| `countryCode` | String | 2 chars (ISO 3166-1) | "US" |
| `currencyCode` | String | max 4 chars (ISO 4217) | "USD" |
| `locale` | String | max 20 chars | "en-US" |
| `cookingSkill` | String | max 20 chars | "BEGINNER" |
| `householdSize` | Integer | 1–20 | 1 |

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/profile` | Yes | Get profile (returns defaults if none exists) |
| PUT | `/api/v1/profile` | Yes | Create or update profile |
| DELETE | `/api/v1/profile` | Yes | Soft-delete profile |

### 4.3 Preferences (`preferences/`)

**Responsibility:** Dietary preferences and allergy management.

**Entities:**
- `DietaryPreference` — user + diet type (vegetarian, vegan, keto, etc.)
- `Allergy` — user + allergen + severity

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/preferences/diets` | Yes | List user's dietary preferences |
| POST | `/api/v1/preferences/diets` | Yes | Add dietary preference |
| DELETE | `/api/v1/preferences/diets/{dietType}` | Yes | Remove dietary preference |
| GET | `/api/v1/preferences/allergies` | Yes | List user's allergies |
| POST | `/api/v1/preferences/allergies` | Yes | Add allergy |
| DELETE | `/api/v1/preferences/allergies/{allergen}` | Yes | Remove allergy |

### 4.4 Budget (`budget/`)

**Responsibility:** Weekly/monthly budget tracking.

**Entity:** `Budget` — user + amount + currency + period + date range

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/budgets` | Yes | List budgets (paginated) |
| POST | `/api/v1/budgets` | Yes | Create budget |
| DELETE | `/api/v1/budgets/{id}` | Yes | Soft-delete budget |

### 4.5 Pantry (`pantry/`)

**Responsibility:** User's kitchen inventory management.

**Entity:** `PantryItem` — user + ingredient + quantity + unit + expiration date

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/pantry` | Yes | List pantry items (paginated) |
| POST | `/api/v1/pantry` | Yes | Add pantry item |
| PUT | `/api/v1/pantry/{id}` | Yes | Update pantry item |
| DELETE | `/api/v1/pantry/{id}` | Yes | Soft-delete pantry item |
| POST | `/api/v1/pantry/{id}/consume` | Yes | Consume quantity from item |
| GET | `/api/v1/pantry/search` | Yes | Search pantry by name |
| GET | `/api/v1/pantry/category/{category}` | Yes | Filter by category |
| GET | `/api/v1/pantry/expiring` | Yes | Get items expiring within N days |

### 4.6 Ingredients (`ingredients/`)

**Responsibility:** Canonical ingredient database with alias resolution and allergen mapping.

**Entities:**
- `Ingredient` — canonical name, slug, category, nutrition data, allergen flags
- `IngredientAlias` — alternative names mapped to canonical ingredient
- `IngredientAllergen` — ingredient-to-allergen-group mapping

**Resolution Flow:**
```
User input: "All-purpose flour"
    ↓
IngredientResolutionService.resolveIngredientId()
    ↓
Search aliases → find "all purpose flour" → map to canonical "Flour" (UUID)
    ↓
Return canonical ingredient ID for pricing, pantry matching, allergen checks
```

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/ingredients/search` | No | Search ingredients (cached) |
| GET | `/api/v1/ingredients/slug/{slug}` | No | Get ingredient by slug (cached) |
| GET | `/api/v1/ingredients/{id}` | No | Get ingredient by ID (cached) |
| GET | `/api/v1/ingredients/category/{category}` | No | Get ingredients by category (cached) |

### 4.7 Recipes (`recipes/`)

**Responsibility:** Recipe CRUD with ingredients and steps.

**Entities:**
- `Recipe` — name, description, times, servings, difficulty, cuisine, meal type, dietary flags, allergen flags, nutrition data
- `RecipeIngredient` — recipe + ingredient name + quantity + unit + sortOrder
- `RecipeStep` — recipe + step number + instruction + duration

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/recipes/public` | No | Browse public recipes (paginated) |
| GET | `/api/v1/recipes/public/search` | No | Search recipes |
| GET | `/api/v1/recipes/public/cuisine/{type}` | No | Filter by cuisine |
| GET | `/api/v1/recipes/public/meal/{type}` | No | Filter by meal type |
| GET | `/api/v1/recipes/public/{id}` | No | Get recipe detail |
| GET | `/api/v1/recipes/my` | Yes | Get user's personal recipes |
| GET | `/api/v1/recipes/my/{id}` | Yes | Get user's recipe detail |
| POST | `/api/v1/recipes` | Yes | Create recipe |
| PUT | `/api/v1/recipes/{id}` | Yes | Update recipe |
| DELETE | `/api/v1/recipes/{id}` | Yes | Soft-delete recipe |

### 4.8 Meal Planning (`mealplanning/`)

**Responsibility:** Weekly meal plan creation, management, and auto-generation.

**Entities:**
- `MealPlan` — user + name + date range + status (DRAFT/ACTIVE)
- `MealPlanEntry` — plan + recipe + date + meal type + servings + notes

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/meal-plans` | Yes | List user's meal plans (paginated) |
| GET | `/api/v1/meal-plans/{id}` | Yes | Get meal plan with entries |
| POST | `/api/v1/meal-plans` | Yes | Create meal plan |
| POST | `/api/v1/meal-plans/generate` | Yes | Auto-generate weekly plan |
| POST | `/api/v1/meal-plans/{id}/entries` | Yes | Add meal entry |
| DELETE | `/api/v1/meal-plans/entries/{entryId}` | Yes | Remove meal entry |
| POST | `/api/v1/meal-plans/{id}/activate` | Yes | Activate plan |
| DELETE | `/api/v1/meal-plans/{id}` | Yes | Soft-delete plan |

### 4.9 Grocery (`grocery/`)

**Responsibility:** Grocery list generation from meal plans with pantry subtraction and price estimation.

**Entities:**
- `GroceryList` — user + name + status (ACTIVE/COMPLETED)
- `GroceryItem` — list + name + category + quantity + unit + estimated price + checked + ingredientId + priceConfidence

**Generation Algorithm:**
```
1. Fetch all meal plan entries
2. For each entry, fetch recipe ingredients
3. Aggregate ingredients by canonical ID (or name + unit family)
4. Load user's pantry items matching recipe ingredient IDs
5. Subtract pantry quantities from required quantities
6. Estimate prices using regional pricing data
7. Create grocery list with remaining items
```

**Unit Conversion:**
- Mass: g, kg (base: g)
- Volume: ml, l, tsp, tbsp, cup (base: ml)
- Cross-family conversion blocked (mass ≠ volume)

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/grocery-lists` | Yes | List grocery lists (paginated) |
| GET | `/api/v1/grocery-lists/{id}` | Yes | Get list with items |
| POST | `/api/v1/grocery-lists` | Yes | Create list |
| POST | `/api/v1/grocery-lists/{id}/items` | Yes | Add item |
| PUT | `/api/v1/grocery-lists/items/{itemId}/toggle` | Yes | Toggle checked |
| DELETE | `/api/v1/grocery-lists/items/{itemId}` | Yes | Remove item |
| POST | `/api/v1/grocery-lists/from-plan/{planId}` | Yes | Generate from meal plan |
| POST | `/api/v1/grocery-lists/{id}/complete` | Yes | Mark as completed |
| DELETE | `/api/v1/grocery-lists/{id}` | Yes | Soft-delete list |

### 4.10 Recommendation Engine (`recommendation/`)

**Responsibility:** Multi-factor recipe scoring and recommendation generation.

**See detailed section:** [8. Recommendation Engine](#8-recommendation-engine)

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/recommendations` | Yes | Get recipe recommendations |
| POST | `/api/v1/recommendations/quick-meal` | Yes | Get quick meal suggestions |
| POST | `/api/v1/recommendations/weekly-plan` | Yes | Generate weekly meal plan |

### 4.11 Pricing (`pricing/`)

**Responsibility:** Ingredient pricing by country and barcode product lookup.

**Entities:**
- `IngredientPrice` — ingredient + country + price per unit + effective date
- `BarcodeProduct` — barcode + product name + brand + category

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/pricing/barcode/{barcode}` | No | Lookup product by barcode |

### 4.12 Subscription (`subscription/`)

**Responsibility:** Free/Premium subscription management and entitlement.

**Entities:**
- `Subscription` — user + plan type (FREE/PREMIUM) + status + dates
- `UserEntitlement` — user + entitlement type + provider + expires at

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/subscription` | Yes | Get subscription (auto-creates FREE if none) |
| POST | `/api/v1/subscription/upgrade` | Admin only | Upgrade to Premium |
| POST | `/api/v1/subscription/cancel` | Yes | Cancel subscription |

### 4.13 Billing (`billing/`)

**Responsibility:** Stripe checkout, customer portal, webhook processing.

**Entities:**
- `BillingCustomer` — user + Stripe customer ID
- `BillingEvent` — event type + Stripe event ID + processed status

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/billing/stripe/checkout` | Yes | Create checkout session |
| POST | `/api/v1/billing/stripe/portal` | Yes | Create customer portal session |
| POST | `/api/v1/billing/stripe/webhook` | No | Stripe webhook (signature verified) |

### 4.14 Notification (`notification/`)

**Responsibility:** User notification management (read/manage stored notifications).

**Entity:** `Notification` — user + type + title + body + data + read status

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/notifications` | Yes | List notifications (paginated) |
| GET | `/api/v1/notifications/unread` | Yes | List unread notifications |
| GET | `/api/v1/notifications/unread/count` | Yes | Get unread count |
| PUT | `/api/v1/notifications/{id}/read` | Yes | Mark as read |
| PUT | `/api/v1/notifications/read-all` | Yes | Mark all as read |
| DELETE | `/api/v1/notifications/{id}` | Yes | Soft-delete notification |

### 4.15 Admin (`admin/`)

**Responsibility:** Administrative operations, audit logging, feature flags, system settings.

**Entities:**
- `AuditLog` — action + user + details + timestamp
- `FeatureFlag` — key + enabled + description
- `SystemSetting` — key + value (used for recommendation weights, quotas)
- `AdminNote` — user + note + admin
- `AiUsageMetric` — metric type + value + timestamp

**Key Endpoints:** (18 endpoints, all role-gated to ADMIN/SUPER_ADMIN)
- User management (search, suspend, role update)
- Recipe/ingredient browsing
- Import management
- Subscription browsing
- Audit logs
- Feature flags CRUD
- System settings CRUD
- Recommendation analytics
- Billing events

### 4.16 Imports (`imports/`)

**Responsibility:** External data import from USDA, Open Food Facts, TheMealDB.

**Entity:** `ImportJob` — source + status + records processed + errors

**Services:**
- `UsdaImporter` — USDA FoodData Central API
- `OpenFoodFactsImporter` — Open Food Facts API
- `MealDbImporter` — TheMealDB API
- `IngredientNormalizer` — canonical name normalization
- `ImportService` — orchestrator with async processing + scheduled nightly imports

**Key Endpoints:**
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/imports/usda` | Admin | Trigger USDA import |
| POST | `/api/v1/imports/openfoodfacts` | Admin | Trigger Open Food Facts import |
| POST | `/api/v1/imports/mealdb` | Admin | Trigger TheMealDB import |

---

## 5. API Reference

### 5.1 Base URL

```
http://localhost:8081/api/v1
```

### 5.2 Authentication

All authenticated endpoints require:
```
Authorization: Bearer <JWT_ACCESS_TOKEN>
```

### 5.3 Response Format

**Success:**
```json
{
  "success": true,
  "message": "Optional message",
  "data": { ... },
  "timestamp": "2026-05-20T12:00:00.000Z"
}
```

**Paginated:**
```json
{
  "success": true,
  "data": {
    "content": [ ... ],
    "page": 0,
    "size": 20,
    "totalElements": 150
  },
  "timestamp": "2026-05-20T12:00:00.000Z"
}
```

**Error:**
```json
{
  "status": 400,
  "message": "Validation failed",
  "timestamp": "2026-05-20T12:00:00.000Z",
  "errors": {
    "fieldName": "Error message"
  }
}
```

### 5.4 Complete Endpoint Matrix

| Module | Method | Path | Auth | Role | Description |
|--------|--------|------|------|------|-------------|
| **Auth** | POST | `/auth/register` | No | — | Register |
| | POST | `/auth/login` | No | — | Login |
| | POST | `/auth/oauth2` | No | — | OAuth2 login |
| | POST | `/auth/refresh` | No | — | Refresh token |
| | POST | `/auth/logout` | No | — | Logout (single) |
| | POST | `/auth/logout-all` | No | — | Logout (all devices) |
| | GET | `/auth/verify-email` | No | — | Verify email |
| | POST | `/auth/resend-verification` | No | — | Resend email |
| **Profile** | GET | `/profile` | Yes | — | Get profile |
| | PUT | `/profile` | Yes | — | Update profile |
| | DELETE | `/profile` | Yes | — | Delete profile |
| **Preferences** | GET | `/preferences/diets` | Yes | — | List diets |
| | POST | `/preferences/diets` | Yes | — | Add diet |
| | DELETE | `/preferences/diets/{type}` | Yes | — | Remove diet |
| | GET | `/preferences/allergies` | Yes | — | List allergies |
| | POST | `/preferences/allergies` | Yes | — | Add allergy |
| | DELETE | `/preferences/allergies/{allergen}` | Yes | — | Remove allergy |
| **Budget** | GET | `/budgets` | Yes | — | List budgets |
| | POST | `/budgets` | Yes | — | Create budget |
| | DELETE | `/budgets/{id}` | Yes | — | Delete budget |
| **Pantry** | GET | `/pantry` | Yes | — | List items |
| | POST | `/pantry` | Yes | — | Add item |
| | PUT | `/pantry/{id}` | Yes | — | Update item |
| | DELETE | `/pantry/{id}` | Yes | — | Delete item |
| | POST | `/pantry/{id}/consume` | Yes | — | Consume |
| | GET | `/pantry/search` | Yes | — | Search |
| | GET | `/pantry/category/{cat}` | Yes | — | By category |
| | GET | `/pantry/expiring` | Yes | — | Expiring items |
| **Ingredients** | GET | `/ingredients/search` | No | — | Search |
| | GET | `/ingredients/slug/{slug}` | No | — | By slug |
| | GET | `/ingredients/{id}` | No | — | By ID |
| | GET | `/ingredients/category/{cat}` | No | — | By category |
| **Recipes** | GET | `/recipes/public` | No | — | Browse |
| | GET | `/recipes/public/search` | No | — | Search |
| | GET | `/recipes/public/cuisine/{type}` | No | — | By cuisine |
| | GET | `/recipes/public/meal/{type}` | No | — | By meal type |
| | GET | `/recipes/public/{id}` | No | — | Detail |
| | GET | `/recipes/my` | Yes | — | My recipes |
| | GET | `/recipes/my/{id}` | Yes | — | My recipe detail |
| | POST | `/recipes` | Yes | — | Create |
| | PUT | `/recipes/{id}` | Yes | — | Update |
| | DELETE | `/recipes/{id}` | Yes | — | Delete |
| **Meal Plans** | GET | `/meal-plans` | Yes | — | List |
| | GET | `/meal-plans/{id}` | Yes | — | Detail |
| | POST | `/meal-plans` | Yes | — | Create |
| | POST | `/meal-plans/generate` | Yes | — | Auto-generate |
| | POST | `/meal-plans/{id}/entries` | Yes | — | Add entry |
| | DELETE | `/meal-plans/entries/{id}` | Yes | — | Remove entry |
| | POST | `/meal-plans/{id}/activate` | Yes | — | Activate |
| | DELETE | `/meal-plans/{id}` | Yes | — | Delete |
| **Grocery** | GET | `/grocery-lists` | Yes | — | List |
| | GET | `/grocery-lists/{id}` | Yes | — | Detail |
| | POST | `/grocery-lists` | Yes | — | Create |
| | POST | `/grocery-lists/{id}/items` | Yes | — | Add item |
| | PUT | `/grocery-lists/items/{id}/toggle` | Yes | — | Toggle check |
| | DELETE | `/grocery-lists/items/{id}` | Yes | — | Remove item |
| | POST | `/grocery-lists/from-plan/{planId}` | Yes | — | Generate |
| | POST | `/grocery-lists/{id}/complete` | Yes | — | Complete |
| | DELETE | `/grocery-lists/{id}` | Yes | — | Delete |
| **Pricing** | GET | `/pricing/barcode/{code}` | No | — | Barcode lookup |
| **Recommend** | GET | `/recommendations` | Yes | — | Get recommendations |
| | POST | `/recommendations/quick-meal` | Yes | — | Quick meals |
| | POST | `/recommendations/weekly-plan` | Yes | — | Weekly plan |
| **Notifications** | GET | `/notifications` | Yes | — | List |
| | GET | `/notifications/unread` | Yes | — | Unread list |
| | GET | `/notifications/unread/count` | Yes | — | Unread count |
| | PUT | `/notifications/{id}/read` | Yes | — | Mark read |
| | PUT | `/notifications/read-all` | Yes | — | Mark all read |
| | DELETE | `/notifications/{id}` | Yes | — | Delete |
| **Subscription** | GET | `/subscription` | Yes | — | Get subscription |
| | POST | `/subscription/upgrade` | Yes | ADMIN | Upgrade |
| | POST | `/subscription/cancel` | Yes | — | Cancel |
| **Billing** | POST | `/billing/stripe/checkout` | Yes | — | Checkout |
| | POST | `/billing/stripe/portal` | Yes | — | Portal |
| | POST | `/billing/stripe/webhook` | No | — | Webhook |
| **Admin** | GET | `/admin/overview` | Yes | ADMIN+ | Dashboard |
| | GET | `/admin/users` | Yes | ADMIN+ | List users |
| | PUT | `/admin/users/{id}/suspend` | Yes | ADMIN+ | Suspend user |
| | PUT | `/admin/users/{id}/roles` | Yes | SUPER_ADMIN | Update roles |
| | GET | `/admin/recipes` | Yes | ADMIN+ | Browse recipes |
| | GET | `/admin/ingredients` | Yes | ADMIN+ | Browse ingredients |
| | GET | `/admin/imports` | Yes | ADMIN+ | Import jobs |
| | GET | `/admin/subscriptions` | Yes | ADMIN+ | Subscriptions |
| | GET | `/admin/audit-logs` | Yes | ADMIN+ | Audit logs |
| | GET | `/admin/feature-flags` | Yes | ADMIN+ | Feature flags |
| | POST | `/admin/feature-flags` | Yes | SUPER_ADMIN | Create flag |
| | PUT | `/admin/feature-flags/{id}` | Yes | SUPER_ADMIN | Update flag |
| | DELETE | `/admin/feature-flags/{id}` | Yes | SUPER_ADMIN | Delete flag |
| | GET | `/admin/settings` | Yes | ADMIN+ | System settings |
| | PUT | `/admin/settings/{key}` | Yes | ADMIN+ | Update setting |
| | GET | `/admin/recommendation-analytics` | Yes | ADMIN+ | Analytics |
| | GET | `/admin/billing-events` | Yes | ADMIN+ | Billing events |
| **Imports** | POST | `/imports/usda` | Yes | ADMIN+ | USDA import |
| | POST | `/imports/openfoodfacts` | Yes | ADMIN+ | OFF import |
| | POST | `/imports/mealdb` | Yes | ADMIN+ | MealDB import |

---

## 6. Database Schema

### 6.1 Migration History

| Migration | Purpose |
|-----------|---------|
| `V1__init_schema.sql` | All base tables |
| `V2__seed_data.sql` | Seed data |
| `V3__food_intelligence.sql` | Ingredients, aliases, allergens, prices |
| `V100__seed_food_intelligence.sql` | Food intelligence seed data |
| `V101__core_v1_authorization_recommendations_admin.sql` | RBAC, profile location fields, admin tables |
| `V102__auth_refresh_token_hardening.sql` | Refresh token security |
| `V103__subscription_entitlements.sql` | Subscription provider fields, entitlements |
| `V104__recipe_data_quality.sql` | Recipe verification, confidence, allergens, nutrition |
| `V105__grocery_canonical_ingredients.sql` | Grocery item ingredient_id, price_confidence |
| `V106__stripe_billing_foundation.sql` | Billing customers, billing events |
| `V107__recommendation_feedback_allergens.sql` | User interactions, recipe allergen flags |
| `V108__grocery_price_confidence.sql` | Grocery price confidence improvements |
| `V109__performance_indexes.sql` | 14 performance indexes on hot query paths |
| `V110__increase_currency_code_length.sql` | currency_code VARCHAR(3) → VARCHAR(4) |

### 6.2 Core Tables

```
users (id, email, password_hash, first_name, last_name, email_verified, created_at, updated_at, last_login)
roles (id, name)
user_roles (user_id, role_id)
refresh_tokens (id, user_id, token_hash, expires_at, created_at)
email_verification_tokens (id, user_id, token, expires_at, used, created_at)

user_profiles (id, user_id, date_of_birth, gender, height_cm, weight_kg, activity_level, health_goals, country_code, currency_code, locale, cooking_skill, household_size, created_at, updated_at)

dietary_preferences (id, user_id, diet_type, created_at, deleted_at)
allergies (id, user_id, allergen, severity, created_at, deleted_at)

budgets (id, user_id, amount, currency, period, start_date, end_date, created_at, updated_at, deleted_at)

pantry_items (id, user_id, name, category, quantity, unit, expiration_date, ingredient_id, created_at, updated_at, deleted_at)

ingredients (id, canonical_name, slug, category, description, default_unit, nutrition fields..., allergen flags..., source info, created_at, updated_at, deleted_at)
ingredient_aliases (id, ingredient_id, alias_name, created_at)
ingredient_allergens (id, ingredient_id, allergen_group, confidence_score, source, created_at)
ingredient_prices (id, ingredient_id, country_code, price_per_unit, unit, effective_date, source, created_at)

recipes (id, user_id, name, description, prep_time, cook_time, total_time, servings, difficulty, cuisine_type, meal_type, image_url, source, is_public, enabled, verified, verification_status, confidence_score, nutrition fields..., allergen flags..., estimated_cost, created_at, updated_at, deleted_at)
recipe_ingredients (id, recipe_id, name, quantity, unit, notes, sort_order, ingredient_id)
recipe_steps (id, recipe_id, step_number, instruction, duration_minutes)

meal_plans (id, user_id, name, start_date, end_date, status, created_at, updated_at, deleted_at)
meal_plan_entries (id, meal_plan_id, recipe_id, meal_date, meal_type, servings, notes)

grocery_lists (id, user_id, name, status, created_at, updated_at, deleted_at)
grocery_items (id, grocery_list_id, name, category, quantity, unit, estimated_price, price_confidence, checked, notes, ingredient_id, sort_order)

recommendation_events (id, user_id, request_type, country_code, currency_code, result_count, duration_ms, quota_limited, created_at)
user_interactions (id, user_id, recipe_id, interaction_type, created_at)

notifications (id, user_id, type, title, body, data, is_read, read_at, created_at, deleted_at)

subscriptions (id, user_id, plan_type, status, start_date, end_date, trial_end_date, cancel_at_period_end, provider, expires_at, last_verified_at, created_at, updated_at)
user_entitlements (id, user_id, entitlement_type, provider, expires_at, created_at, updated_at)

billing_customers (id, user_id, stripe_customer_id, created_at, updated_at)
billing_events (id, stripe_event_id, event_type, processed, created_at)

audit_logs (id, action, user_id, details, created_at)
feature_flags (id, key, enabled, description, created_at, updated_at)
system_settings (id, setting_key, setting_value, created_at, updated_at)
admin_notes (id, user_id, note, admin_id, created_at)
ai_usage_metrics (id, metric_type, value, created_at)

import_jobs (id, source, status, records_processed, errors, started_at, completed_at, created_at)
```

### 6.3 Indexes (V109)

| Index | Table | Columns | Purpose |
|-------|-------|---------|---------|
| `idx_ri_recipe_id` | recipe_ingredients | recipe_id | Recipe detail, allergen checks, grocery generation |
| `idx_mpe_plan_id` | meal_plan_entries | meal_plan_id | Meal plan detail views |
| `idx_gi_list_id` | grocery_items | grocery_list_id | Grocery list views |
| `idx_pantry_user_ingredient` | pantry_items | user_id, ingredient_id (partial) | Grocery pantry subtraction |
| `idx_pantry_user_expiring` | pantry_items | user_id, expiration_date (partial) | Expiring items query |
| `idx_recipe_public_active` | recipes | is_public, deleted_at | Recipe browsing, recommendations |
| `idx_recipe_user_active` | recipes | user_id, deleted_at | "My recipes" query |
| `idx_budget_user_active` | budgets | user_id, deleted_at | Budget queries |
| `idx_notification_user_read` | notifications | user_id, is_read, deleted_at | Notification queries |
| `idx_grocery_list_user` | grocery_lists | user_id, deleted_at | Grocery list queries |
| `idx_meal_plan_user` | meal_plans | user_id, deleted_at | Meal plan queries |
| `idx_refresh_token_hash` | refresh_tokens | token_hash | Authentication |
| `idx_user_interaction_user_date` | user_interactions | user_id, created_at | Recommendation feedback |
| `idx_rec_event_user_date` | recommendation_events | user_id, created_at (partial) | Quota enforcement |

---

## 7. Authentication & Authorization

### 7.1 JWT Token Structure

**Access Token:**
```json
{
  "roles": ["ROLE_USER"],
  "sub": "user@email.com",
  "iat": 1779278739,
  "exp": 1779282339
}
```
- Algorithm: HS512
- TTL: 1 hour (configurable via `JWT_EXPIRATION`)
- Subject: user email

**Refresh Token:**
- Stored as SHA-256 hash in database
- TTL: 7 days (configurable via `JWT_REFRESH_EXPIRATION`)
- Rotated on each use

### 7.2 Role Hierarchy

```
SUPER_ADMIN
    └── ADMIN
        └── CONTENT_MANAGER
        └── SUPPORT_AGENT
        └── ANALYST
    └── PREMIUM_USER
    └── USER (default)
    └── SYSTEM (for automated processes)
```

### 7.3 Endpoint Protection

| Pattern | Required Role |
|---------|---------------|
| `/api/v1/auth/**` | Public |
| `/api/v1/recipes/public/**` | Public |
| `/api/v1/ingredients/**` | Public |
| `/api/v1/pricing/**` | Public |
| `/api/v1/billing/stripe/webhook` | Public (signature verified) |
| `/api/v1/admin/feature-flags/**` | SUPER_ADMIN |
| `/api/v1/admin/**` | ADMIN, SUPER_ADMIN, SUPPORT_AGENT, ANALYST, CONTENT_MANAGER |
| `/api/v1/imports/**` | ADMIN, SUPER_ADMIN, CONTENT_MANAGER, SYSTEM |
| `/api/v1/subscription/upgrade` | ADMIN, SUPER_ADMIN |
| All other endpoints | Any authenticated user |

### 7.4 OAuth2 Flow

**Google/Apple Sign-In:**
1. Mobile app obtains ID token from Google/Apple SDK
2. App sends ID token to `POST /api/v1/auth/oauth2`
3. Backend verifies OIDC signature using JWKs from provider
4. Backend creates/finds user, issues JWT tokens
5. Auto-creates FREE subscription and default profile

---

## 8. Recommendation Engine

### 8.1 Architecture

The recommendation engine is the core differentiator of PlatePilot. It uses a **multi-factor weighted scoring system** that evaluates each recipe against the user's complete profile.

### 8.2 Scoring Factors

| Factor | Weight (default) | Description |
|--------|-----------------|-------------|
| Pantry Match | 0.25 | % of recipe ingredients in user's pantry |
| Budget Fit | 0.20 | How well recipe cost fits weekly budget |
| Preference Match | 0.20 | Alignment with dietary preferences and cuisine |
| Nutrition Goals | 0.15 | Match with health goals (protein, weight loss, etc.) |
| Time Convenience | 0.10 | Shorter prep/cook time = higher score |
| Variety | 0.05 | Cuisine + meal type diversity |
| Location Relevance | 0.05 | Regional cuisine match (country code) |
| User Feedback | ±0.20 | Saved (+0.15), cooked (+0.20), skipped (-0.10), disliked (-0.20) |
| Expiring Pantry Bonus | +0.05 | Uses pantry items expiring soon |

Weights are configurable via `system_settings` table and normalized to sum to 1.0.

### 8.3 Filtering Pipeline

```
1. Fetch N candidate recipes (1 DB query)
2. Filter: enabled + not rejected/disabled
3. Filter: hard allergen exclusion (batch-loaded, 2 DB queries)
4. Filter: hard dietary exclusion (in-memory)
5. Score: multi-factor scoring (0 DB queries — all data pre-loaded)
6. Sort: by final score descending
7. Diversify: limit same cuisine+mealType combinations
8. Return top K results
```

### 8.4 Performance

| Metric | Before Optimization | After Optimization |
|--------|-------------------|-------------------|
| DB queries per request | ~120-320 | ~8 |
| Response time (50 candidates) | 5-15 seconds | <1 second |
| PRD target (<3s) | ❌ Not met | ✅ Exceeded |

**Optimizations applied:**
- Batch recipe cost estimation (1 query vs N)
- Batch pantry scoring (2 queries vs N)
- Batch allergen context loading (2 queries vs N×M)
- Batch expiring pantry matching (1 query vs N)
- Pre-load all scoring data before scoring loop
- Hibernate L2 cache for reference data
- 14 database indexes on hot query paths

### 8.5 Quota Enforcement

- Free users: limited to `free_weekly_recommendation_limit` (default: 20) per 7-day rolling window
- Premium users: unlimited
- Configurable via `system_settings.free_weekly_recommendation_limit`

### 8.6 Allergen Safety

**Hard exclusion rules (never bypassed):**
- Recipe-level flags: containsGluten, containsLactose, containsNuts, containsSoy, containsEggs, containsFish, containsShellfish
- Ingredient-level allergen mapping via `ingredient_allergens` table
- Name-based matching (fuzzy containment check)

**Trust warnings:**
- Unverified recipes: "Recipe has not been professionally verified"
- Low confidence (<0.7): "Nutrition and allergen details are estimates"

---

## 9. Core Business Logic

### 9.1 Grocery List Generation

**Algorithm:**
1. Fetch meal plan entries
2. For each entry, fetch recipe ingredients
3. Aggregate by canonical ingredient ID + unit family
4. Load pantry items matching recipe ingredient IDs
5. Subtract pantry quantities (with unit conversion)
6. Estimate prices using regional pricing
7. Create grocery list with remaining items

**Unit Conversion Rules:**
- Mass family: g ↔ kg (base: g)
- Volume family: ml ↔ l ↔ tsp ↔ tbsp ↔ cup (base: ml)
- Cross-family: blocked (mass ≠ volume)
- Unknown units: treated as discrete units (no conversion)

**Price Confidence:**
- Canonical ingredient resolved: 0.70
- Unresolved: null (warning added to item notes)

### 9.2 Ingredient Resolution

```
User input: "All-purpose flour"
    ↓
Normalize: "all purpose flour"
    ↓
Search ingredient_aliases table
    ↓
Found: "all purpose flour" → ingredient_id = UUID("Flour")
    ↓
Return canonical ingredient for pricing, pantry matching, allergen checks
```

If no alias match, falls back to name-based string matching.

### 9.3 Meal Plan Generation

1. Call `RecommendationEngine.generateWeeklyMealPlan(userId)`
2. Get 50 recommendations
3. Distribute across 7 days × 3 meals (Breakfast, Lunch, Dinner)
4. Create MealPlan with status "ACTIVE"
5. Create MealPlanEntry for each meal

### 9.4 Subscription & Entitlement

**Free Tier:**
- Auto-created on first subscription query
- 20 recommendations per week (configurable)
- Basic features

**Premium Tier:**
- Unlimited recommendations
- Advanced features (future)
- Stripe-managed billing

**Entitlement Flow:**
- `EntitlementService.grantPremium()` → adds ROLE_PREMIUM_USER
- `EntitlementService.revokePremium()` → removes ROLE_PREMIUM_USER
- Checked via `hasActiveEntitlement()` (DB + role fallback)

---

## 10. Performance Optimizations

### 10.1 Database Layer

| Optimization | Impact |
|-------------|--------|
| 14 performance indexes (V109) | 5-50x faster list/filter queries |
| Batch recipe cost estimation | 50-100 queries → 1 |
| Batch pantry scoring | 50-100 queries → 2 |
| Batch allergen context | N×M queries → 2 |
| N+1 fix in MealPlanService | 22 queries → 2 |
| Targeted pantry query in GroceryService | 500-row scan → 10-20 rows |

### 10.2 Caching Layer

| Cache | Type | TTL | Purpose |
|-------|------|-----|---------|
| Redis (`ingredients`) | Spring Cache | 10 min | Ingredient search results |
| Redis (`ingredient`) | Spring Cache | 10 min | Individual ingredient by ID/slug |
| Redis (`ingredients_batch`) | Spring Cache | 10 min | Batch ingredient lookups |
| EhCache L2 (`Ingredient`) | Hibernate L2 | 1 hour | Ingredient entity cache |
| EhCache L2 (`DietaryPreference`) | Hibernate L2 | 2 hours | Diet preference entity cache |
| EhCache L2 (`Allergy`) | Hibernate L2 | 2 hours | Allergy entity cache |
| EhCache L2 (`SystemSetting`) | Hibernate L2 | 30 min | System settings cache |

### 10.3 Connection Pool

| Setting | Value | Rationale |
|---------|-------|-----------|
| maximum-pool-size | 20 | Handles concurrent load |
| minimum-idle | 5 | Keeps warm connections |
| idle-timeout | 300,000ms (5 min) | Closes stale connections |
| max-lifetime | 1,200,000ms (20 min) | Prevents connection drift |
| connection-timeout | 20,000ms (20 sec) | Fail fast on pool exhaustion |

### 10.4 Response Compression

- Enabled for: JSON, XML, HTML, plain text
- Minimum size: 1,024 bytes
- Expected reduction: 60-80% for large responses (grocery lists, meal plans)

### 10.5 Read-Only Transactions

All `get*`, `list*`, `search*` methods use `@Transactional(readOnly = true)`:
- Disables Hibernate dirty checking
- Enables read-replica routing (future)
- Reduces first-level cache overhead

---

## 11. Security Architecture

### 11.1 Authentication

- **Password hashing:** BCrypt, 10 rounds
- **JWT signing:** HS512 with configurable secret
- **Refresh tokens:** SHA-256 hashed before storage
- **OAuth2:** OIDC JWT signature verification via JWKs

### 11.2 Authorization

- **RBAC:** 8 distinct roles with fine-grained endpoint protection
- **Ownership checks:** Every user-scoped operation verifies `entity.userId == requestingUserId`
- **Centralized guard:** `SecurityUtils.verifyOwnership()` helper

### 11.3 Data Protection

- **Soft deletes:** All user-facing entities use `deleted_at` timestamp
- **Auditable entities:** `created_at`, `updated_at`, `created_by`, `updated_by` via `AuditableEntity`
- **PII compliance:** GDPR-ready (data export, deletion support)

### 11.4 API Security

- **CSRF:** Disabled (stateless JWT API)
- **CORS:** Configurable via `CORS_ALLOWED_ORIGINS`
- **Rate limiting:** Documented in PRD (1000 req/min) — implementation pending
- **Input validation:** Jakarta Validation annotations on all DTOs

### 11.5 Email Security

- **Local dev:** Mailpit (no auth, no TLS, port 1025)
- **Production:** Brevo SMTP (auth + STARTTLS, port 587)
- **Verification tokens:** 24-hour TTL, single-use, UUID-based

---

## 12. Infrastructure & Deployment

### 12.1 Docker Compose

```yaml
services:
  postgres:    # PostgreSQL 16 — port 5432
  redis:       # Redis 7 — port 6379
  mailpit:     # Mailpit — SMTP 1025, Web UI 8025
```

### 12.2 Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_USERNAME` | postgres | Database username |
| `DB_PASSWORD` | postgres | Database password |
| `POSTGRES_DB` | PlatePilot | Database name |
| `REDIS_HOST` | localhost | Redis host |
| `REDIS_PORT` | 6379 | Redis port |
| `REDIS_PASSWORD` | (empty) | Redis password |
| `JWT_SECRET` | (default) | JWT signing key (Base64) |
| `JWT_EXPIRATION` | 3600000 | Access token TTL (ms) |
| `JWT_REFRESH_EXPIRATION` | 604800000 | Refresh token TTL (ms) |
| `MAIL_HOST` | smtp-relay.brevo.com | SMTP host |
| `MAIL_PORT` | 587 | SMTP port |
| `MAIL_SMTP_AUTH` | true | SMTP authentication |
| `MAIL_SMTP_STARTTLS` | true | STARTTLS encryption |
| `BREVO_SMTP_USERNAME` | (empty) | Brevo SMTP login |
| `BREVO_SMTP_KEY` | (empty) | Brevo SMTP key |
| `CORS_ALLOWED_ORIGINS` | http://localhost:3000 | Allowed origins |
| `STRIPE_SECRET_KEY` | (empty) | Stripe secret key |
| `STRIPE_WEBHOOK_SECRET` | (empty) | Stripe webhook secret |
| `GOOGLE_OAUTH_CLIENT_IDS` | (empty) | Google OAuth client IDs |
| `APPLE_OAUTH_CLIENT_IDS` | (empty) | Apple OAuth client IDs |
| `USDA_API_KEY` | (empty) | USDA API key |
| `THEMEALDB_API_KEY` | 1 | TheMealDB API key |

### 12.3 Local Development Setup

```bash
# 1. Start infrastructure
docker-compose up -d

# 2. Build and run
mvn clean install
mvn spring-boot:run

# 3. Access
# API: http://localhost:8081
# Swagger: http://localhost:8081/swagger-ui.html
# Mailpit: http://localhost:8025
```

### 12.4 Production Deployment

```bash
# 1. Set environment variables
export JWT_SECRET=<strong-base64-secret>
export DB_PASSWORD=<strong-password>
export STRIPE_SECRET_KEY=<stripe-key>
export BREVO_SMTP_USERNAME=<brevo-login>
export BREVO_SMTP_KEY=<brevo-key>
export MAIL_SMTP_AUTH=true
export MAIL_SMTP_STARTTLS=true

# 2. Build
mvn clean package -DskipTests

# 3. Run
java -jar target/PlatePilot-backend-0.0.1-SNAPSHOT.jar
```

---

## 13. Development Workflow

### 13.1 Build Commands

```bash
# Compile
mvn clean compile

# Run tests
mvn test

# Build JAR
mvn clean package -DskipTests

# Run application
mvn spring-boot:run

# Run with specific profile
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### 13.2 Database Migrations

```bash
# Migrations are auto-applied on startup via Flyway
# Migration files: src/main/resources/db/migration/V*.sql

# To add a new migration:
# 1. Create V{next}__description.sql in db/migration/
# 2. Write SQL (use IF EXISTS/IF NOT EXISTS for safety)
# 3. Restart application — Flyway applies automatically
```

### 13.3 Code Conventions

- **Layering:** domain → application → presentation
- **Naming:** `Entity`, `Repository`, `Service`, `Controller`, `Request`, `Response`
- **Soft deletes:** Use `deleted_at` column, never hard delete user data
- **Ownership:** Always verify `entity.userId == requestingUserId`
- **Transactions:** `@Transactional` on service methods, `readOnly = true` on reads
- **DTOs:** Use records for responses, builder-pattern classes for requests
- **Validation:** Jakarta Validation annotations on request DTOs

---

## 14. Error Handling & Validation

### 14.1 Exception Types

| Exception | HTTP Status | Usage |
|-----------|-------------|-------|
| `ResourceNotFoundException` | 404 | Entity not found |
| `BusinessRuleViolationException` | 400 | Business rule broken |
| `MethodArgumentNotValidException` | 400 | Validation failed |
| `AccessDeniedException` | 403 | Insufficient permissions |
| `Internal Server Error` | 500 | Unexpected error |

### 14.2 Validation Rules

| Field | Rules |
|-------|-------|
| Email | Valid format, unique |
| Password | Min 8 chars, 1 number, 1 uppercase |
| Name | 2-100 chars |
| Budget | Positive number or null |
| Height | 50-300 cm |
| Weight | 20-500 kg |
| Country code | 2 chars (ISO 3166-1 alpha-2) |
| Currency code | Max 4 chars (ISO 4217) |
| Locale | Max 20 chars |
| Cooking skill | Max 20 chars |
| Household size | 1-20 |

### 14.3 Global Error Response

```json
{
  "status": 400,
  "message": "Validation failed",
  "timestamp": "2026-05-20T12:00:00.000Z",
  "errors": {
    "field1": "Error message 1",
    "field2": "Error message 2"
  }
}
```

---

## 15. Testing Strategy

### 15.1 Current Test Coverage

| Module | Tests | Coverage |
|--------|-------|----------|
| Email Verification | 5 | ✅ |
| OAuth2 Login | 3 | ✅ |
| RBAC Security | 3 | ✅ |
| Grocery Aggregation | 2 | ✅ |
| Recommendation Engine | 5 | ✅ |
| Billing Service | 3 | ✅ |
| Stripe Webhook | 2 | ✅ |
| Entitlement | 2 | ✅ |
| Config Binding | 1 | ✅ |
| **Total** | **27** | |

### 15.2 Test Execution

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=RecommendationEngineTest

# Run with coverage (requires JaCoCo plugin)
mvn test jacoco:report
```

### 15.3 Test Database

- Unit tests use H2 in-memory database (no Docker required)
- Integration tests use Testcontainers for PostgreSQL (future)

---

## 16. Frontend Integration Guide

### 16.1 Authentication Flow

```
1. POST /api/v1/auth/register { firstName, lastName, email, password }
   → Returns: { accessToken, refreshToken }

2. Store tokens securely (Keychain/Keystore)

3. Include in every request:
   Authorization: Bearer <accessToken>

4. On 401, refresh token:
   POST /api/v1/auth/refresh { refreshToken }
   → Returns: { accessToken, refreshToken }

5. On logout:
   POST /api/v1/auth/logout { refreshToken }
```

### 16.2 Onboarding Flow

```
1. Register user
2. Create/update profile: PUT /api/v1/profile
3. Add dietary preferences: POST /api/v1/preferences/diets
4. Add allergies: POST /api/v1/preferences/allergies
5. Create budget: POST /api/v1/budgets
6. Add pantry items: POST /api/v1/pantry
7. Generate first meal plan: POST /api/v1/meal-plans/generate
```

### 16.3 Meal Planning Flow

```
1. GET /api/v1/recommendations?limit=10
   → Returns scored recipes with reasons and warnings

2. POST /api/v1/meal-plans/generate
   → Returns auto-generated weekly plan

3. POST /api/v1/grocery-lists/from-plan/{planId}
   → Returns grocery list with pantry subtraction

4. PUT /api/v1/grocery-lists/items/{itemId}/toggle
   → Check off items while shopping
```

### 16.4 Key Response Formats

**Recommendation Result:**
```json
{
  "id": "uuid",
  "name": "Recipe Name",
  "cuisineType": "Italian",
  "mealType": "Dinner",
  "totalTimeMinutes": 30,
  "servings": 4,
  "imageUrl": "https://...",
  "score": 0.85,
  "budgetScore": 0.90,
  "pantryScore": 0.75,
  "timeScore": 0.85,
  "preferenceScore": 0.65,
  "nutritionScore": 0.70,
  "varietyScore": 0.80,
  "locationScore": 1.0,
  "estimatedCost": 12.50,
  "currencyCode": "USD",
  "countryCode": "US",
  "reasons": ["Uses ingredients that match your pantry", "Fits your weekly budget"],
  "warnings": ["Contains gluten"]
}
```

**Grocery List:**
```json
{
  "id": "uuid",
  "name": "Grocery List for Auto-Generated Weekly Plan",
  "status": "ACTIVE",
  "items": [
    {
      "id": "uuid",
      "name": "Flour",
      "category": "Pantry",
      "quantity": 1.250,
      "unit": "kg",
      "estimatedPrice": 2.50,
      "priceConfidence": 0.70,
      "checked": false,
      "notes": "",
      "sortOrder": 0,
      "ingredientId": "uuid"
    }
  ],
  "createdAt": "2026-05-20T12:00:00Z",
  "updatedAt": "2026-05-20T12:00:00Z"
}
```

### 16.5 Error Handling on Frontend

```typescript
interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data: T;
  timestamp: string;
}

interface ApiError {
  status: number;
  message: string;
  timestamp: string;
  errors?: Record<string, string>;
}

// Handle 401 → refresh token
// Handle 403 → redirect to login
// Handle 400 → show field-level errors
// Handle 404 → show not found
// Handle 500 → show generic error
```

### 16.6 Pagination

All list endpoints support:
```
?page=0&size=20
```

Response includes:
```json
{
  "content": [...],
  "page": 0,
  "size": 20,
  "totalElements": 150
}
```

### 16.7 Email Verification

```
1. User registers → email sent (Mailpit in dev, Brevo in prod)
2. User clicks verification link → frontend captures token
3. Frontend calls: GET /api/v1/auth/verify-email?token=<token>
4. On success → redirect to login
5. On error → show error message (expired, invalid, already used)
```

---

## 17. Monitoring & Observability

### 17.1 Actuator Endpoints

| Endpoint | Description |
|----------|-------------|
| `/actuator/health` | Health check (DB, Redis connectivity) |
| `/actuator/info` | Application info |
| `/actuator/metrics` | All metrics |
| `/actuator/prometheus` | Prometheus-formatted metrics |

### 17.2 Key Metrics

- HTTP request latency
- Database connection pool status
- Cache hit/miss rates
- Recommendation generation duration
- Error rates by endpoint

### 17.3 Logging

- Application logs: `com.PlatePilot` at DEBUG level
- Security logs: `org.springframework.security` at DEBUG level
- SQL logs: `org.hibernate.SQL` at DEBUG level (dev only)

---

## 18. Change Log

### v2.0.0 — 20 May 2026

**Performance Optimizations:**
- RecommendationEngine rewritten: ~320 DB queries → ~8 per request
- Batch recipe cost estimation (`BudgetOptimizer.estimateMultipleRecipeCosts`)
- Batch pantry scoring (`PantryUtilizationScorer.calculatePantryScoresForRecipes`)
- Batch allergen context loading
- N+1 query fix in MealPlanService
- Targeted pantry query in GroceryService
- 14 performance indexes (V109 migration)
- Hibernate L2 cache with EhCache
- Response compression enabled
- HikariCP connection pool tuned

**Bug Fixes:**
- Profile GET returns default profile for new users (was 404)
- Subscription GET auto-creates FREE subscription (was 404)
- Currency code column increased to VARCHAR(4) for FCFA support (V110)
- Input validation added to UserProfileRequest

**Infrastructure:**
- Mailpit added to docker-compose for local email testing
- Email config made environment-driven (auth/TLS toggle)
- Ownership guard extracted to `SecurityUtils.verifyOwnership()`

**Endpoint Testing:**
- All 16 authenticated + public endpoints verified working
- 27 unit tests passing

### v1.0.0 — Initial Release

- 14 bounded contexts implemented
- 93 REST API endpoints
- JWT + OAuth2 authentication
- Stripe billing integration
- Multi-factor recommendation engine
- Grocery list generation with pantry subtraction
- Admin dashboard with audit logging
- External data imports (USDA, Open Food Facts, TheMealDB)
