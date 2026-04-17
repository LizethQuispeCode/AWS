# Stage 1: Build
FROM maven:3.9-eclipse-temurin-17 as builder

WORKDIR /app

# Copiar pom.xml y descargar dependencias
COPY pom.xml .
RUN mvn dependency:go-offline

# Copiar código fuente
COPY src ./src

# Compilar y empaquetar
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copiar el JAR del stage de build
COPY --from=builder /app/target/*.jar app.jar

# Exponer el puerto 8080
EXPOSE 8080

# Variables de entorno por defecto (pueden ser sobrescritas)
ENV DB_IP=localhost
ENV DB_USER=sa
ENV DB_PASSWORD=TuPassword123

# Comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]
