FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Install Maven and debugging tools
RUN apk add --no-cache maven curl netcat-openbsd

# Copy source files
COPY pom.xml .
COPY src ./src

# Build the application with verbose output
RUN echo "=== Starting Maven Build ===" && \
    mvn clean package -DskipTests -q && \
    echo "=== Build completed ==="

# Check if JAR was created and move it
RUN echo "=== Checking for JAR file ===" && \
    ls -la target/ && \
    if [ -f "target/financeiro-api-simple-1.0.0.jar" ]; then \
        cp target/financeiro-api-simple-1.0.0.jar app.jar && \
        echo "JAR copied successfully"; \
    else \
        echo "ERROR: JAR not found, looking for any JAR files..." && \
        find target -name "*.jar" -type f && \
        JAR_FILE=$(find target -name "*.jar" -not -name "*sources*" -not -name "*javadoc*" | head -1) && \
        if [ -f "$JAR_FILE" ]; then \
            cp "$JAR_FILE" app.jar && \
            echo "Alternative JAR copied: $JAR_FILE"; \
        else \
            echo "FATAL: No JAR file found!" && \
            exit 1; \
        fi; \
    fi

# Verify the JAR file exists
RUN ls -la app.jar

# Environment variables
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"
ENV SPRING_PROFILES_ACTIVE=prod

# Simple and direct startup command
CMD echo "=== Railway Startup ===" && \
    echo "PORT: $PORT" && \
    echo "DATABASE_URL: ${DATABASE_URL:0:50}..." && \
    echo "Starting application..." && \
    java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar app.jar