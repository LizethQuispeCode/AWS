# ✅ VERIFICACIÓN DEL PROYECTO - Checklist Final

## 📋 Status del Proyecto

### 1️⃣ FRONTEND (Angular + Nginx)

**Archivo clave:** `frontend/src/app/services/backend.service.ts`

- ✅ Endpoint corregido a: `http://10.0.0.10:8080/api/datos`
- ✅ Tabla con usuarios (ID, Nombre, Correo)
- ✅ Dockerfile con build multi-fase (node:18 + nginx:alpine)
- ✅ Nginx configurado para SPA routing
- ✅ Puerto 80 expuesto
- ✅ Styles responsivos

**Local:** `http://localhost`
**AWS:** `http://EC2_PUBLICA_FRONTEND`

---

### 2️⃣ BACKEND (Spring Boot REST API)

**Archivo clave:** `backend/src/main/resources/application-prod.yml`

- ✅ Endpoint: `GET /api/datos`
- ✅ Spring Boot 3.1.5 + Java 17
- ✅ SQL Server Driver (JDBC)
- ✅ Dockerfile multi-stage (maven:3.9 + eclipse-temurin:17)
- ✅ Puerto 8080 expuesto
- ✅ Variables de entorno: `DB_IP`, `DB_USER`, `DB_PASSWORD`
- ✅ CORS habilitado

**Local:** `http://localhost:8080/api/datos`
**AWS:** `http://IP_PRIVADA_BACKEND:8080/api/datos`

---

### 3️⃣ BASE DE DATOS (SQL Server)

**Archivo clave:** `backend/setup-database.sql`

- ✅ Database: `proyecto_db`
- ✅ Tabla: `usuarios` (id, nombre, correo)
- ✅ Usuario: `sa`
- ✅ Puerto 1433 expuesto
- ✅ Compatible con Dockerfile MS SQL

**Local:** `localhost:1433`
**AWS:** `IP_PRIVADA_DB:1433`

---

### 4️⃣ DOCKER

**Archivo clave:** `docker-compose.yml` (raíz)

- ✅ Dockerfile propio para cada servicio
- ✅ docker-compose levanta los 3 servicios
- ✅ Red interna `proyecto-network`
- ✅ Health checks configurados
- ✅ Volumen para persistencia BD

---

## 🚀 CÓMO USAR

### Opción 1: Levantar Todo Localmente (RECOMENDADO)

```bash
cd c:\Users\Thalia\Desktop\frontend

# Levantar todo
docker-compose up -d

# Verificar que esté corriendo
docker ps

# Ver logs
docker-compose logs -f

# Acceder
http://localhost
```

### Opción 2: Componentes Individuales

```bash
# Frontend
cd frontend
docker build -t frontend-app .
docker run -d -p 80:80 frontend-app

# Backend
cd backend
docker build -t backend-app .
docker run -d -p 8080:8080 -e DB_IP=localhost -e DB_PASSWORD=TuPassword123 backend-app

# BD (SQL Server)
docker run -d -p 1433:1433 -e SA_PASSWORD=TuPassword123 -e ACCEPT_EULA=Y mcr.microsoft.com/mssql/server:2022-latest
```

---

## ✅ VALIDACIÓN PASO A PASO

### 1. Verificar que BD está activa

```bash
# Desde la EC2 del Backend
telnet localhost 1433

# O con SQL cmd
sqlcmd -S localhost -U sa -P TuPassword123 -Q "SELECT 1"
```

### 2. Verificar Backend responde

```bash
# Desde cualquier lugar con conectividad
curl http://localhost:8080/api/datos

# Respuesta esperada (JSON):
# [{"id":1,"nombre":"Juan","correo":"juan@example.com"}]
```

### 3. Verificar Frontend muestra datos

```bash
# Abrir navegador
http://localhost

# Debe mostrar tabla con usuarios
```

### 4. Ver contenedores activos

```bash
docker ps

# Debe mostrar:
# - sqlserver-db (1433)
# - backend-app (8080)
# - frontend-app (80)
```

### 5. Ver logs de cada servicio

```bash
docker logs sqlserver-db
docker logs backend-app
docker logs frontend-app
```

---

## 🔧 PARA AWS EC2

### Cambios necesarios SOLO en variables de entorno:

**En Backend (application-prod.yml):**
```
DB_IP: 10.0.X.X  (IP privada de la BD)
```

**En Frontend (backend.service.ts):**
```
http://10.0.X.X:8080/api/datos  (IP privada del backend)
```

**NO cambiar:**
- Lógica del código
- Estructura de carpetas
- Puertos
- Endpoints

---

## 📊 CHECKLIST FINAL

| Componente | Local | AWS | Status |
|-----------|-------|-----|--------|
| **Frontend** | localhost:80 | EC2_IP:80 | ✅ |
| **Backend** | localhost:8080 | IP_PRIVADA:8080 | ✅ |
| **BD** | localhost:1433 | IP_PRIVADA:1433 | ✅ |
| **Docker** | Multi-compose | docker run | ✅ |
| **Conectividad** | localhost | IP privada | ✅ |
| **Tabla Usuarios** | Datos reales | Datos reales | ✅ |

---

## 📁 ESTRUCTURA FINAL

```
.
├── docker-compose.yml              ← Levanta TODO
├── frontend/
│   ├── src/app/services/backend.service.ts  (endpoint corregido)
│   ├── Dockerfile
│   ├── nginx.conf
│   └── ...
├── backend/
│   ├── setup-database.sql
│   ├── Dockerfile
│   ├── pom.xml
│   ├── src/...
│   └── docker-compose.yml
└── .git/
```

---

## 🎯 RESULTADO

✅ **Proyecto 100% funcional**
- Sistema distribuido con 3 capas
- Todo contenerizado
- Listo para AWS (solo cambiar IPs)
- Documentado y validado

**Comando final (local):**
```bash
docker-compose up -d && docker ps && docker logs -f backend-app
```

---

## ⚠️ SI HAY ERRORES

**Backend no conecta a BD:**
```bash
docker logs backend-app
# Ver el error y asegurar que DB_IP sea correcto (por defecto: sqlserver en docker-compose)
```

**Frontend no ve datos:**
```bash
# Abrir DevTools → Console
# Ver si hay error de CORS o conexión
# Verificar que backend.service.ts tenga: http://localhost:8080/api/datos
```

**Puerto ya en uso:**
```bash
docker-compose down
docker ps  # Verificar que no hay contenedores activos
docker-compose up -d
```

---

**¡Todo listo para funcionar! 🚀**
