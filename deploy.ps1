# Script de Deployment - Frontend Angular en AWS EC2
# Uso: .\deploy.ps1 -BackendIP "10.0.2.5"

param(
    [Parameter(Mandatory=$true)]
    [string]$BackendIP
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Green
Write-Host "Frontend Angular - Deploy Script (Windows)" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

$BACKEND_URL = "http://${BackendIP}:8080/datos"

Write-Host ""
Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "- Backend URL: $BACKEND_URL" -ForegroundColor White
Write-Host ""

# Actualizar archivo de servicio
Write-Host "[1/5] Actualizando configuración del backend..." -ForegroundColor Cyan
$serviceFile = "src/app/services/backend.service.ts"
$content = Get-Content $serviceFile
$content = $content -replace "private backendUrl = '.*'", "private backendUrl = '$BACKEND_URL'"
Set-Content -Path $serviceFile -Value $content
Write-Host "✓ Backend URL actualizada" -ForegroundColor Green

# Build
Write-Host ""
Write-Host "[2/5] Construyendo imagen Docker..." -ForegroundColor Cyan
docker build -t frontend-app .
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Error en build de Docker" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Imagen Docker construida" -ForegroundColor Green

# Detener contenedor anterior
Write-Host ""
Write-Host "[3/5] Limpiando contenedor anterior..." -ForegroundColor Cyan
$existingContainer = docker ps -a --filter "name=frontend-container" --quiet
if ($existingContainer) {
    Write-Host "  Deteniendo contenedor anterior..." -ForegroundColor Gray
    docker stop frontend-container | Out-Null
    docker rm frontend-container | Out-Null
    Write-Host "✓ Contenedor anterior removido" -ForegroundColor Green
} else {
    Write-Host "✓ No hay contenedor anterior" -ForegroundColor Green
}

# Ejecutar nuevo contenedor
Write-Host ""
Write-Host "[4/5] Iniciando nuevo contenedor..." -ForegroundColor Cyan
docker run -d `
    -p 80:80 `
    --name frontend-container `
    --restart unless-stopped `
    frontend-app

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Error al iniciar contenedor" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Contenedor iniciado" -ForegroundColor Green

# Verificar
Write-Host ""
Write-Host "[5/5] Verificando..." -ForegroundColor Cyan
Start-Sleep -Seconds 2

$runningContainer = docker ps --filter "name=frontend-container" --quiet
if ($runningContainer) {
    Write-Host "✓ Contenedor ejecutándose" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "✓ DEPLOYMENT COMPLETADO" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Frontend disponible en:" -ForegroundColor Yellow
    Write-Host "- http://localhost:80" -ForegroundColor White
    Write-Host "- http://<IP_PUBLICA_EC2>:80" -ForegroundColor White
    Write-Host ""
    Write-Host "Backend configurado en:" -ForegroundColor Yellow
    Write-Host "- $BACKEND_URL" -ForegroundColor White
    Write-Host ""
    Write-Host "Comandos útiles:" -ForegroundColor Yellow
    Write-Host "Ver logs: docker logs -f frontend-container" -ForegroundColor Gray
    Write-Host "Detener: docker stop frontend-container" -ForegroundColor Gray
} else {
    Write-Host "✗ Error: Contenedor no está ejecutándose" -ForegroundColor Red
    docker logs frontend-container
    exit 1
}
