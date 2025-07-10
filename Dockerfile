FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Install Maven and debugging tools
RUN apk add --no-cache maven curl netcat-openbsd

# Copy source files
COPY pom.xml .
COPY src ./src

# Build the application
RUN echo "=== Starting Maven Build ===" && \
    mvn clean package -DskipTests -q

# Debug: Show what was built
RUN echo "=== Build Results ===" && \
    ls -la target/ && \
    echo "=== All JAR files ===" && \
    find . -name "*.jar" -type f

# Force copy ANY jar file found to app.jar
RUN echo "=== Moving JAR File ===" && \
    JAR_FILE=$(find target -name "*.jar" -not -name "*sources*" -not -name "*javadoc*" | head -1) && \
    echo "Found JAR: $JAR_FILE" && \
    cp "$JAR_FILE" /app/app.jar && \
    echo "=== JAR moved to /app/app.jar ===" && \
    ls -la /app/app.jar && \
    echo "=== Removing target directory ===" && \
    rm -rf target/

# Final verification
RUN echo "=== Final Check ===" && \
    ls -la /app/ && \
    file /app/app.jar

# Environment variables
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"
ENV SPRING_PROFILES_ACTIVE=prod

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/actuator/health || exit 1

# Absolutely force the JAR path
CMD echo "=== Railway Startup Debug ===" && \
    echo "PORT: $PORT" && \
    echo "DATABASE_URL: ${DATABASE_URL:0:50}..." && \
    echo "JAVA_OPTS: $JAVA_OPTS" && \
    echo "=== JAR File Check ===" && \
    ls -la /app/app.jar && \
    echo "=== Starting Application ===" && \
    cd /app && \
    java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar /app/app.jar