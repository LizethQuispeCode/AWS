<<<<<<< HEAD
# Frontend - Arquitectura Distribuida AWS

Sistema frontend en Angular para consumir datos del backend en una arquitectura distribuida con Docker en AWS EC2.

## Requisitos

- Docker instalado en la instancia EC2 Ubuntu
- IP privada del backend disponible
- Puerto 80 accesible en el security group

## Estructura del Proyecto

```
frontend/
├── src/
│   ├── app/
│   │   ├── services/
│   │   │   └── backend.service.ts    # Servicio HTTP para consumir backend
│   │   ├── app.component.ts          # Componente principal
│   │   ├── app.component.html        # Template con tabla de usuarios
│   │   ├── app.component.scss        # Estilos
│   │   └── app.config.ts             # Configuración Angular
│   ├── index.html                    # HTML principal
│   ├── main.ts                       # Entry point
│   └── styles.scss                   # Estilos globales
├── Dockerfile                        # Build multi-fase
├── nginx.conf                        # Configuración Nginx
├── package.json                      # Dependencias
├── angular.json                      # Configuración Angular CLI
└── tsconfig.json                     # Configuración TypeScript
```

## Configuración del Backend

El frontend consume datos del backend en:

```
http://IP_PRIVADA_BACKEND:8080/datos
```

### Modificar IP del Backend

Edita `src/app/services/backend.service.ts` y actualiza la URL:

```typescript
private backendUrl = 'http://10.0.0.10:8080/datos'; // Cambiar IP privada
```

### Formato de Datos Esperado

El backend debe retornar un array JSON con usuarios:

```json
[
  {
    "id": 1,
    "nombre": "Juan Pérez",
    "correo": "juan@example.com"
  },
  {
    "id": 2,
    "nombre": "María García",
    "correo": "maria@example.com"
  }
]
```

## Build Local (Opcional)

Para desarrollar localmente:

```bash
# Instalar dependencias
npm install

# Ejecutar servidor de desarrollo
npm start

# Build para producción
npm run build:prod
```

La aplicación estará disponible en `http://localhost:4200`

## Docker - Build y Ejecución

### 1. Build de la imagen

```bash
docker build -t frontend-app .
```

### 2. Ejecutar contenedor

```bash
docker run -d -p 80:80 frontend-app
```

### 3. Verificar contenedor

```bash
docker ps
docker logs <container_id>
```

### 4. Acceder a la aplicación

```
http://localhost:80
```

### 5. Detener contenedor

```bash
docker stop <container_id>
```

## Deployment en AWS EC2

### Paso 1: Conectar a EC2 Ubuntu

```bash
ssh -i "tu-clave.pem" ubuntu@ec2-xxxxx.compute-1.amazonaws.com
```

### Paso 2: Instalar Docker

```bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker ubuntu
```

### Paso 3: Clonar o transferir proyecto

```bash
git clone <repo-url>
cd frontend
```

O transferir con SCP:

```bash
scp -i "tu-clave.pem" -r frontend ubuntu@ec2-xxxxx.compute-1.amazonaws.com:/home/ubuntu/
```

### Paso 4: Build en EC2

```bash
cd frontend
docker build -t frontend-app .
```

### Paso 5: Ejecutar contenedor

```bash
docker run -d -p 80:80 --name frontend-container frontend-app
```

### Paso 6: Verificar

```bash
# Ver logs
docker logs frontend-container

# Ver salud
curl http://localhost:80/health
```

### Paso 7: Acceder desde navegador

```
http://<IP_PUBLICA_EC2>:80
```

## Configuración de Security Group

En AWS Console > Security Groups:

1. **Inbound Rules:**
   - Type: HTTP
   - Protocol: TCP
   - Port: 80
   - Source: 0.0.0.0/0 (o tu IP)

2. **Outbound Rules:**
   - Debe permitir tráfico a la EC2 privada del backend
   - Protocol: TCP
   - Port: 8080
   - Destination: IP privada del backend

## Networking AWS

### Conexión entre EC2s

1. **Frontend EC2:** 10.0.1.0/24 (Subnet pública)
2. **Backend EC2:** 10.0.2.0/24 (Subnet privada)

Ambas en el mismo VPC para comunicación interna.

## Mantenimiento

### Ver contenedor activo

```bash
docker ps
```

### Reiniciar frontend

```bash
docker restart frontend-container
```

### Actualizar código

```bash
git pull
docker build -t frontend-app .
docker stop frontend-container
docker run -d -p 80:80 --name frontend-container frontend-app
```

### Ver logs

```bash
docker logs -f frontend-container
```

## Troubleshooting

### Error: Cannot connect to backend

```
✓ Verificar que backend está corriendo en EC2
✓ Verificar IP privada en backend.service.ts
✓ Verificar security groups permiten comunicación TCP 8080
✓ Ver logs: docker logs frontend-container
```

### Error: Port 80 already in use

```bash
docker ps
docker stop <contenedor_anterior>
docker rm <contenedor_anterior>
docker run -d -p 80:80 --name frontend-container frontend-app
```

### Frontend muestra "Error al conectar"

- Backend no está disponible
- IP privada del backend es incorrecta
- Backend no está en puerto 8080
- Firewall está bloqueando comunicación

## Arquitectura

```
┌─────────────────────────────────────────┐
│         AWS VPC (10.0.0.0/16)          │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────┐  ┌──────────────┐ │
│  │  EC2 Frontend    │  │  EC2 Backend │ │
│  │  (Pública)       │  │ (Privada)    │ │
│  │                  │  │              │ │
│  │ :80 (Nginx)      │  │ :8080        │ │
│  │                  │  │ (Datos JSON) │ │
│  └────────┬─────────┘  └──────┬───────┘ │
│           │                   │         │
│           └───────────────────┘         │
│          IP Privada 10.0.2.x:8080      │
│                                         │
└─────────────────────────────────────────┘
         ↑
         │ HTTP (Port 80)
         │
   Internet / Usuarios
```

## Recursos

- [Angular Docs](https://angular.io/docs)
- [Docker Docs](https://docs.docker.com/)
- [Nginx Docs](https://nginx.org/en/docs/)
- [AWS EC2](https://aws.amazon.com/ec2/)

## Licencia

MIT
