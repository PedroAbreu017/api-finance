FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Install Maven and curl
RUN apk add --no-cache maven curl netcat-openbsd

# Copy source files
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Move JAR to predictable location
RUN mv target/financeiro-api-simple-1.0.0.jar app.jar

# Expose port (Railway will set $PORT)
EXPOSE $PORT

# Environment variables optimized for Railway
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC -Xms256m"
ENV SPRING_PROFILES_ACTIVE=prod

# Create startup script with better error handling
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'echo "=== Railway Startup Debug ==="' >> /app/start.sh && \
    echo 'echo "PORT: $PORT"' >> /app/start.sh && \
    echo 'echo "DATABASE_URL: ${DATABASE_URL:NOT_SET}"' >> /app/start.sh && \
    echo 'echo "SPRING_PROFILES_ACTIVE: $SPRING_PROFILES_ACTIVE"' >> /app/start.sh && \
    echo 'echo "=== Testing Database Connection ==="' >> /app/start.sh && \
    echo 'if [ -n "$DATABASE_URL" ]; then' >> /app/start.sh && \
    echo '  echo "Database URL is configured"' >> /app/start.sh && \
    echo 'else' >> /app/start.sh && \
    echo '  echo "ERROR: DATABASE_URL not set!"' >> /app/start.sh && \
    echo '  exit 1' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo 'echo "=== Starting Application ==="' >> /app/start.sh && \
    echo 'exec java $JAVA_OPTS -Dserver.port=$PORT -jar app.jar' >> /app/start.sh && \
    chmod +x /app/start.sh

# Run the startup script
CMD ["/app/start.sh"]