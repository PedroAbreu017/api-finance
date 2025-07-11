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

# Create startup script that captures ALL output including stderr
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'echo "=== STARTING APPLICATION WITH FULL LOGGING ===" ' >> /app/start.sh && \
    echo 'echo "PORT: $PORT"' >> /app/start.sh && \
    echo 'echo "SPRING_PROFILES_ACTIVE: $SPRING_PROFILES_ACTIVE"' >> /app/start.sh && \
    echo 'echo "Starting application..."' >> /app/start.sh && \
    echo 'java -Dspring.profiles.active=prod \' >> /app/start.sh && \
    echo '     -Dserver.port=${PORT:-8080} \' >> /app/start.sh && \
    echo '     -Dlogging.level.root=DEBUG \' >> /app/start.sh && \
    echo '     -Dlogging.level.org.springframework=DEBUG \' >> /app/start.sh && \
    echo '     -XX:+PrintGCDetails \' >> /app/start.sh && \
    echo '     -XX:+UnlockDiagnosticVMOptions \' >> /app/start.sh && \
    echo '     -XX:+LogVMOutput \' >> /app/start.sh && \
    echo '     -jar app.jar 2>&1 | tee app.log &' >> /app/start.sh && \
    echo 'APP_PID=$!' >> /app/start.sh && \
    echo 'echo "Application started with PID: $APP_PID"' >> /app/start.sh && \
    echo 'sleep 30' >> /app/start.sh && \
    echo 'echo "=== APPLICATION LOG CONTENT ===" ' >> /app/start.sh && \
    echo 'tail -50 app.log || echo "No app log found"' >> /app/start.sh && \
    echo 'echo "=== PORT CHECK ===" ' >> /app/start.sh && \
    echo 'netstat -tulpn | grep LISTEN || echo "No listening ports"' >> /app/start.sh && \
    echo 'echo "=== PROCESS STATUS ===" ' >> /app/start.sh && \
    echo 'ps aux | grep java' >> /app/start.sh && \
    echo 'wait $APP_PID' >> /app/start.sh && \
    chmod +x /app/start.sh

CMD ["/app/start.sh"]