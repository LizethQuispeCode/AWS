#!/bin/bash

# Script de pruebas para los endpoints del backend
# Ejecutar: bash test-endpoints.sh

API_URL="http://localhost:8080/api"

echo "========================================"
echo "Pruebas de Endpoints - Backend"
echo "========================================"
echo ""

# Color para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. Health Check
echo -e "${BLUE}1. Health Check${NC}"
curl -s "$API_URL/health"
echo -e "\n"

# 2. Obtener todos los datos (Endpoint obligatorio)
echo -e "${BLUE}2. GET /api/datos (Obligatorio)${NC}"
curl -s "$API_URL/datos" | jq '.'
echo -e "\n"

# 3. Obtener todos los usuarios
echo -e "${BLUE}3. GET /api/usuarios${NC}"
curl -s "$API_URL/usuarios" | jq '.'
echo -e "\n"

# 4. Crear nuevo usuario
echo -e "${BLUE}4. POST /api/usuarios (Crear nuevo)${NC}"
NEW_USER=$(curl -s -X POST "$API_URL/usuarios" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Usuario Prueba",
    "correo": "prueba@example.com"
  }' | jq '.')
echo "$NEW_USER"
USER_ID=$(echo "$NEW_USER" | jq '.id')
echo -e "\n"

# 5. Obtener usuario específico
echo -e "${BLUE}5. GET /api/usuarios/{id}${NC}"
curl -s "$API_URL/usuarios/$USER_ID" | jq '.'
echo -e "\n"

# 6. Actualizar usuario
echo -e "${BLUE}6. PUT /api/usuarios/{id} (Actualizar)${NC}"
curl -s -X PUT "$API_URL/usuarios/$USER_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Usuario Actualizado",
    "correo": "actualizado@example.com"
  }' | jq '.'
echo -e "\n"

# 7. Eliminar usuario
echo -e "${BLUE}7. DELETE /api/usuarios/{id}${NC}"
curl -s -X DELETE "$API_URL/usuarios/$USER_ID" -v
echo -e "\n"

echo -e "${GREEN}========================================"
echo "Pruebas completadas"
echo "========================================${NC}"
