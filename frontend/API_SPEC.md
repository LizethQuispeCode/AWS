# API Specification - Backend Endpoint

## Requisitos del Endpoint Backend

El frontend espera que el backend proporcione datos en el siguiente formato:

### URL Base
```
http://IP_PRIVADA_BACKEND:8080
```

### Endpoint Principal
```
GET /datos
```

### Response Format (JSON)

**Status Code:** 200

**Body:**
```json
[
  {
    "id": 1,
    "nombre": "string",
    "correo": "string"
  },
  {
    "id": 2,
    "nombre": "string",
    "correo": "string"
  }
]
```

### Ejemplo Real

```json
[
  {
    "id": 1,
    "nombre": "Juan Pérez",
    "correo": "juan.perez@example.com"
  },
  {
    "id": 2,
    "nombre": "María García",
    "correo": "maria.garcia@example.com"
  },
  {
    "id": 3,
    "nombre": "Carlos López",
    "correo": "carlos.lopez@example.com"
  }
]
```

## CORS Headers

Para que el frontend acceda desde diferente dominio, el backend debe incluir:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

## Error Handling

El frontend maneja estos errores:

### Error de Conexión
```
Status: Connection Error
Mensaje: "Error al conectar con el backend"
```

### Error HTTP
```
Status: 4xx/5xx
Mensaje: "Error al conectar con el backend: [error details]"
```

### Sin Datos
```
Status: 200 OK
Body: []
Mensaje mostrado: "No hay datos disponibles"
```

## Testing del Backend

Desde la EC2 Frontend, probar conexión:

```bash
# Verificar conectividad TCP
telnet 10.0.2.5 8080

# Hacer request
curl http://10.0.2.5:8080/datos

# Con headers
curl -i http://10.0.2.5:8080/datos
```

## Modificar Estructura de Datos

Si el backend devuelve campos diferentes, editar `src/app/services/backend.service.ts`:

```typescript
export interface Usuario {
  id: number;
  nombre: string;
  correo: string;
  // Agregar más campos según necesidad
}
```

Y actualizar template `src/app/app.component.html`:

```html
<td>{{ usuario.nuevocampo }}</td>
```

## Rate Limiting

El frontend no implementa rate limiting. Asegúrese que el backend:

- Maneje múltiples requests
- Implemente timeout razonable (< 10 segundos)
- Tenga límite de conexiones
