#!/bin/bash

# Script de instalación y despliegue en AWS EC2

set -e  # Exit si hay error

echo "====================================="
echo "Instalador Backend Spring Boot - AWS"
echo "====================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir con color
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si está en Ubuntu
if ! grep -qi "ubuntu" /etc/os-release; then
    log_error "Este script solo funciona en Ubuntu"
    exit 1
fi

log_info "Actualizando sistema..."
sudo apt-get update
sudo apt-get upgrade -y

log_info "Instalando Docker..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

log_info "Agregando usuario al grupo docker..."
sudo usermod -aG docker $USER

log_info "Verificando Docker..."
docker --version

log_info "Instalando Git..."
sudo apt-get install -y git

log_info "Instalando tmux (para sesiones persistentes)..."
sudo apt-get install -y tmux

# Pedir datos de entrada
echo ""
log_warn "Por favor, proporciona los siguientes datos:"
read -p "IP privada de SQL Server (ej: 10.0.0.5): " DB_IP
read -p "Usuario SQL Server [sa]: " DB_USER
DB_USER=${DB_USER:-sa}
read -sp "Contraseña SQL Server: " DB_PASSWORD
echo ""

# Crear directorio de la aplicación
log_info "Creando directorio de aplicación..."
APP_DIR="/home/ubuntu/backend-app"
if [ ! -d "$APP_DIR" ]; then
    mkdir -p $APP_DIR
    log_info "Directorio creado: $APP_DIR"
else
    log_warn "El directorio ya existe"
fi

# Copiar código (si está disponible localmente)
if [ -f "./pom.xml" ]; then
    log_info "Copiando archivos del proyecto..."
    cp -r . $APP_DIR/
else
    log_warn "No se encontraron archivos locales. Por favor, clona el repo o copia los archivos manualmente."
fi

# Navegar al directorio
cd $APP_DIR

# Actualizar docker-compose.yml con los datos
log_info "Actualizando configuración..."
if [ -f "docker-compose.yml" ]; then
    # Crear archivo .env para variables de entorno
    cat > .env <<EOF
DB_IP=$DB_IP
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
EOF
    log_info "Archivo .env creado"
fi

# Construir imagen
log_info "Construyendo imagen Docker..."
docker build -t backend-app:latest .

# Crear y ejecutar contenedor
log_info "Iniciando contenedor..."
docker run -d \
    --name backend-container \
    -p 8080:8080 \
    -e DB_IP=$DB_IP \
    -e DB_USER=$DB_USER \
    -e DB_PASSWORD=$DB_PASSWORD \
    --restart unless-stopped \
    backend-app:latest

log_info "Esperando a que la aplicación inicie..."
sleep 10

# Verificar health
log_info "Verificando estado de la aplicación..."
if curl -s http://localhost:8080/api/health; then
    log_info "✓ Backend está corriendo correctamente"
else
    log_error "✗ No se pudo conectar al backend"
    log_info "Revisa los logs: docker logs backend-container"
fi

echo ""
log_info "====================================="
log_info "Instalación completada!"
log_info "====================================="
echo ""
log_info "Información útil:"
echo "  Health Check:    curl http://localhost:8080/api/health"
echo "  Obtener datos:   curl http://localhost:8080/api/datos"
echo "  Ver logs:        docker logs -f backend-container"
echo "  Parar backend:   docker stop backend-container"
echo "  Iniciar backend: docker start backend-container"
echo ""
log_warn "Nota: La aplicación está escuchando en el puerto 8080"
log_warn "Asegúrate de que el security group permite tráfico en el puerto 8080"
echo ""
