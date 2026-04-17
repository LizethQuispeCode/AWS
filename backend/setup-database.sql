-- Script SQL para SQL Server
-- Crear base de datos y tabla de usuarios

-- Crear base de datos (ejecutar con permisos de administrador)
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'proyecto_db')
BEGIN
    CREATE DATABASE proyecto_db;
END
GO

-- Usar la base de datos
USE proyecto_db;
GO

-- Crear tabla usuarios
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'usuarios')
BEGIN
    CREATE TABLE usuarios (
        id BIGINT PRIMARY KEY IDENTITY(1,1),
        nombre NVARCHAR(255) NOT NULL,
        correo NVARCHAR(255) NOT NULL UNIQUE
    );
    
    PRINT 'Tabla usuarios creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla usuarios ya existe';
END
GO

-- Insertar datos de ejemplo
INSERT INTO usuarios (nombre, correo) VALUES 
    (N'Juan Pérez', N'juan@example.com'),
    (N'María García', N'maria@example.com'),
    (N'Carlos López', N'carlos@example.com'),
    (N'Ana Martínez', N'ana@example.com'),
    (N'Roberto Díaz', N'roberto@example.com');

PRINT 'Datos de ejemplo insertados';
GO

-- Verificar datos
SELECT 'Datos en tabla usuarios:' as Mensaje;
SELECT * FROM usuarios;
GO
