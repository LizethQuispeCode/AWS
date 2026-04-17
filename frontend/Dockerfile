# FASE 1: Build de Angular con Node.js 18
FROM node:18 as build

WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar fuentes
COPY . .

# Build para producción
RUN npm run build:prod

# FASE 2: Servir con Nginx Alpine
FROM nginx:alpine

# Copiar build a la carpeta de Nginx
COPY --from=build /app/dist/frontend-app /usr/share/nginx/html

# Copiar configuración de Nginx personalizada
COPY nginx.conf /etc/nginx/nginx.conf

# Exponer puerto 80
EXPOSE 80

# Comando por defecto
CMD ["nginx", "-g", "daemon off;"]
