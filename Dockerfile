# Dockerfile - Versão Simplificada
FROM eclipse-temurin:17-jdk-slim

# Instalar ferramentas básicas para debug
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar JAR da aplicação
COPY target/financeiro-api-simple-1.0.0.jar app.jar

# Verificar se o JAR foi copiado corretamente
RUN ls -la /app/ && \
    file /app/app.jar

# Criar usuário não-root
RUN addgroup --system spring && adduser --system spring --ingroup spring
RUN chown spring:spring /app/app.jar
USER spring:spring

# Expor porta
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Configurações JVM para produção
ENV JAVA_OPTS="-Xmx512m -Xms256m -Djava.security.egd=file:/dev/./urandom"

# Comando de inicialização
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]