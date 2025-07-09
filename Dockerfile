# Build stage
FROM eclipse-temurin:17-jdk-slim AS builder

WORKDIR /app
COPY . .

# Build the application if source is available
RUN if [ -f "pom.xml" ]; then \
      apt-get update && apt-get install -y maven && \
      mvn clean package -DskipTests && \
      mv target/financeiro-api-simple-1.0.0.jar app.jar; \
    else \
      echo "Using pre-built JAR"; \
    fi

# Runtime stage - CORRIGIDO: usando amazoncorretto que é mais estável
FROM amazoncorretto:17-alpine

# Install essential tools
RUN apk add --no-cache curl dumb-init

# Create application directory
WORKDIR /app

# Create non-root user (Alpine style)
RUN addgroup -g 1001 -S spring && \
    adduser -u 1001 -S spring -G spring

# Copy JAR from builder or local
COPY --chown=spring:spring \
    target/financeiro-api-simple-1.0.0.jar app.jar

# Verify JAR exists
RUN ls -la /app/ && \
    file /app/app.jar && \
    chown spring:spring /app/app.jar

# Switch to non-root user
USER spring:spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# JVM optimization for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport \
                -XX:MaxRAMPercentage=75.0 \
                -XX:+UseG1GC \
                -XX:+UseStringDeduplication \
                -Djava.security.egd=file:/dev/./urandom \
                -Dspring.profiles.active=prod"

# Use dumb-init as PID 1
ENTRYPOINT ["dumb-init", "--"]
CMD ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]