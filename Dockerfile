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

ENV SPRING_PROFILES_ACTIVE=prod

# FORÇA a usar a porta do Render através de argumentos JVM
ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT:-8080} -jar app.jar"]