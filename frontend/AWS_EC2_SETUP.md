# Configuración para AWS EC2 - Frontend Angular

## Variables de Entorno en EC2

```bash
# En /home/ubuntu/.bashrc o /home/ubuntu/.profile

export BACKEND_IP="10.0.2.5"          # IP privada del backend
export BACKEND_PORT="8080"            # Puerto del backend
export FRONTEND_PORT="80"             # Puerto del frontend
export DOCKER_IMAGE_NAME="frontend-app"
export DOCKER_CONTAINER_NAME="frontend-container"
```

## Instrucciones de Configuración en EC2

### 1. Preparar Instancia Ubuntu

```bash
# Update sistema
sudo apt-get update
sudo apt-get upgrade -y

# Instalar Docker
sudo apt-get install -y docker.io

# Agregar usuario ubuntu a grupo docker
sudo usermod -aG docker ubuntu

# Salir y volver a entrar para aplicar permisos
logout
ssh -i "key.pem" ubuntu@<EC2_PUBLIC_IP>

# Verificar Docker
docker --version
```

### 2. Transferir Proyecto a EC2

**Opción A: Con Git**
```bash
cd /home/ubuntu
git clone <REPO_URL>
cd frontend
```

**Opción B: Con SCP**
```bash
scp -i "key.pem" -r ./frontend ubuntu@<EC2_PUBLIC_IP>:/home/ubuntu/
ssh -i "key.pem" ubuntu@<EC2_PUBLIC_IP>
cd /home/ubuntu/frontend
```

### 3. Configurar Conexión con Backend

```bash
# Editar con nano/vi
nano src/app/services/backend.service.ts

# Cambiar: private backendUrl = 'http://10.0.0.10:8080/datos';
# Por:     private backendUrl = 'http://<IP_PRIVADA_BACKEND>:8080/datos';

# Guardar: Ctrl+O, Enter, Ctrl+X
```

### 4. Build y Deploy

**Opción A: Con script**
```bash
chmod +x deploy.sh
./deploy.sh <IP_PRIVADA_BACKEND>
```

**Opción B: Manual**
```bash
# Build
docker build -t frontend-app .

# Run
docker run -d -p 80:80 --name frontend-container --restart unless-stopped frontend-app

# Verificar
docker ps
curl http://localhost/health
```

### 5. Configurar Auto-start en EC2

Crear systemd service (`/etc/systemd/system/frontend.service`):

```ini
[Unit]
Description=Frontend Angular Container
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=ubuntu
Restart=always
RestartSec=10
ExecStart=/usr/bin/docker start -a frontend-container
ExecStop=/usr/bin/docker stop frontend-container

[Install]
WantedBy=multi-user.target
```

Habilitar:
```bash
sudo systemctl daemon-reload
sudo systemctl enable frontend
sudo systemctl start frontend
sudo systemctl status frontend
```

## Monitoreo en EC2

### Ver logs en tiempo real
```bash
docker logs -f frontend-container

# Solo últimas 100 líneas
docker logs --tail 100 frontend-container
```

### Estadísticas del contenedor
```bash
docker stats frontend-container
```

### Acceder a contenedor
```bash
docker exec -it frontend-container /bin/sh
```

### Listar puertos
```bash
sudo netstat -tulpn | grep 80
```

## Troubleshooting

### Contenedor no inicia
```bash
docker logs frontend-container
# Ver error específico

# Verificar imagen
docker images | grep frontend

# Verificar puerto disponible
sudo netstat -tulpn | grep :80
```

### No conecta con backend
```bash
# Verificar conectividad
docker exec frontend-container ping -c 4 <IP_PRIVADA_BACKEND>

# Ver configuración actual
docker exec frontend-container cat /usr/share/nginx/html/main.*.js | grep backend
```

### Actualizar imagen

```bash
# Detener
docker stop frontend-container

# Remover
docker rm frontend-container

# Rebuild
docker build -t frontend-app .

# Ejecutar
docker run -d -p 80:80 --name frontend-container frontend-app
```

## Security Group - Configuración Recomendada

**Inbound Rules:**
- HTTP: 80/tcp de 0.0.0.0/0
- SSH: 22/tcp de <tu-IP>/32

**Outbound Rules:**
- All TCP: al backend SG (rango privado)
- All para internet (DNS, etc.)

## Performance - Optimizaciones

### Aumentar Workers de Nginx
En `nginx.conf`:
```
worker_processes auto;  # Ya configurado
```

### Aumentar Límite de Conexiones
```
events {
    worker_connections 2048;  # Cambiar de 1024
}
```

### Aumentar Límite de Descriptores de Archivo
```bash
sudo bash -c 'echo "* soft nofile 65535" >> /etc/security/limits.conf'
sudo bash -c 'echo "* hard nofile 65535" >> /etc/security/limits.conf'
```

## Backup y Recuperación

### Backup de Imagen
```bash
docker save frontend-app -o frontend-app.tar
# Transferir: scp -i key.pem frontend-app.tar ubuntu@<EC2_IP>:~/
```

### Restaurar Imagen
```bash
docker load -i frontend-app.tar
docker run -d -p 80:80 --name frontend-container frontend-app
```

## Actualizaciones

### Actualizar Angular

En `package.json`, cambiar versiones y luego:

```bash
npm install
npm run build:prod
docker build -t frontend-app .
docker stop frontend-container
docker rm frontend-container
docker run -d -p 80:80 --name frontend-container frontend-app
```

## Logs en CloudWatch (Opcional)

Instalar CloudWatch agent y configurar:

```bash
# Instalar
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Configurar para Docker logs
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```
