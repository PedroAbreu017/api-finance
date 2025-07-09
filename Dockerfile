# Use a imagem oficial do OpenJDK mais estável
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Copy the JAR file
COPY target/financeiro-api-simple-1.0.0.jar app.jar

# Expose port
EXPOSE 8080

# Environment variables
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"
ENV SPRING_PROFILES_ACTIVE=prod

# Run the application
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]