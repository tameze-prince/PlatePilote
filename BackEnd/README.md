# PlatePilote Backend

Modular Monolith Spring Boot Backend with Domain-Driven Design (DDD).

## Tech Stack

- **Java 21**
- **Spring Boot 3.2.5**
- **PostgreSQL 16**
- **Redis 7**
- **Flyway** (migrations)
- **JWT** (authentication)
- **MapStruct** (DTO mapping)
- **Lombok** (boilerplate reduction)
- **SpringDoc OpenAPI** (API documentation)

## Architecture

Modular Monolith with 10 bounded contexts:

1. **Auth** - Registration, login, JWT, OAuth2
2. **User Profile** - User profile management
3. **Preferences** - Dietary preferences, allergies, cuisine preferences
4. **Budget** - Budget tracking and management
5. **Pantry** - Pantry inventory management
6. **Recipes** - Recipe CRUD, ratings, favorites
7. **Meal Planning** - Weekly meal plans
8. **Grocery** - Grocery list generation and management
9. **Recommendation** - Rule-based recipe recommendations
10. **Notifications** - Push and email notifications

## Getting Started

### Prerequisites

- Java 21+
- Docker & Docker Compose
- Maven 3.9+

### Run Infrastructure

```bash
docker-compose up -d
```

### Build & Run

```bash
mvn clean install
mvn spring-boot:run
```

### API Documentation

Once running, visit: http://localhost:8080/swagger-ui.html

## Configuration

Key environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_USERNAME` | `postgres` | Database username |
| `DB_PASSWORD` | `postgres` | Database password |
| `REDIS_HOST` | `localhost` | Redis host |
| `JWT_SECRET` | (default) | JWT signing key |
| `JWT_EXPIRATION` | `3600000` | Access token TTL (ms) |

## Testing

```bash
mvn test
```

Tests use Testcontainers for PostgreSQL.
