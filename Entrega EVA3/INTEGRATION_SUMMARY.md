# 🚀 Integración Order Service y File Service

## ✅ Servicios Implementados

### 1. Order Service (Puerto 8084)
**Ubicación:** `src/services/orderService.js`

#### Funciones disponibles:
- `createOrder(orderData)` - Crea una nueva orden de compra
- `getUserOrders()` - Obtiene todas las órdenes del usuario actual
- `getOrderById(orderId)` - Obtiene una orden específica
- `updateOrderStatus(orderId, status)` - Actualiza el estado de una orden
- `cancelOrder(orderId)` - Cancela una orden
- `getAllOrders(params)` - Obtiene todas las órdenes (Admin)

#### Estados de órdenes:
- `PENDING` - Pendiente
- `CONFIRMED` - Confirmada
- `SHIPPED` - Enviada
- `DELIVERED` - Entregada
- `CANCELLED` - Cancelada

---

### 2. File Service (Puerto 8087)
**Ubicación:** `src/services/fileService.js`

#### Funciones disponibles:
- `uploadFile(file, category)` - Sube un archivo al servidor
- `downloadFile(filename)` - Descarga un archivo
- `getFileUrl(filename)` - Obtiene la URL pública de un archivo
- `deleteFile(filename)` - Elimina un archivo
- `listFiles(category)` - Lista todos los archivos (Admin)
- `validateFile(file, options)` - Valida un archivo antes de subirlo

#### Categorías soportadas:
- `productos` - Imágenes de productos
- `usuarios` - Imágenes de perfiles
- `documentos` - Documentos varios

#### Validaciones:
- Tamaño máximo: 5MB (configurable)
- Formatos permitidos: JPG, PNG, GIF, WEBP

---

## 📦 Componentes Actualizados

### 1. Carrito.jsx
**Cambios:**
- ✅ Integrado con Order Service para crear órdenes reales
- ✅ Validación de autenticación antes de checkout
- ✅ Verificación de stock antes de procesar
- ✅ Actualización automática de stock después de compra
- ✅ Redirección a "Mis Órdenes" después de compra exitosa
- ✅ Manejo de errores con notificaciones

**Flujo de compra:**
1. Usuario hace clic en "Finalizar Compra"
2. Verifica autenticación (redirige a login si no está autenticado)
3. Verifica stock disponible
4. Crea orden en Order Service
5. Actualiza stock local (temporal hasta integrar Product Service)
6. Vacía el carrito
7. Redirige a "Mis Órdenes"

---

### 2. AdminProductoForm.jsx
**Cambios:**
- ✅ Integrado con File Service para subir imágenes
- ✅ Upload de imágenes al servidor (no solo base64)
- ✅ Vista previa de imágenes con URL del File Service
- ✅ Validación de archivos antes de subir
- ✅ Indicador de progreso durante la subida
- ✅ Fallback a base64 si falla el upload
- ✅ Soporte para URLs externas y rutas locales

**Flujo de subida:**
1. Usuario selecciona imagen desde su computador
2. Valida tamaño y formato
3. Sube a File Service con categoría "productos"
4. Obtiene URL del archivo subido
5. Actualiza vista previa con URL real
6. Guarda URL en el producto

---

### 3. MisOrdenes.jsx (NUEVO)
**Funcionalidad:**
- ✅ Lista todas las órdenes del usuario autenticado
- ✅ Muestra estado de cada orden con badges de colores
- ✅ Detalle de productos en cada orden
- ✅ Totales: subtotal, descuento, total
- ✅ Información de envío y pago
- ✅ Ordenadas por fecha (más reciente primero)
- ✅ Página vacía cuando no hay órdenes
- ✅ Manejo de errores con retry

**Estados visuales:**
- 🟡 PENDING → Badge amarillo "Pendiente"
- 🔵 CONFIRMED → Badge azul "Confirmada"
- 🔷 SHIPPED → Badge azul oscuro "Enviada"
- 🟢 DELIVERED → Badge verde "Entregada"
- 🔴 CANCELLED → Badge rojo "Cancelada"

---

## 🔧 Configuración

### Variables de Entorno
Crear archivo `.env` basado en `.env.example`:

```bash
# Development
REACT_APP_API_GATEWAY_URL=http://localhost:8080

# Production
REACT_APP_API_GATEWAY_URL=http://144.22.43.202:8080
```

### Rutas Añadidas en App.jsx
```jsx
<Route path="/mis-ordenes" element={<ProtectedRoute><MisOrdenes /></ProtectedRoute>} />
```

### Header Actualizado
Nuevo enlace "Mis Órdenes" en el menú principal (solo visible cuando el usuario está autenticado)

---

## 📊 Estructura de Datos

### Order Object
```javascript
{
  id: "123",
  userId: "user-uuid",
  items: [
    {
      productId: "PROD001",
      productName: "Monopoly Clásico",
      quantity: 2,
      price: 15990
    }
  ],
  totalAmount: 31980,
  subtotalAmount: 35000,
  discountAmount: 3020,
  shippingAddress: "Calle Ejemplo 123",
  paymentMethod: "Tarjeta de Crédito",
  status: "PENDING",
  createdAt: "2025-11-27T10:30:00Z",
  updatedAt: "2025-11-27T10:30:00Z"
}
```

### File Upload Response
```javascript
{
  filename: "producto-12345.jpg",
  fileUrl: "http://localhost:8087/files/view/producto-12345.jpg",
  category: "productos",
  size: 245678,
  uploadedAt: "2025-11-27T10:30:00Z"
}
```

---

## 🧪 Testing

### Order Service - Endpoints Postman
Colección: `4_Order_Service.postman_collection.json`
- POST `/orders` - Crear orden
- GET `/orders/user/{userId}` - Obtener órdenes del usuario
- GET `/orders/{orderId}` - Obtener orden específica
- PATCH `/orders/{orderId}/status` - Actualizar estado
- GET `/orders` - Listar todas las órdenes (Admin)

### File Service - Endpoints Postman
Colección: `7_File_Service.postman_collection.json`
- POST `/files/upload?category=productos` - Subir archivo
- GET `/files/download/{filename}` - Descargar archivo
- GET `/files/view/{filename}` - Ver archivo
- DELETE `/files/delete/{filename}` - Eliminar archivo
- GET `/files/list?category=productos` - Listar archivos

---

## 🔒 Autenticación

Todas las peticiones incluyen el token JWT automáticamente:
```javascript
headers: {
  'Authorization': `Bearer ${localStorage.getItem('token')}`,
  'Content-Type': 'application/json'
}
```

---

## ⚠️ Notas Importantes

1. **Stock Management**: Actualmente se actualiza en localStorage. Una vez que Product Service esté integrado, se debe llamar a su API para actualizar stock real.

2. **Dirección de Envío**: Por ahora es un valor predeterminado. Se debe implementar gestión de direcciones del usuario.

3. **Método de Pago**: Temporal. Se debe integrar con un gateway de pagos real.

4. **File Service Local**: Las imágenes se guardan en el servidor File Service. En producción, considerar usar almacenamiento en la nube (AWS S3, Azure Blob, etc.)

5. **Fallback de Imágenes**: Si File Service no está disponible, el formulario de productos usa base64 como respaldo.

---

## 🚀 Próximos Pasos

- [ ] Integrar Product Service para gestión de stock real
- [ ] Implementar gestión de direcciones de usuario
- [ ] Añadir métodos de pago (Stripe, PayPal, etc.)
- [ ] Admin panel para gestionar órdenes
- [ ] Notificaciones por email al crear órdenes (Notification Service)
- [ ] Seguimiento de envíos
- [ ] Historial de cambios de estado de órdenes
- [ ] Exportar órdenes a PDF/Excel

---

## 📝 Comandos Útiles

```bash
# Desarrollo local
cd level-up
npm start

# Build para producción
npm run build

# Deploy a Firebase Hosting
firebase deploy --only hosting

# Iniciar Order Service
cd LevelUp_Order_service
./mvnw spring-boot:run

# Iniciar File Service
cd LevelUp_File_service
./mvnw spring-boot:run
```

---

## 📞 Soporte

Para problemas o preguntas:
1. Verificar logs del microservicio correspondiente
2. Revisar Postman collections para endpoints exactos
3. Validar que los servicios estén corriendo en los puertos correctos
4. Verificar variables de entorno en `.env`

---

**Última actualización:** 27 de noviembre de 2025
**Versión:** 1.0.0
