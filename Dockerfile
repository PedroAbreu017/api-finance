FROM openjdk:11-jre-slim

WORKDIR /app
COPY target/financeiro-api-simple-1.0.0.jar app.jar
EXPOSE 8080
ENV SPRING_PROFILES_ACTIVE=prod
CMD ["java", "-jar", "app.jar"]