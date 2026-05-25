# Food Intelligence Pipeline - Architecture Design

## System Overview

The Food Intelligence Pipeline is a distributed, event-driven microservices architecture designed to process global food data at scale.

## Core Principles

1. **Deterministic** - Reproducible, consistent results
2. **Idempotent** - Safe to retry without side effects
3. **Fault-Tolerant** - Graceful degradation, self-healing
4. **Observable** - Full traceability and monitoring
5. **Scalable** - Horizontal scaling capability
6. **Modular** - Loosely coupled services
7. **Event-Driven** - Async processing via message queues

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    External Sources                          │
│  (USDA, Spoonacular, Open Food Facts, Recipes, etc)         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │ Ingestion Service     │
         │ - API Sync            │
         │ - Retry Logic         │
         │ - Rate Limiting       │
         └────────┬──────────────┘
                  │
                  ▼
         ┌───────────────────────┐
         │ Raw Data Storage      │
         │ (PostgreSQL JSONB)    │
         └────────┬──────────────┘
                  │
                  ▼ (Event: RawDataImported)
         ┌───────────────────────┐
         │ Normalization Service │
         │ - Slug Generation     │
         │ - Accent Removal      │
         │ - Canonical Names     │
         └────────┬──────────────┘
                  │
                  ▼ (Event: IngredientNormalized)
         ┌───────────────────────┐
         │ Deduplication Service │
         │ - Fuzzy Matching      │
         │ - Confidence Scoring  │
         │ - Auto-Merge          │
         └────────┬──────────────┘
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
  ┌──────────────┐   ┌──────────────┐
  │Recipe        │   │Ingredient    │
  │Processing    │   │Enrichment    │
  │Service       │   │Service       │
  └──────┬───────┘   └──────┬───────┘
         │                  │
         └─────────┬────────┘
                   ▼
         ┌───────────────────────┐
         │ Nutrition Service     │
         │ - Macro Calculation   │
         │ - Aggregation         │
         └────────┬──────────────┘
                  │
                  ▼ (Event: NutritionCalculated)
         ┌───────────────────────┐
         │ Classification Service│
         │ - Vegan/Vegetarian    │
         │ - Allergen Detection  │
         │ - Dietary Tags        │
         └────────┬──────────────┘
                  │
                  ▼
         ┌───────────────────────┐
         │ Validation Service    │
         │ - Schema Validation   │
         │ - Integrity Checks    │
         │ - Anomaly Detection   │
         └────────┬──────────────┘
                  │
         ┌────────┴─────────┐
         │                  │ (if invalid)
         ▼                  ▼
  ┌─────────────┐  ┌──────────────┐
  │Production   │  │Moderation    │
  │Database     │  │Queue         │
  └─────────────┘  └──────────────┘
```

## Service Catalog

### Tier 1: Data Acquisition
- **Ingestion Service**: Fetches from external APIs and datasets

### Tier 2: Data Foundation  
- **Normalization Service**: Canonicalizes inconsistent data
- **Deduplication Service**: Identifies and resolves duplicates

### Tier 3: Data Intelligence
- **Recipe Processing Service**: Parses and structures recipes
- **Nutrition Service**: Calculates macronutrient information
- **Classification Service**: Applies dietary/allergen tags
- **Enrichment Service**: AI-powered semantic enrichment

### Tier 4: Data Quality
- **Validation Service**: Enforces data integrity rules
- **Moderation Service**: Routes to human review

### Tier 5: Knowledge & Optimization
- **Knowledge Graph Service**: Maintains semantic relationships
- **Pricing Service**: Manages cost intelligence
- **Image Service**: Handles food image processing

### Tier 6: Operations
- **Analytics Service**: Tracks pipeline metrics
- **Monitoring Service**: Health checks and alerts
- **Orchestration Service**: Coordinates workflows

## Message Flow

### Event Types

```java
// Ingestion
RawDataImported
  ├─ source: String
  ├─ entityType: String (INGREDIENT, RECIPE, PRODUCT)
  ├─ payload: JSON
  └─ timestamp: Instant

// Normalization
IngredientNormalized
  ├─ originalName: String
  ├─ canonicalName: String
  ├─ slug: String
  └─ timestamp: Instant

// Deduplication
DuplicateDetected
  ├─ entityType: String
  ├─ primaryId: String
  ├─ duplicateId: String
  ├─ confidenceScore: Double
  └─ timestamp: Instant

// Nutrition
NutritionCalculated
  ├─ calories: Integer
  ├─ protein: Double
  ├─ carbs: Double
  ├─ fat: Double
  └─ timestamp: Instant
```

## Database Schema

### Core Entities

```sql
ingredients
  ├─ id (PK)
  ├─ canonical_name (UNIQUE)
  ├─ slug (UNIQUE, indexed)
  ├─ category
  └─ created_at

recipes
  ├─ id (PK)
  ├─ title
  ├─ slug (UNIQUE, indexed)
  ├─ cuisine
  ├─ category
  └─ created_at

recipe_ingredients
  ├─ id (PK)
  ├─ recipe_id (FK, indexed)
  ├─ ingredient_id (FK)
  ├─ quantity
  └─ unit

nutrition_facts
  ├─ id (PK)
  ├─ ingredient_id (FK, unique)
  ├─ calories_per_100g
  ├─ protein_grams
  ├─ carbs_grams
  └─ fat_grams
```

## Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Import Throughput | 50k records/min | Batch processing |
| Recipe Processing | < 100ms | Single recipe |
| Deduplication | < 50ms | Per comparison |
| Query Latency | < 100ms | P95 |
| Pipeline End-to-End | < 5s | Raw → Production |
| Error Rate | < 1% | Target SLA |
| Availability | 99.9% | Monthly uptime |

## Resilience Patterns

### Retry Strategy
- Exponential backoff: 1s → 2s → 4s → 8s
- Max retries: 3
- Jitter: ±10%

### Circuit Breaker
- Failure threshold: 50% over 10 samples
- Timeout: 30 seconds
- Half-open state: 60 seconds

### Dead Letter Queues
- Auto-route failed messages
- Manual inspection required
- Replay capability

## Deployment Architecture

### Local Development
```bash
docker-compose up  # PostgreSQL, Redis, RabbitMQ, Prometheus, Grafana
mvn clean install
mvn spring-boot:run -pl [service]
```

### Kubernetes (Production)
- One pod per service
- StatefulSets for databases
- Horizontal Pod Autoscaler
- Service mesh (Istio) for resilience

## Monitoring & Observability

### Metrics
- Pipeline throughput (records/s)
- Error rates by service
- Queue depth
- Processing latency (p50, p95, p99)
- Resource utilization

### Logs
- Structured JSON logging
- Trace IDs for end-to-end tracking
- Log levels: DEBUG, INFO, WARN, ERROR

### Dashboards
- Pipeline Overview (overall health)
- Service Health (per-service metrics)
- Data Quality (error rates, duplicates)
- Business Metrics (recipes, ingredients, coverage)

## Security Considerations

- Input validation on all endpoints
- JSONB payload schema validation
- Rate limiting on external APIs
- Network segmentation (services in private network)
- Secrets management (environment variables)
- Audit logging for moderation actions

## Future Extensions

1. **Vector Search**: Semantic recipe recommendations
2. **Multilingual**: Support 10+ languages
3. **Real-time Sync**: Webhooks from retailers
4. **Image Recognition**: AI-powered food identification
5. **Predictive Analytics**: Demand forecasting
