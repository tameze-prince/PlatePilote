# Deployment Guide

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Java 21 JDK
- Maven 3.8+
- Git

## Local Development

### Setup

```bash
# Clone repository
git clone https://github.com/tameze-prince/PlatePilote.git
cd PlatePilote/food-intelligence-pipeline

# Start infrastructure
docker-compose up -d

# Verify services
docker-compose ps
```

### Build

```bash
# Full build
mvn clean install

# Skip tests
mvn clean install -DskipTests

# Build specific service
mvn clean package -pl ingestion-service
```

### Run Individual Services

```bash
# Terminal 1: Ingestion Service
mvn spring-boot:run -pl ingestion-service

# Terminal 2: Normalization Service
mvn spring-boot:run -pl normalization-service

# Terminal 3: Recipe Processing Service
mvn spring-boot:run -pl recipe-processing-service
```

### Health Checks

```bash
# Check all services
for port in 8081 8082 8083 8084 8085; do
  curl http://localhost:$port/actuator/health
done
```

## Docker Build

### Build Individual Service

```bash
docker build \
  --build-arg SERVICE_NAME=ingestion-service \
  --build-arg SERVICE_PORT=8081 \
  -t plateplate/ingestion-service:1.0.0 .
```

### Build All Services

```bash
#!/bin/bash
services=("ingestion-service" "normalization-service" "deduplication-service" "recipe-processing-service" "nutrition-service")
ports=(8081 8082 8083 8084 8085)

for i in "${!services[@]}"; do
  docker build \
    --build-arg SERVICE_NAME=${services[$i]} \
    --build-arg SERVICE_PORT=${ports[$i]} \
    -t plateplate/${services[$i]}:1.0.0 .
done
```

### Push to Registry

```bash
# Login to Docker Hub
docker login

# Push
docker push plateplate/ingestion-service:1.0.0
```

## Kubernetes Deployment

### Create Namespace

```bash
kubectl create namespace plateplate
```

### Deploy PostgreSQL

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: plateplate
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: plateplate
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: plateplate
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 100Gi
```

### Deploy Service

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingestion-service
  namespace: plateplate
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ingestion-service
  template:
    metadata:
      labels:
        app: ingestion-service
    spec:
      containers:
      - name: ingestion-service
        image: plateplate/ingestion-service:1.0.0
        ports:
        - containerPort: 8081
        env:
        - name: SPRING_DATASOURCE_URL
          value: jdbc:postgresql://postgres:5432/plateplate
        - name: SPRING_DATASOURCE_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: SPRING_DATASOURCE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        - name: SPRING_RABBITMQ_HOST
          value: rabbitmq
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8081
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8081
          initialDelaySeconds: 20
          periodSeconds: 5
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

### Service & Ingress

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ingestion-service
  namespace: plateplate
spec:
  selector:
    app: ingestion-service
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8081
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: plateplate
spec:
  ingressClassName: nginx
  rules:
  - host: api.plateplate.com
    http:
      paths:
      - path: /ingestion
        pathType: Prefix
        backend:
          service:
            name: ingestion-service
            port:
              number: 80
```

## Monitoring

### Prometheus Scrape Targets

ServiceMonitor in Kubernetes:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: plateplate-services
  namespace: plateplate
spec:
  selector:
    matchLabels:
      app: ingestion-service
  endpoints:
  - port: metrics
    interval: 30s
    path: /actuator/prometheus
```

## Troubleshooting

### Service won't start

```bash
# Check logs
docker logs plateplate-postgres
java -jar ingestion-service-1.0.0.jar

# Verify database connection
psql -h localhost -U postgres -d plateplate

# Check RabbitMQ
curl http://localhost:15672/api/overview
```

### Performance degradation

```bash
# Check queue depth
curl -u guest:guest http://localhost:15672/api/queues

# Monitor PostgreSQL
psql -c "SELECT datname, numbackends FROM pg_stat_database;"

# View Prometheus metrics
curl http://localhost:9090/api/v1/query?query=up
```

## Scaling

### Horizontal Scaling

```bash
# Kubernetes
kubectl scale deployment ingestion-service --replicas=5 -n plateplate

# Docker Compose (requires custom orchestration)
```

### Database Optimization

```sql
-- Add missing indexes
CREATE INDEX idx_recipes_cuisine ON recipes(cuisine);
CREATE INDEX idx_recipe_nutrition_servings ON recipe_nutrition(servings);

-- Analyze
ANALYZE;

-- Vacuum
VACUUM ANALYZE;
```
