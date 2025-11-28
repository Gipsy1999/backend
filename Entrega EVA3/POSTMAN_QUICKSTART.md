# 🚀 GUÍA RÁPIDA POSTMAN - LEVEL UP

## 📥 IMPORTAR COLECCIÓN

1. Abre **Postman**
2. Click en **Import** (esquina superior izquierda)
3. Arrastra el archivo `LevelUp_Postman_Collection.json` o click "Upload Files"
4. Click **Import**
5. ✅ Listo - Verás 9 carpetas con 52 endpoints

---

## ⚡ CONFIGURACIÓN INICIAL

### **Crear Variable de Token (Opcional pero recomendado)**

1. En Postman, ve a **Environments** (icono de ojo)
2. Click **Add** → Nuevo Environment: `LevelUp`
3. Agrega variable:
   - **Variable:** `token`
   - **Initial Value:** (dejar vacío)
   - **Current Value:** (dejar vacío)
4. **Save**
5. Selecciona el environment `LevelUp` en el dropdown superior

---

## 🔥 PRUEBAS RÁPIDAS

### **1️⃣ TEST BÁSICO - LOGIN**

**Request:** `1. Auth Service (8081) → Login`

```json
{
  "correo": "admin@levelup.cl",
  "password": "admin123"
}
```

**Respuesta esperada (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "tipo": "Bearer",
  "id": 1,
  "nombre": "Admin",
  "apellidos": "Level Up",
  "correo": "admin@levelup.cl",
  "rol": "ADMIN",
  "mensaje": "Inicio de sesión exitoso"
}
```

**💡 Acción:** Copia el valor de `token` para requests autenticados

---

### **2️⃣ REGISTRAR USUARIO (18+ años)**

**Request:** `1. Auth Service (8081) → Register`

```json
{
  "run": "12345678-9",
  "nombre": "Juan",
  "apellidos": "Pérez González",
  "correo": "juan@test.cl",
  "password": "password123",
  "telefono": "912345678",
  "direccion": "Santiago Centro",
  "fechaNacimiento": "1995-05-15"
}
```

**✅ Validaciones automáticas:**
- ✅ RUN formato chileno: `12345678-9`
- ✅ Password mínimo 6 caracteres
- ✅ Edad mínima 18 años
- ✅ Correo válido

**❌ Ejemplos que FALLAN:**

```json
// MENOR DE EDAD - RECHAZADO
{
  "fechaNacimiento": "2010-01-01"
}
// Error: "Debes ser mayor de 18 años para registrarte"

// PASSWORD CORTO - RECHAZADO
{
  "password": "123"
}
// Error: "La contrasena debe tener al menos 6 caracteres"

// RUN INVÁLIDO - RECHAZADO
{
  "run": "123"
}
// Error: "Formato de RUN invalido"
```

---

### **3️⃣ LISTAR USUARIOS**

**Request:** `2. User Service (8082) → Get All Users`

Sin body, solo GET.

**Respuesta (200 OK):** Array de usuarios

---

### **4️⃣ CREAR PRODUCTO**

**Request:** `3. Product Service (8083) → Create Product`

```json
{
  "nombre": "Mouse Gamer RGB",
  "descripcion": "Mouse gaming con iluminación RGB",
  "precio": 29990,
  "categoria": "Perifericos",
  "stock": 50,
  "imagenUrl": "https://example.com/mouse.jpg",
  "destacado": true,
  "marca": "Logitech",
  "descuento": 0
}
```

---

### **5️⃣ CREAR ORDEN**

**Request:** `4. Order Service (8084) → Create Order`

```json
{
  "usuarioId": 1,
  "usuarioNombre": "Admin Level Up",
  "usuarioCorreo": "admin@levelup.cl",
  "direccionEnvio": "Santiago Centro, Chile",
  "metodoPago": "Tarjeta de Credito",
  "detalles": [
    {
      "productoId": 1,
      "productoNombre": "PlayStation 5",
      "cantidad": 1,
      "precioUnitario": 499990
    }
  ]
}
```

---

## 📊 HEALTH CHECKS - VERIFICAR SERVICIOS

Ejecuta estos endpoints para verificar que los servicios estén corriendo:

| Servicio | Endpoint | Puerto |
|----------|----------|--------|
| API Gateway | `GET http://localhost:8080/actuator/health` | 8080 |
| Auth Service | `GET http://localhost:8081/api/auth/health` | 8081 |
| User Service | `GET http://localhost:8082/api/usuarios/health` | 8082 |
| Product Service | `GET http://localhost:8083/api/productos/health` | 8083 |
| Order Service | `GET http://localhost:8084/api/ordenes/health` | 8084 |
| Analytics Service | `GET http://localhost:8085/api/analytics/health` | 8085 |
| Notification Service | `GET http://localhost:8086/api/notificaciones/health` | 8086 |
| File Service | `GET http://localhost:8087/api/files/health` | 8087 |
| Config Service | `GET http://localhost:8888/api/config/health` | 8888 |

**Respuesta esperada de todos:**
```json
{"status": "OK"}
```

---

## 🔐 CREDENCIALES DE PRUEBA

### **Usuarios predefinidos:**

| Rol | Email | Password |
|-----|-------|----------|
| ADMIN | `admin@levelup.cl` | `admin123` |
| CLIENTE | `usuario@test.cl` | `user123` |
| VENDEDOR | `vendedor@levelup.cl` | `vendedor123` |

---

## 📝 VALIDACIONES IMPORTANTES

### **RUN (Cédula Chilena)**
- ✅ Formato: `12345678-9` o `1234567-K`
- ✅ Pattern: `^\d{7,8}-[0-9Kk]$`
- ❌ Rechaza: `12345678` (sin guión), `123-4` (muy corto)

### **Correo**
- ✅ Formato estándar: `user@domain.com`
- ❌ Rechaza: `user@`, `@domain.com`, `userdomain.com`

### **Password**
- ✅ Mínimo: 6 caracteres
- ❌ Rechaza: `123`, `pass`

### **Teléfono**
- ✅ Formato: 9 dígitos sin espacios `912345678`
- ❌ Rechaza: `91234` (muy corto), `+56912345678` (con código)

### **Edad**
- ✅ Mínimo: 18 años
- ✅ Ejemplo válido: `1995-05-15` (29 años)
- ❌ Rechaza: `2010-01-01` (14 años)

### **Roles Válidos**
- `CLIENTE` (predeterminado)
- `ADMIN`
- `VENDEDOR`
- `BODEGUERO`

---

## 🌐 RUTAS VÍA API GATEWAY

Todos los servicios también están disponibles a través del API Gateway en puerto **8080**:

```
http://localhost:8080/api/auth/login       → Auth Service
http://localhost:8080/api/usuarios         → User Service
http://localhost:8080/api/productos        → Product Service
http://localhost:8080/api/ordenes          → Order Service
http://localhost:8080/api/analytics/...    → Analytics Service
http://localhost:8080/api/files/...        → File Service
```

---

## 🔄 FLUJO COMPLETO DE PRUEBA

### **Secuencia recomendada:**

1. **Login** → Obtener token
   ```
   POST http://localhost:8081/api/auth/login
   ```

2. **Crear Usuario** (opcional)
   ```
   POST http://localhost:8082/api/usuarios
   ```

3. **Listar Productos**
   ```
   GET http://localhost:8083/api/productos
   ```

4. **Crear Producto** (como ADMIN)
   ```
   POST http://localhost:8083/api/productos
   ```

5. **Subir Imagen** (opcional)
   ```
   POST http://localhost:8087/api/files/upload/producto
   ```

6. **Crear Orden**
   ```
   POST http://localhost:8084/api/ordenes
   ```

7. **Ver Analytics**
   ```
   GET http://localhost:8085/api/analytics/dashboard
   ```

---

## ❌ ERRORES COMUNES

### **Error 500: Connection refused**
**Causa:** El servicio no está corriendo  
**Solución:** Ejecutar el servicio desde IntelliJ o terminal

### **Error 400: Validation failed**
**Causa:** Datos no cumplen validaciones  
**Solución:** Revisar formato de RUN, password min 6, edad 18+

### **Error 409: Already exists**
**Causa:** Correo o RUN ya registrado  
**Solución:** Usar otro correo/RUN

### **Error 404: Not found**
**Causa:** Endpoint incorrecto o ID no existe  
**Solución:** Verificar URL y que el ID exista

---

## 📦 COLECCIONES ORGANIZADAS

```
📁 LevelUp_Postman_Collection.json
  ├── 📂 1. Auth Service (8081)          [4 endpoints]
  ├── 📂 2. User Service (8082)          [8 endpoints]
  ├── 📂 3. Product Service (8083)       [10 endpoints]
  ├── 📂 4. Order Service (8084)         [7 endpoints]
  ├── 📂 5. Analytics Service (8085)     [10 endpoints]
  ├── 📂 6. Notification Service (8086)  [6 endpoints]
  ├── 📂 7. File Service (8087)          [6 endpoints]
  ├── 📂 8. Config Service (8888)        [3 endpoints]
  └── 📂 9. API Gateway (8080)           [5 endpoints]
```

**Total:** 52 endpoints listos para usar

---

## 🎯 TIPS PRODUCTIVIDAD

### **1. Guardar Token Automáticamente**

En el request de Login, ve a **Tests** y agrega:

```javascript
pm.test("Login successful", function () {
    var jsonData = pm.response.json();
    pm.environment.set("token", jsonData.token);
});
```

Ahora el token se guardará automáticamente en la variable `{{token}}`

### **2. Usar Variables**

En cualquier request que necesite el token:

**Headers:**
```
Authorization: Bearer {{token}}
```

### **3. Ejecutar Colección Completa**

1. Click derecho en la colección
2. **Run collection**
3. Selecciona requests específicos o todos
4. **Run**

---

## 📚 DOCUMENTACIÓN ADICIONAL

- **Estándares:** Ver `ESTANDARES_PROYECTO.md`
- **Guía completa:** Ver `GUIA_POSTMAN_COMPLETA.md`
- **Microservicios:** Ver documentación individual de cada servicio

---

**Última actualización:** 25/11/2025  
**Versión colección:** 1.0  
**Total endpoints:** 52
