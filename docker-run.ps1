# Script de Build e Execu��o - Docker

Write-Host "=== BUILD E EXECU��O DOCKER ===" -ForegroundColor Green
Write-Host ""

# 1. Build da aplica��o
Write-Host "1. Build da aplica��o Java..." -ForegroundColor Yellow
mvn clean package -DskipTests

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ? Build Java conclu�do!" -ForegroundColor Green
} else {
    Write-Host "   ? Erro no build Java!" -ForegroundColor Red
    exit 1
}

# 2. Build dos containers
Write-Host "2. Build dos containers Docker..." -ForegroundColor Yellow
docker-compose build --no-cache

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ? Build Docker conclu�do!" -ForegroundColor Green
} else {
    Write-Host "   ? Erro no build Docker!" -ForegroundColor Red
    exit 1
}

# 3. Iniciar ambiente
Write-Host "3. Iniciando ambiente completo..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ? Ambiente iniciado!" -ForegroundColor Green
} else {
    Write-Host "   ? Erro ao iniciar ambiente!" -ForegroundColor Red
    exit 1
}

# 4. Aguardar inicializa��o
Write-Host "4. Aguardando servi�os ficarem prontos..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# 5. Verificar status
Write-Host "5. Verificando status dos servi�os..." -ForegroundColor Yellow
docker-compose ps

Write-Host ""
Write-Host "=== SERVI�OS DISPON�VEIS ===" -ForegroundColor Green
Write-Host "?? Aplica��o: http://localhost:8080" -ForegroundColor Cyan
Write-Host "?? Swagger: http://localhost:8080/swagger-ui/index.html" -ForegroundColor Cyan
Write-Host "?? Health: http://localhost:8080/actuator/health" -ForegroundColor Cyan
Write-Host "???  SQL Server: localhost:1433" -ForegroundColor Cyan
Write-Host "?? Redis: localhost:6379" -ForegroundColor Cyan

Write-Host ""
Write-Host "?? TESTE R�PIDO:"
Write-Host "curl http://localhost:8080/actuator/health"
