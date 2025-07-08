Write-Host "=== Limpando processos Java e VS Code que possam estar segurando arquivos... ==="

# Mata processos java
Get-Process java -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "⛔ Matando processo Java PID $($_.Id)..."
    Stop-Process -Id $_.Id -Force
}

# Mata processos code (VS Code)
Get-Process code -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "⛔ Matando processo VS Code PID $($_.Id)..."
    Stop-Process -Id $_.Id -Force
}

Start-Sleep -Seconds 2

$targetPath = ".\target\azure-sql-demo-0.0.1-SNAPSHOT.jar"

Write-Host "Tentando remover arquivo JAR: $targetPath"
try {
    Remove-Item $targetPath -Force -ErrorAction Stop
    Write-Host "✅ JAR removido com sucesso: $targetPath"
} catch {
    Write-Host "❌ Falha ao remover JAR: $($_.Exception.Message)"
}

Write-Host "Tentando remover pasta 'target' recursivamente"
try {
    Remove-Item .\target -Recurse -Force -ErrorAction Stop
    Write-Host "✅ Pasta target removida com sucesso."
} catch {
    Write-Host "❌ Falha ao remover pasta target: $($_.Exception.Message)"
}

Write-Host "`n=== Finalizado ==="
Write-Host "Pressione Enter para fechar..."
Read-Host
