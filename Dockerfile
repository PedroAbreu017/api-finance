# Dockerfile - Production Ready Multi-stage
# Build stage
FROM eclipse-temurin:17-jdk-slim AS builder

WORKDIR /app
COPY . .

# Build the application (if source is available)
RUN if [ -f "pom.xml" ]; then \
      apt-get update && apt-get install -y maven && \
      mvn clean package -DskipTests && \
      mv target/financeiro-api-simple-1.0.0.jar app.jar; \
    else \
      echo "Using pre-built JAR"; \
    fi

# Runtime stage
FROM eclipse-temurin:17-jre-slim

# Install essential tools
RUN apt-get update && \
    apt-get install -y \
      curl \
      dumb-init && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Create application directory
WORKDIR /app

# Create non-root user
RUN groupadd --system --gid 1001 spring && \
    useradd --system --uid 1001 --gid spring --shell /bin/bash --create-home spring

# Copy JAR from builder or local
COPY --chown=spring:spring \
    target/financeiro-api-simple-1.0.0.jar app.jar

# Alternatively, copy from builder stage if built
# COPY --from=builder --chown=spring:spring /app/app.jar app.jar

# Verify JAR
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
                -Dspring.profiles.active=docker"

# Use dumb-init as PID 1
ENTRYPOINT ["dumb-init", "--"]
CMD ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]