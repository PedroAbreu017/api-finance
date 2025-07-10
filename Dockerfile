FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Install Maven
RUN apk add --no-cache maven

# Copy source files
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Check what JAR was created and move it
RUN echo "=== Checking JAR files ===" && \
    ls -la target/ && \
    mv target/azure-sql-demo.jar app.jar && \
    echo "JAR moved successfully: $(ls -lh app.jar)"

# Clean up to reduce image size
RUN rm -rf target/ ~/.m2/repository src pom.xml && \
    echo "=== Final Check ===" && \
    ls -la /app/ && \
    echo "JAR ready to run!"

# Expose port
EXPOSE $PORT

# Environment variables
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"
ENV SPRING_PROFILES_ACTIVE=prod

# Run the application
CMD java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar /app/app.jar