# 🔐 Sistema de Roles y Permisos - Level Up Gamer

## 📋 Roles Implementados

### 1. 👤 Usuario (usuario)
**Descripción:** Cliente estándar de la tienda

**Permisos:**
- ✅ Ver y navegar por la tienda pública
- ✅ Ver productos y detalles
- ✅ Agregar productos al carrito
- ✅ Realizar compras (crear órdenes)
- ✅ **EXCLUSIVO: Ver sus propias órdenes (solo usuarios pueden ver órdenes)**
- ✅ Editar su propio perfil
- ✅ Cambiar su contraseña
- ❌ NO puede acceder al panel de administración
- ❌ NO puede editar productos
- ❌ NO puede gestionar otros usuarios

**Rutas accesibles:**
- `/` - Inicio
- `/productos` - Catálogo de productos
- `/detalle/:codigo` - Detalle de producto
- `/carrito` - Carrito de compras
- `/perfil` - Mi perfil (edición) ⭐ EXCLUSIVO
- `/mis-ordenes` - Mis órdenes ⭐ EXCLUSIVO
- `/nosotros` - Nosotros
- `/contacto` - Contacto
- `/noticias` - Noticias

**Redirección al login:**
- Si no está autenticado → `/login`
- Después del login → `/perfil`

---

### 2. 🏪 Vendedor (vendedor)
**Descripción:** Usuario con permisos para gestionar productos

**Permisos:**
- ✅ Ver y navegar por la tienda pública
- ✅ Ver productos y detalles
- ✅ Acceder al panel de vendedor
- ✅ Ver dashboard de productos (estadísticas)
- ✅ Crear nuevos productos
- ✅ Editar productos existentes
- ✅ Eliminar productos
- ✅ Editar su propio perfil (vendedor)
- ✅ Cambiar su contraseña
- ❌ NO puede ver órdenes (funcionalidad exclusiva de usuarios)
- ❌ NO puede realizar compras
- ❌ NO puede gestionar usuarios
- ❌ NO puede acceder a logs del sistema
- ❌ NO puede gestionar productos destacados
- ❌ NO puede acceder al panel de administración completo

**Rutas accesibles:**
- `/` - Inicio
- `/productos` - Catálogo de productos (solo visualización)
- `/detalle/:codigo` - Detalle de producto
- `/vendedor` - Dashboard de vendedor ⭐ EXCLUSIVO
- `/vendedor/productos` - Gestión de productos ⭐ EXCLUSIVO
- `/vendedor/productos/nuevo` - Crear producto ⭐ EXCLUSIVO
- `/vendedor/productos/editar/:codigo` - Editar producto ⭐ EXCLUSIVO
- `/vendedor/perfil` - Mi perfil (edición) ⭐ EXCLUSIVO

**Redirección al login:**
- Si no está autenticado → `/login`
- Después del login → `/vendedor`

---

### 3. 👨‍💼 Administrador (admin)
**Descripción:** Usuario con permisos completos del sistema

**Permisos:**
- ✅ Ver y navegar por la tienda pública
- ✅ Ver productos y detalles
- ✅ Acceder al panel de administración completo
- ✅ Gestionar productos (crear, editar, eliminar)
- ✅ Gestionar usuarios (crear, editar, eliminar)
- ✅ Ver y gestionar logs del sistema
- ✅ Gestionar productos destacados
- ✅ Ver estadísticas completas del sistema
- ✅ Acceso total a funcionalidades administrativas
- ❌ NO puede ver órdenes (funcionalidad exclusiva de usuarios)
- ❌ NO puede realizar compras (no es su función)

**Rutas accesibles:**
- `/` - Inicio
- `/productos` - Catálogo de productos (solo visualización)
- `/detalle/:codigo` - Detalle de producto
- `/admin` - Dashboard de administración ⭐ EXCLUSIVO
- `/admin/productos` - Gestión de productos ⭐ EXCLUSIVO
- `/admin/productos/nuevo` - Crear producto ⭐ EXCLUSIVO
- `/admin/productos/editar/:codigo` - Editar producto ⭐ EXCLUSIVO
- `/admin/destacados` - Gestión de destacados ⭐ EXCLUSIVO
- `/admin/usuarios` - Gestión de usuarios ⭐ EXCLUSIVO
- `/admin/usuarios/nuevo` - Crear usuario ⭐ EXCLUSIVO
- `/admin/usuarios/editar/:correo` - Editar usuario ⭐ EXCLUSIVO
- `/admin/logs` - Logs del sistema ⭐ EXCLUSIVO

**Redirección al login:**
- Si no está autenticado → `/login`
- Después del login → `/admin`

---

## 🛡️ Componente ProtectedRoute

### Uso:
```jsx
<ProtectedRoute allowedRoles={['usuario', 'vendedor', 'admin']}>
  <ComponenteProtegido />
</ProtectedRoute>
```

### Parámetros:
- `allowedRoles`: Array de roles permitidos
- Si está vacío `[]`, solo verifica autenticación

### Comportamiento:
1. Verifica si hay usuario en `localStorage.getItem('usuarioActual')`
2. Si no hay usuario → Redirige a `/login`
3. Si hay usuario, verifica el rol contra `allowedRoles`
4. Si el rol no está permitido → Redirige a `/` (home)
5. Si el rol está permitido → Renderiza el componente

---

## 🎨 Headers Contextuales

### Header Público (Usuario no autenticado)
```
Inicio | Productos | Noticias | Nosotros | Contacto | Registro | Login | 🛒
```

### Header Usuario Autenticado (rol: usuario)
```
Mi Perfil | Mis Órdenes | Productos | Carrito | Inicio | Cerrar Sesión
```

### Header Vendedor (rol: vendedor)
```
Dashboard | Productos | Mi Perfil | Ver Tienda | Cerrar Sesión
(No tiene acceso a Mis Órdenes ni Carrito)
```

### Header Admin (rol: admin)
```
Dashboard | Productos | Destacados | Usuarios | Logs | Cerrar Sesión
(No tiene acceso a Mis Órdenes ni Carrito)
```

---

## 📊 Páginas por Rol

### Perfil.jsx (Usuario)
**Ruta:** `/perfil`
**Acceso:** ⭐ SOLO usuario

**Funcionalidades:**
- Ver y editar información personal
- Cambiar contraseña
- Ver últimas 5 órdenes
- Accesos rápidos a productos, órdenes y carrito

### MisOrdenes.jsx (Usuario)
**Ruta:** `/mis-ordenes`
**Acceso:** ⭐ SOLO usuario

**Funcionalidades:**
- Ver historial completo de órdenes
- Ver estado de cada orden
- Ver detalles de productos en cada orden
- Ver totales y métodos de pago

### VendedorHome.jsx
**Ruta:** `/vendedor`
**Acceso:** vendedor

**Funcionalidades:**
- Dashboard con estadísticas de productos
- Total de productos, con stock, sin stock
- Accesos rápidos a gestión de productos y perfil
- Lista de productos recientes

### VendedorProductos.jsx
**Ruta:** `/vendedor/productos`
**Acceso:** vendedor

**Funcionalidades:**
- Listar todos los productos
- Crear nuevo producto
- Editar productos existentes
- Eliminar productos
- Filtrar por nombre/código y categoría
- Estadísticas de productos

### VendedorProductoForm.jsx
**Rutas:** `/vendedor/productos/nuevo` | `/vendedor/productos/editar/:codigo`
**Acceso:** vendedor

**Funcionalidades:**
- Formulario para crear/editar productos
- Upload de imágenes con File Service
- Validaciones de campos
- Vista previa de imagen

### VendedorPerfil.jsx
**Ruta:** `/vendedor/perfil`
**Acceso:** vendedor

**Funcionalidades:**
- Editar información personal del vendedor
- Cambiar contraseña
- Accesos rápidos a gestión de productos

### AdminHome.jsx
**Ruta:** `/admin`
**Acceso:** admin

**Funcionalidades:**
- Dashboard completo con todas las estadísticas
- Gestión de productos, usuarios, destacados
- Ver logs del sistema

---

## 🔄 Flujo de Autenticación

### Login
1. Usuario ingresa credenciales en `/login`
2. Sistema verifica en `localStorage.getItem('usuarios')`
3. Si es válido, guarda en `localStorage.setItem('usuarioActual', ...)`
4. Redirige según rol:
   - `admin` → `/admin`
   - `vendedor` → `/vendedor`
   - `usuario` → `/perfil`

### Logout
1. Usuario hace clic en "Cerrar Sesión"
2. Sistema ejecuta `localStorage.removeItem('usuarioActual')`
3. Redirige a `/login`

---

## 🗄️ Estructura de Usuario en localStorage

```javascript
{
  correo: "usuario@example.com",
  password: "password123",
  nombre: "Juan",
  apellidos: "Pérez",
  telefono: "+56912345678",
  direccion: "Calle Ejemplo 123",
  ciudad: "Santiago",
  rol: "usuario" | "vendedor" | "admin"
}
```

---

## 🎯 Casos de Uso

### Caso 1: Cliente hace una compra
1. Usuario navega por `/productos`
2. Agrega productos al carrito
3. Va a `/carrito`
4. Hace clic en "Finalizar Compra"
5. Si no está autenticado → Redirige a `/login`
6. Después del login (rol: usuario) → Redirige a `/perfil`
7. Puede ver su orden en `/mis-ordenes`

### Caso 2: Vendedor actualiza stock
1. Vendedor inicia sesión (rol: vendedor)
2. Redirige a `/vendedor` (dashboard)
3. Va a `/vendedor/productos`
4. Busca el producto a actualizar
5. Hace clic en "Editar"
6. Actualiza el stock
7. Guarda cambios

### Caso 3: Admin gestiona usuarios
1. Admin inicia sesión (rol: admin)
2. Redirige a `/admin` (dashboard)
3. Va a `/admin/usuarios`
4. Puede crear, editar o eliminar usuarios
5. Puede ver logs en `/admin/logs`

---

## 🔧 Configuración Inicial

### Crear usuarios de prueba:
```javascript
// En inicializarDatos.jsx o directamente en consola del navegador
const usuarios = [
  {
    correo: "usuario@levelup.cl",
    password: "usuario123",
    nombre: "Cliente",
    apellidos: "Prueba",
    rol: "usuario"
  },
  {
    correo: "vendedor@levelup.cl",
    password: "vendedor123",
    nombre: "Vendedor",
    apellidos: "Prueba",
    rol: "vendedor"
  },
  {
    correo: "admin@levelup.cl",
    password: "admin123",
    nombre: "Admin",
    apellidos: "Prueba",
    rol: "admin"
  }
];
localStorage.setItem('usuarios', JSON.stringify(usuarios));
```

---

## 📝 Logging

### Usuario
- Registro de acciones en `logsUsuario`
- Login, compras, visualizaciones

### Vendedor
- Registro en `logsAdmin` con prefijo "Vendedor"
- Creación/edición/eliminación de productos

### Admin
- Registro en `logsAdmin`
- Todas las acciones administrativas

---

## ⚠️ Seguridad

### Validaciones implementadas:
- ✅ Verificación de autenticación en rutas protegidas
- ✅ Verificación de rol en cada ruta
- ✅ Redirección automática si no tiene permisos
- ✅ Headers contextuales según rol
- ✅ Logging de acciones por rol

### Pendientes (para producción):
- 🔄 JWT tokens en lugar de localStorage
- 🔄 Refresh tokens
- 🔄 Encriptación de contraseñas (bcrypt)
- 🔄 Rate limiting
- 🔄 HTTPS obligatorio
- 🔄 CSRF protection

---

**Última actualización:** 27 de noviembre de 2025
**Versión:** 1.0.0
