# Backend Spring Boot - Arquitectura Distribuida AWS

API REST distribuida en AWS con Docker, conectada a SQL Server para exponer datos de usuarios.

## Requisitos

- Java 17+
- Maven 3.9+
- Docker
- Docker Compose
- SQL Server accesible desde la red

## Estructura del Proyecto

```
backend/
├── src/
│   ├── main/
│   │   ├── java/com/proyecto/backend/
│   │   │   ├── BackendApplication.java      # Clase principal
│   │   │   ├── controller/
│   │   │   │   └── UsuarioController.java   # Controlador REST
│   │   │   ├── entity/
│   │   │   │   └── Usuario.java             # Entidad JPA
│   │   │   ├── repository/
│   │   │   │   └── UsuarioRepository.java   # Repositorio JPA
│   │   │   └── service/
│   │   │       └── UsuarioService.java      # Lógica de negocio
│   │   └── resources/
│   │       └── application.yml              # Configuración
├── pom.xml                                   # Dependencias Maven
├── Dockerfile                                # Multi-stage build
├── docker-compose.yml                        # Orquestación de contenedores
└── README.md                                 # Este archivo
```

## Endpoints Disponibles

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/datos` | **Obligatorio** - Retorna lista de usuarios |
| GET | `/api/health` | Health check del backend |
| GET | `/api/usuarios` | Obtener todos los usuarios |
| GET | `/api/usuarios/{id}` | Obtener usuario por ID |
| POST | `/api/usuarios` | Crear nuevo usuario |
| PUT | `/api/usuarios/{id}` | Actualizar usuario |
| DELETE | `/api/usuarios/{id}` | Eliminar usuario |

## Configuración en AWS

### 1. Actualizar IP de SQL Server

Antes de construir, actualizar la IP privada de SQL Server en:

**docker-compose.yml:**
```yaml
environment:
  DB_IP: 10.0.0.X  # Cambiar por IP privada real del SQL Server
```

**O usar variables de entorno:**
```bash
docker run -d -p 8080:8080 \
  -e DB_IP=10.0.0.X \
  -e DB_USER=sa \
  -e DB_PASSWORD=TuPassword123 \
  backend-app
```

### 2. Configuración de Seguridad (Security Groups)

La EC2 donde corre el backend debe tener:
- Inbound: Puerto 8080 abierto desde el frontend EC2
- Outbound: Puerto 1433 abierto hacia la EC2 de SQL Server

La EC2 de SQL Server debe tener:
- Inbound: Puerto 1433 abierto desde el backend EC2

### 3. Tabla SQL Server Requerida

```sql
CREATE TABLE usuarios (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(255) NOT NULL,
    correo NVARCHAR(255) NOT NULL UNIQUE
);

-- Datos de ejemplo
INSERT INTO usuarios (nombre, correo) VALUES 
    ('Juan Pérez', 'juan@example.com'),
    ('María García', 'maria@example.com'),
    ('Carlos López', 'carlos@example.com');
```

## Compilar y Ejecutar en Local

### Opción 1: Con Maven
```bash
mvn clean package
java -jar target/backend-app-1.0.0.jar
```

### Opción 2: Con Docker
```bash
docker build -t backend-app .
docker run -d -p 8080:8080 backend-app
```

### Opción 3: Con Docker Compose
```bash
docker-compose up -d
```

## Desplegar en AWS EC2 Ubuntu

### 1. Conectarse a la EC2
```bash
ssh -i tu-key.pem ubuntu@tu-ec2-ip
```

### 2. Instalar Docker
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker ubuntu
```

### 3. Clonar o transferir código
```bash
git clone <tu-repo>
cd backend
```

### 4. Construir imagen Docker
```bash
docker build -t backend-app .
```

### 5. Ejecutar contenedor
```bash
docker run -d \
  --name backend-container \
  -p 8080:8080 \
  -e DB_IP=10.0.0.X \
  -e DB_USER=sa \
  -e DB_PASSWORD=TuPassword123 \
  backend-app
```

### 6. Ver logs
```bash
docker logs -f backend-container
```

## Pruebas

### Health Check
```bash
curl http://localhost:8080/api/health
```

### Obtener datos (Endpoint obligatorio)
```bash
curl http://localhost:8080/api/datos
```

### Crear usuario
```bash
curl -X POST http://localhost:8080/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Test User","correo":"test@example.com"}'
```

## Logs y Debugging

### Ver logs del contenedor
```bash
docker logs backend-container
```

### Ejecutar contenedor en modo interactivo
```bash
docker run -it --rm -p 8080:8080 backend-app
```

## Notas Importantes

- La aplicación usa Hibernate con SQL Server dialect
- `ddl-auto: update` - Hibernate actualizará automáticamente el schema
- CORS está habilitado para todas las fuentes (`*`)
- La conexión a SQL Server usa `encrypt=false` y `trustServerCertificate=true` para desarrollo
- En producción, considerar usar variables de entorno más seguras (AWS Secrets Manager)

## Variables de Entorno

| Variable | Descripción | Por Defecto |
|----------|-------------|------------|
| `DB_IP` | IP privada del SQL Server | localhost |
| `DB_USER` | Usuario SQL Server | sa |
| `DB_PASSWORD` | Contraseña SQL Server | TuPassword123 |
| `SERVER_PORT` | Puerto de escucha | 8080 |

## Arquitectura

```
┌─────────────┐
│  Frontend   │
│   EC2       │
└──────┬──────┘
       │ HTTP:8080
       │
┌──────▼──────────────┐
│   Backend App       │
│   (Docker)          │
│   EC2 t3.medium     │
│   Puerto 8080       │
└──────┬──────────────┘
       │ JDBC:1433
       │
┌──────▼──────────────┐
│   SQL Server        │
│   EC2               │
│   Puerto 1433       │
└─────────────────────┘
```

## Troubleshooting

### Error: Connection refused
- Verificar que SQL Server EC2 está en marcha
- Verificar IP privada en variables de entorno
- Verificar security groups

### Error: Cannot create table
- Verificar permisos en SQL Server
- Ejecutar script SQL de creación de tabla

### Error: Port already in use
```bash
docker rm $(docker ps -aq)
docker run -d -p 8080:8080 backend-app
```

## Licencia

Proyecto Spring Boot para AWS distribuida.
