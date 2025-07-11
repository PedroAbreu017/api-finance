# Build stage
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml first for better caching
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Debug: Check what was actually created
RUN echo "=== Contents of target directory ===" && \
    ls -la target/ && \
    echo "=== Looking for JAR files ===" && \
    find target/ -name "*.jar" -type f

# Find and copy the JAR with any name
RUN JAR_FILE=$(find target/ -name "*.jar" -not -name "*sources*" -not -name "*javadoc*" | head -1) && \
    echo "Found JAR: $JAR_FILE" && \
    cp "$JAR_FILE" app.jar

# Runtime stage
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copy the JAR file
COPY --from=build /app/app.jar app.jar

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown appuser:appuser /app/app.jar
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]