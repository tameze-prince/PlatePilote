# ---- Builder Stage ----
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Copy Maven wrapper and pom.xml for dependency caching
COPY pom.xml ./
COPY .mvn .mvn/
COPY mvnw ./

# Download dependencies (cached if pom.xml unchanged)
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Copy source and build
COPY src ./src
COPY pom.xml ./

# Build the JAR (Spring Boot repackages to platepilote-backend-0.0.1-SNAPSHOT.jar)
RUN ./mvnw clean package -DskipTests -q

# ---- Runtime Stage ----
FROM eclipse-temurin:21-jre-alpine AS runtime

# Security: run as non-root user
RUN addgroup -S spring && adduser -S spring -G spring

WORKDIR /app

# Create non-root user directories
RUN mkdir -p /app && chown -R spring:spring /app

# Copy the fat JAR from builder
COPY --from=builder /app/target/*.jar app.jar

# Switch to non-root user
USER spring:spring

# Expose port
EXPOSE 8080

# Health check using Spring Actuator
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget -q --spider http://localhost:8080/actuator/health || exit 1

# JVM tuning for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]