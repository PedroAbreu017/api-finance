FROM amazoncorretto:17

WORKDIR /app

# Install curl for health checks
RUN yum update -y && yum install -y curl && yum clean all

# Copy the JAR file
COPY target/financeiro-api-simple-1.0.0.jar app.jar

# Expose port
EXPOSE 8080

# Environment variables
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"
ENV SPRING_PROFILES_ACTIVE=prod

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]