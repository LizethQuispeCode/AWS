# Estructura del Proyecto - Frontend Angular

```
frontend/
│
├── 📁 src/                              # Código fuente principal
│   ├── 📁 app/
│   │   ├── 📁 services/
│   │   │   └── backend.service.ts      # ✓ Servicio HTTP para consumir backend
│   │   │       └── Interface: Usuario (id, nombre, correo)
│   │   │       └── Método: obtenerUsuarios()
│   │   │
│   │   ├── app.component.ts            # ✓ Componente principal
│   │   │   └── Gestiona estado de datos
│   │   │   └── Maneja carga de usuarios
│   │   │   └── Maneja errores
│   │   │
│   │   ├── app.component.html          # ✓ Template con tabla
│   │   │   └── Tabla de usuarios (ID, Nombre, Correo)
│   │   │   └── Indicador de carga
│   │   │   └── Mensajes de error
│   │   │
│   │   ├── app.component.scss          # ✓ Estilos responsive
│   │   │   └── Gradiente azul/púrpura
│   │   │   └── Tabla con estilos modernos
│   │   │   └── Responsive design
│   │   │
│   │   ├── app.config.ts               # ✓ Configuración de providers
│   │   │   └── HttpClient provider
│   │   │   └── Router provider
│   │   │
│   │   └── index.ts
│   │
│   ├── index.html                      # ✓ HTML principal
│   │   └── Meta tags
│   │   └── Root component <app-root>
│   │
│   ├── main.ts                         # ✓ Entry point de Angular
│   │   └── Bootstrap de aplicación
│   │
│   └── styles.scss                     # ✓ Estilos globales
│       └── Reset CSS
│       └── Fuentes globales
│
├── 📁 dist/                            # Build output (generado)
│   └── frontend-app/                   # Archivos compilados
│
├── 🐳 Dockerfile                       # ✓ Build multi-fase
│   ├── FASE 1: node:18 (Build Angular)
│   └── FASE 2: nginx:alpine (Servir app)
│
├── 📄 nginx.conf                       # ✓ Configuración Nginx
│   ├── SPA routing (try_files)
│   ├── Cache estático
│   ├── Gzip compression
│   └── Health check endpoint
│
├── 📋 package.json                     # ✓ Dependencias npm
│   ├── @angular/core: 17.0.0
│   ├── @angular/common: 17.0.0
│   ├── rxjs: 7.8.0
│   └── scripts: build, start, etc.
│
├── ⚙️ angular.json                     # ✓ Configuración Angular CLI
│   └── Build configuration
│
├── 🔧 tsconfig.json                    # ✓ Configuración TypeScript
│   ├── Target: ES2022
│   ├── Module: ES2022
│   └── Strict mode habilitado
│
├── 📝 tsconfig.app.json                # ✓ Config específica app
│
├── 📚 README.md                        # ✓ Documentación principal
│   ├── Estructura
│   ├── Setup local
│   ├── Docker deployment
│   ├── AWS EC2 deployment
│   └── Troubleshooting
│
├── 🚀 AWS_EC2_SETUP.md                 # ✓ Guía completa AWS
│   ├── Setup instancia Ubuntu
│   ├── Instalar Docker
│   ├── Deploy automatizado
│   ├── Monitoreo
│   ├── Security groups
│   └── Performance tuning
│
├── 🔌 API_SPEC.md                      # ✓ Especificación API
│   ├── Endpoint esperado
│   ├── Formato JSON
│   ├── Error handling
│   └── Testing
│
├── 🧠 STRUCTURE.md                     # Este archivo
│   └── Visión general del proyecto
│
├── 📜 deploy.sh                        # ✓ Script Linux/Mac
│   ├── Automático
│   ├── Build + Deploy
│   └── Verificación
│
├── 🪟 deploy.ps1                       # ✓ Script Windows
│   ├── Automático
│   ├── Build + Deploy
│   └── Verificación
│
├── 🐳 docker-compose.yml               # ✓ Docker Compose (opcional)
│   └── Fácil desarrollo local
│
├── 📄 .env.example                     # ✓ Variables de ambiente
│   └── Plantilla de configuración
│
├── 🚫 .gitignore                       # ✓ Git ignore patterns
│   └── node_modules, dist, etc.
│
├── 🐳 .dockerignore                    # ✓ Docker ignore patterns
│   └── Optimizar tamaño imagen
│
├── 📌 .nvmrc                           # ✓ Versión Node recomendada
│   └── Node 18
│
└── 📄 .editorconfig                    # Configuración editor (opcional)
```

## Flujo de Datos

```
┌─────────────────────────────────────────────┐
│        Usuario en Navegador                │
│     http://<IP_EC2>:80                     │
└────────────┬────────────────────────────────┘
             │
             ▼
     ┌──────────────────┐
     │   index.html     │
     │  (carga Angular) │
     └────────┬─────────┘
              │
              ▼
     ┌──────────────────┐
     │  app.component   │
     │   (Angular)      │
     │   ngOnInit()     │
     └────────┬─────────┘
              │
              ▼
    ┌──────────────────────┐
    │ backend.service.ts   │
    │obtenerUsuarios()     │
    │  HttpClient GET      │
    └────────┬─────────────┘
             │
             │ HTTP GET
             │
             ▼
┌────────────────────────────────────────┐
│    EC2 Backend (IP Privada)           │
│  http://10.0.2.5:8080/datos           │
│  Retorna: [                           │
│    {id, nombre, correo},              │
│    {id, nombre, correo}               │
│  ]                                    │
└────────────┬────────────────────────────┘
             │
             ▼
    ┌──────────────────────┐
    │ backend.service.ts   │
    │  Recibe datos        │
    └────────┬─────────────┘
             │
             ▼
    ┌──────────────────────┐
    │  app.component.ts    │
    │  this.usuarios =     │
    │  data                │
    └────────┬─────────────┘
             │
             ▼
    ┌──────────────────────┐
    │  app.component.html  │
    │  Renderiza tabla     │
    │  ngFor usuarios      │
    └────────┬─────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│    Tabla HTML en Navegador             │
│                                        │
│ ID │ Nombre    │ Correo              │
│ 1  │ Juan Pérez│ juan@example.com    │
│ 2  │ María G.  │ maria@example.com   │
└────────────────────────────────────────┘
```

## Tecnologías

| Componente | Tecnología | Versión |
|-----------|-----------|---------|
| **Frontend Framework** | Angular | 17.0.0 |
| **Language** | TypeScript | 5.2.2 |
| **HTTP Client** | @angular/common/http | 17.0.0 |
| **Estilos** | SCSS | Built-in |
| **Node Runtime** | Node.js | 18.x |
| **Build Tool** | Angular CLI | 17.0.0 |
| **Web Server** | Nginx | Alpine |
| **Container** | Docker | Latest |
| **Package Manager** | npm | 9.x+ |

## Archivos Críticos

| Archivo | Descripción | Importancia |
|---------|------------|------------|
| `src/app/services/backend.service.ts` | **EDITAR: URL del backend** | 🔴 Crítico |
| `Dockerfile` | Build image | 🟡 Importante |
| `nginx.conf` | Servidor web | 🟡 Importante |
| `README.md` | Documentación | 🟢 Referencia |
| `deploy.sh` | Script deployment | 🟢 Utilidad |

## Comandos Principales

```bash
# Desarrollo local
npm install          # Instalar dependencias
npm start            # Ejecutar dev server (localhost:4200)

# Build
npm run build:prod   # Build optimizado para producción

# Docker
docker build -t frontend-app .                    # Construir imagen
docker run -d -p 80:80 frontend-app             # Ejecutar
docker ps                                        # Listar contenedores
docker logs -f frontend-app                      # Ver logs
docker stop <container-id>                       # Detener

# AWS EC2
./deploy.sh 10.0.2.5                            # Deploy automático
curl http://localhost/health                     # Health check
```

## Checklist de Deployment

- [ ] IP privada del backend en `backend.service.ts`
- [ ] Dockerfile presente y funcional
- [ ] `nginx.conf` configurado correctamente
- [ ] Security groups AWS configurados (puerto 80, backend 8080)
- [ ] VPC y subnets configuradas
- [ ] Backend está ejecutándose en puerto 8080
- [ ] Docker instalado en EC2
- [ ] `docker build -t frontend-app .` ejecutado
- [ ] `docker run -d -p 80:80 frontend-app` ejecutado
- [ ] Health check: `curl http://localhost/health` retorna 200
- [ ] Frontend accesible desde navegador

## Recursos de Referencia

- [Angular Documentation](https://angular.io/docs)
- [Docker Documentation](https://docs.docker.com)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
