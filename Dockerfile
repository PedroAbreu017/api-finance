# Build stage
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Install netstat for debugging
USER root
RUN apt-get update && apt-get install -y net-tools curl && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

# Create startup script with debug
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'echo "=== ENVIRONMENT DEBUG ===" ' >> /app/start.sh && \
    echo 'echo "PORT: $PORT"' >> /app/start.sh && \
    echo 'echo "SPRING_PROFILES_ACTIVE: $SPRING_PROFILES_ACTIVE"' >> /app/start.sh && \
    echo 'echo "All ENV vars related to port:"' >> /app/start.sh && \
    echo 'env | grep -i port || echo "No port vars found"' >> /app/start.sh && \
    echo 'echo "Starting application..."' >> /app/start.sh && \
    echo 'java -Dspring.profiles.active=prod -Dserver.port=${PORT:-8080} -Dlogging.level.org.springframework.boot.web.embedded.tomcat=DEBUG -jar app.jar &' >> /app/start.sh && \
    echo 'APP_PID=$!' >> /app/start.sh && \
    echo 'echo "Application started with PID: $APP_PID"' >> /app/start.sh && \
    echo 'sleep 30' >> /app/start.sh && \
    echo 'echo "=== PORT CHECK AFTER 30s ===" ' >> /app/start.sh && \
    echo 'netstat -tulpn | grep LISTEN || echo "No listening ports found"' >> /app/start.sh && \
    echo 'echo "=== PROCESS CHECK ===" ' >> /app/start.sh && \
    echo 'ps aux | grep java || echo "No java process found"' >> /app/start.sh && \
    echo 'wait $APP_PID' >> /app/start.sh && \
    chmod +x /app/start.sh

CMD ["/app/start.sh"]