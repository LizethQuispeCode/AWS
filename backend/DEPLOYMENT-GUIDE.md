# Guía de Despliegue en AWS EC2

## Paso 1: Preparar las instancias EC2

### A. EC2 para Backend (t3.medium)
- Tamaño: t3.medium
- OS: Ubuntu Server 22.04 LTS
- Storage: 30GB (gp3)
- Security Group: Permitir
  - Inbound: Puerto 8080 desde 0.0.0.0/0 o restringido al frontend EC2
  - Outbound: Puerto 1433 hacia la EC2 de SQL Server

### B. EC2 para SQL Server (t3.medium)
- Tamaño: t3.medium
- OS: Windows Server 2022 o posterior
- Storage: 50GB (gp3)
- Security Group: Permitir
  - Inbound: Puerto 1433 desde el Backend EC2
  - Outbound: Todo permitido

## Paso 2: Configurar SQL Server en Windows

1. Conectarse por RDP a la EC2 de SQL Server
2. Descargar e instalar SQL Server 2022 Express
3. Ejecutar Management Studio
4. Ejecutar el script SQL (setup-database.sql)

```sql
-- Asegurar que SQL Server escuche en la IP privada
-- En SQL Server Configuration Manager:
-- - SQL Server Network Configuration > Protocols for MSSQLSERVER
-- - Habilitar Named Pipes y TCP/IP
-- - TCP/IP > IP Addresses > IPAll > cambiar puerto a 1433
```

## Paso 3: Obtener IPs Privadas

1. En AWS Console > EC2 > Instances
2. Anotar IP privada del SQL Server (ej: 10.0.0.5)
3. Esta IP se usará en DB_IP del Backend

## Paso 4: Desplegar Backend en Ubuntu

### Opción A: Script automático
```bash
# SSH a la EC2 Backend
ssh -i tu-key.pem ubuntu@tu-backend-ip

# Descargar e ejecutar script
wget https://tu-repo/install-aws.sh
chmod +x install-aws.sh
./install-aws.sh

# Proporcionar:
# - IP privada SQL Server: 10.0.0.X
# - Usuario: sa
# - Password: TuPassword123
```

### Opción B: Manual
```bash
# SSH a la EC2 Backend
ssh -i tu-key.pem ubuntu@tu-backend-ip

# Instalar Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-plugin
sudo usermod -aG docker ubuntu

# Clonar repositorio
git clone https://tu-repo backend
cd backend

# Construir imagen
docker build -t backend-app .

# Ejecutar contenedor
docker run -d \
  --name backend-container \
  -p 8080:8080 \
  -e DB_IP=10.0.0.X \
  -e DB_USER=sa \
  -e DB_PASSWORD=TuPassword123 \
  --restart unless-stopped \
  backend-app
```

## Paso 5: Verificar Conectividad

### Desde Backend EC2
```bash
# Verificar health del backend
curl http://localhost:8080/api/health

# Verificar conexión a SQL Server (si netcat está disponible)
nc -zv 10.0.0.X 1433
```

### Desde tu máquina local
```bash
# Reemplazar con IP pública de Backend EC2
curl http://TU-BACKEND-IP-PUBLICA:8080/api/health
curl http://TU-BACKEND-IP-PUBLICA:8080/api/datos
```

## Paso 6: Configurar Frontend

En el frontend, usar la IP pública de la EC2 Backend:
```javascript
// Ejemplo: React
const API_BASE_URL = 'http://TU-BACKEND-IP-PUBLICA:8080/api';

fetch(`${API_BASE_URL}/datos`)
  .then(res => res.json())
  .then(data => console.log(data));
```

## Monitoreo y Mantenimiento

### Ver logs
```bash
docker logs -f backend-container
```

### Actualizar aplicación
```bash
cd ~/backend-app
git pull
docker build -t backend-app:latest .
docker rm -f backend-container
docker run -d ... backend-app:latest
```

### Reiniciar backend
```bash
docker restart backend-container
```

### Ver uso de recursos
```bash
docker stats backend-container
```

## Troubleshooting

### Error: Cannot connect to SQL Server
1. Verificar que SQL Server está corriendo
2. Verificar IP privada correcta en DB_IP
3. Verificar security group permite puerto 1433
4. En SQL Server, habilitar TCP/IP en Configuration Manager

### Error: Port 8080 already in use
```bash
docker kill $(docker ps -q)
docker run -d -p 8080:8080 backend-app
```

### Error: Application startup failed
```bash
docker logs backend-container
# Revisar errores de conexión a BD
```

## Costos Estimados en AWS

- EC2 t3.medium (Backend): ~$0.0416/hora = ~$30/mes
- EC2 t3.medium (SQL Server): ~$0.0416/hora = ~$30/mes
- Data Transfer: Varía según uso
- Total aproximado: $60-100/mes

## Seguridad (Recomendaciones)

1. Usar AWS Secrets Manager para credenciales
2. Implementar HTTPS (ALB + ACM Certificate)
3. Usar VPC privada para SQL Server
4. Habilitar CloudWatch para monitoreo
5. Configurar auto-scaling si es necesario
6. Usar IAM roles para acceso a AWS resources

## Escala a Producción

- Usar RDS para SQL Server (managed service)
- Implementar Load Balancer (ALB)
- Auto Scaling Group para backend
- CloudFront para caché
- CloudWatch para monitoreo
- CloudFormation o Terraform para IaC
