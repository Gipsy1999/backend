# Level-Up Gamer - Aplicación React

## Descripción del Proyecto

Level-Up Gamer es una tienda en línea especializada en productos gaming desarrollada con React. La aplicación ofrece una experiencia completa de e-commerce con gestión de productos, carrito de compras, sistema de usuarios y un panel de administración completo.

## Características Principales

### Para Usuarios
- Catálogo de productos con filtros por categoría y búsqueda
- Sistema de carrito de compras con persistencia en localStorage
- Vista detallada de productos con zoom en imágenes
- Carrusel de productos destacados en la página principal
- Formulario de contacto con validación
- Sistema de registro e inicio de sesión
- Gestión de perfil de usuario
- Notificaciones en tiempo real
- Diseño responsive para móviles, tablets y desktop

### Para Administradores
- Panel de administración con estadísticas
- Gestión completa de productos (crear, editar, eliminar)
- Administración de usuarios
- Gestión de productos destacados para el carrusel
- Sistema de logs para auditoría de acciones
- Validaciones de seguridad y permisos

## Tecnologías Utilizadas

### Framework y Librerías
- React 19.2.0
- React Router DOM 7.9.4 (navegación)
- Bootstrap 5.3.8 (estilos y componentes UI)
- Context API (gestión de estado del carrito)

### Testing
- Karma 6.4.4 (test runner)
- Jasmine (framework de testing)
- React Testing Library 16.3.0
- Jest DOM 6.9.1

### Herramientas de Desarrollo
- Create React App 5.0.1
- Webpack 5.102.1
- Babel 7.x (transpilación)
- ESLint (análisis de código)

## Estructura del Proyecto

```
src/
├── components/          # Componentes reutilizables
│   ├── Header.jsx
│   ├── Footer.jsx
│   ├── CarritoDebug.jsx
│   ├── ModalConfirmacion.jsx
│   ├── Notificacion.jsx
│   └── ProtectedRoute.jsx
├── pages/              # Páginas de la aplicación
│   ├── Home.jsx
│   ├── Productos.jsx
│   ├── Detalle.jsx
│   ├── Carrito.jsx
│   ├── Login.jsx
│   ├── Registro.jsx
│   ├── Contacto.jsx
│   ├── Nosotros.jsx
│   ├── Noticias.jsx
│   ├── AdminHome.jsx
│   ├── AdminProductos.jsx
│   ├── AdminProductoForm.jsx
│   ├── AdminUsuarios.jsx
│   ├── AdminUsuarioForm.jsx
│   ├── AdminDestacados.jsx
│   └── AdminLogs.jsx
├── context/            # Context API
│   └── CarritoContext.js
├── styles/             # Archivos CSS
│   ├── Header.css
│   ├── Footer.css
│   ├── Home.css
│   ├── Productos.css
│   ├── Detalle.css
│   ├── Carrito.css
│   ├── Login.css
│   ├── Registro.css
│   ├── Contacto.css
│   ├── Nosotros.css
│   ├── Noticias.css
│   ├── Admin.css
│   ├── CarritoDebug.css
│   ├── ModalConfirmacion.css
│   └── Notificacion.css
├── utils/              # Utilidades y funciones auxiliares
│   ├── validaciones.js
│   ├── logManager.js
│   ├── inicializarDatos.js
│   └── zoomManager.js
└── tests/              # Tests con Jasmine
    ├── carrito.spec.js
    ├── Login.spec.js
    └── Registro.spec.js
```

## Instalación y Configuración

### Requisitos Previos
- Node.js (versión 14 o superior)
- npm o yarn
- Navegador web moderno (Chrome, Firefox, Edge, Safari)

### Pasos de Instalación

1. Clonar el repositorio
```bash
git clone https://github.com/ClaudioFranciscoDelgadoGallardo/Front_level_up.git
cd Front_level_up/Entrega\ EVA2/level-up
```

2. Instalar dependencias
```bash
npm install
```

3. Iniciar la aplicación en modo desarrollo
```bash
npm start
```

La aplicación se abrirá automáticamente en http://localhost:3000

## Scripts Disponibles

### Desarrollo
```bash
npm start
```
Inicia el servidor de desarrollo con hot-reload.

### Testing
```bash
npm test
```
Ejecuta los tests con React Testing Library en modo watch.

```bash
npm run test:ui
```
Ejecuta los tests con Karma/Jasmine en Chrome Headless.

### Producción
```bash
npm run build
```
Genera la versión optimizada para producción en la carpeta `build/`.

## Sistema de Testing

El proyecto incluye dos sistemas de testing:

### Tests con Karma y Jasmine
- Ubicados en `src/tests/`
- Ejecutar con `npm run test:ui`
- 10 tests implementados que validan:
  - Funcionalidad del carrito de compras
  - Validaciones de login
  - Validaciones de registro

### Tests con React Testing Library
- Ubicados junto a los componentes
- Ejecutar con `npm test`
- Tests unitarios de componentes React

## Funcionalidades Detalladas

### Gestión de Productos
- Listado con paginación y filtros
- Búsqueda en tiempo real
- Categorización (Consolas, Juegos, Accesorios, etc.)
- Validación de stock antes de agregar al carrito
- Imágenes con zoom interactivo

### Carrito de Compras
- Agregar/eliminar productos
- Modificar cantidades
- Cálculo automático de subtotales y totales
- Aplicación de descuentos (10% en compras sobre $100.000)
- Persistencia en localStorage
- Validación de stock al finalizar compra

### Sistema de Usuarios
- Registro con validación de datos:
  - RUN chileno (mínimo 9 caracteres)
  - Email único
  - Campos obligatorios
- Login con credenciales
- Dos roles: usuario y admin
- Sesión persistente en localStorage

### Panel de Administración
- Acceso restringido solo para administradores
- Estadísticas en tiempo real
- CRUD completo de productos
- CRUD completo de usuarios
- Gestión de productos destacados
- Sistema de logs con registro de todas las acciones
- Filtros por fecha y tipo de acción

### Sistema de Logs
Registra automáticamente:
- Inicio y cierre de sesión
- Creación, edición y eliminación de productos
- Creación, edición y eliminación de usuarios
- Finalización de compras
- Cambios en productos destacados

## Credenciales de Prueba

### Usuario Administrador
- Correo: admin@levelup.com
- Contraseña: admin123

### Usuario Regular
- Correo: usuario@ejemplo.com
- Contraseña: usuario123

## Datos Iniciales

La aplicación se inicializa automáticamente con:
- 12 productos de diferentes categorías
- 2 usuarios (1 admin, 1 usuario regular)
- 3 productos destacados para el carrusel
- Estructura de logs vacía

## Responsive Design

La aplicación está optimizada para:
- Móviles (< 576px)
- Tablets (576px - 768px)
- Desktop (> 768px)

Utiliza el sistema de grid de Bootstrap con breakpoints adaptativos.

## Persistencia de Datos

Todos los datos se almacenan en localStorage:
- `productos`: Catálogo completo
- `usuarios`: Base de datos de usuarios
- `usuarioActual`: Sesión activa
- `carrito`: Items del carrito
- `destacados`: Códigos de productos destacados
- `logs`: Historial de acciones

## Validaciones Implementadas

### Productos
- Código único
- Nombre (3-100 caracteres)
- Precio mayor a 0
- Stock no negativo
- URL o archivo de imagen válido

### Usuarios
- RUN mínimo 9 caracteres
- Email único y formato válido
- Nombre máximo 50 caracteres
- Apellidos máximo 100 caracteres
- Todos los campos obligatorios

### Carrito
- Stock disponible antes de agregar
- Cantidades válidas (mínimo 1)
- Validación de stock al finalizar compra

## Optimizaciones

- Código CSS separado del JSX (mejores prácticas)
- Lazy loading de imágenes
- Debounce en búsquedas
- Memoización de cálculos pesados
- Minimización de re-renders con Context API
- Build optimizado con code splitting

## Problemas Conocidos y Limitaciones

- Los datos se pierden al limpiar localStorage
- No hay persistencia en base de datos real
- Las imágenes se almacenan como URLs o base64
- Límite de 5MB por imagen en localStorage
- Sin sistema de recuperación de contraseña

## Mejoras Futuras

- Integración con backend y base de datos
- Sistema de pagos real
- Recuperación de contraseña por email
- Chat en vivo con soporte
- Sistema de reseñas y valoraciones
- Wishlist de productos favoritos
- Historial de compras por usuario
- Notificaciones push
- Modo oscuro/claro

## Compatibilidad de Navegadores

- Chrome (última versión)
- Firefox (última versión)
- Safari (última versión)
- Edge (última versión)
- Opera (última versión)

No compatible con Internet Explorer.

## Licencia

Este proyecto es parte de una evaluación académica.

## Autor

Claudio Francisco Delgado Gallardo

## Fecha

Octubre 2025
