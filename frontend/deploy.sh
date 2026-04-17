#!/bin/bash

# Script de Deployment - Frontend Angular en AWS EC2
# Uso: ./deploy.sh <IP_PRIVADA_BACKEND>

set -e

echo "=========================================="
echo "Frontend Angular - Deploy Script"
echo "=========================================="

# Validar argumento
if [ -z "$1" ]; then
    echo "Error: Debe proporcionar la IP privada del backend"
    echo "Uso: ./deploy.sh 10.0.2.5"
    exit 1
fi

BACKEND_IP=$1
BACKEND_URL="http://${BACKEND_IP}:8080/datos"

echo ""
echo "Configuración:"
echo "- Backend URL: $BACKEND_URL"
echo ""

# Actualizar archivo de servicio con la IP correcta
echo "[1/5] Actualizando configuración del backend..."
sed -i "s|private backendUrl = '.*'|private backendUrl = '${BACKEND_URL}'|g" src/app/services/backend.service.ts
echo "✓ Backend URL actualizada"

# Build
echo ""
echo "[2/5] Construyendo imagen Docker..."
docker build -t frontend-app .
echo "✓ Imagen Docker construida"

# Detener contenedor anterior si existe
echo ""
echo "[3/5] Limpiando contenedor anterior..."
if docker ps -a | grep -q frontend-container; then
    echo "  Deteniendo contenedor anterior..."
    docker stop frontend-container || true
    docker rm frontend-container || true
    echo "✓ Contenedor anterior removido"
else
    echo "✓ No hay contenedor anterior"
fi

# Ejecutar nuevo contenedor
echo ""
echo "[4/5] Iniciando nuevo contenedor..."
docker run -d \
    -p 80:80 \
    --name frontend-container \
    --restart unless-stopped \
    frontend-app
echo "✓ Contenedor iniciado"

# Verificar
echo ""
echo "[5/5] Verificando..."
sleep 2

if docker ps | grep -q frontend-container; then
    echo "✓ Contenedor ejecutándose"
    
    echo ""
    echo "=========================================="
    echo "✓ DEPLOYMENT COMPLETADO"
    echo "=========================================="
    echo ""
    echo "Frontend está disponible en:"
    echo "- http://localhost:80"
    echo "- http://<IP_PUBLICA_EC2>:80"
    echo ""
    echo "Backend configurado en:"
    echo "- $BACKEND_URL"
    echo ""
    echo "Ver logs: docker logs -f frontend-container"
    echo "Detener: docker stop frontend-container"
else
    echo "✗ Error: Contenedor no está ejecutándose"
    docker logs frontend-container
    exit 1
fi
