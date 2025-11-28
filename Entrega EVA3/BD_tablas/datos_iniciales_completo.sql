-- =============================================
-- DATOS INICIALES COMPLETOS PARA LEVEL UP E-COMMERCE
-- Compatible con schema_completo.sql
-- =============================================

-- IMPORTANTE: Ejecutar DESPUÉS de schema_completo.sql

-- =============================================
-- MÓDULO 1: USUARIOS
-- =============================================

-- Passwords hasheados con BCrypt
-- Password real: admin123 / user123
INSERT INTO usuarios (run, nombre, apellidos, correo, password, telefono, direccion, comuna, ciudad, region, fecha_nacimiento, rol, activo, verificado) VALUES
('12345678-9', 'Admin', 'Level Up', 'admin@levelup.cl', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '912345678', 'Av. Providencia 123', 'Providencia', 'Santiago', 'Región Metropolitana', '1990-01-01', 'ADMIN', TRUE, TRUE),
('98765432-1', 'Usuario', 'Demo', 'usuario@test.cl', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '987654321', 'Calle Principal 456', 'Santiago', 'Santiago', 'Región Metropolitana', '1995-05-15', 'CLIENTE', TRUE, TRUE),
('11111111-1', 'Juan', 'Pérez González', 'juan.perez@email.cl', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '956789012', 'Av. Libertad 456', 'Viña del Mar', 'Viña del Mar', 'Región de Valparaíso', '1988-03-20', 'CLIENTE', TRUE, TRUE),
('22222222-2', 'María', 'López Silva', 'maria.lopez@email.cl', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '945678901', 'Calle Los Aromos 123', 'Valparaíso', 'Valparaíso', 'Región de Valparaíso', '1992-07-15', 'CLIENTE', TRUE, TRUE),
('33333333-3', 'Pedro', 'Vendedor', 'vendedor@levelup.cl', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '934567890', 'Local Centro', 'Santiago', 'Santiago', 'Región Metropolitana', '1985-12-10', 'VENDEDOR', TRUE, TRUE);

-- =============================================
-- MÓDULO 2: CATÁLOGO
-- =============================================

-- Categorías
INSERT INTO categorias (nombre, descripcion, slug, activo, orden) VALUES
('Juegos de Mesa', 'Juegos de mesa para toda la familia', 'juegos-de-mesa', TRUE, 1),
('Accesorios', 'Accesorios para gaming y consolas', 'accesorios', TRUE, 2),
('Consolas', 'Consolas de videojuegos de última generación', 'consolas', TRUE, 3),
('Videojuegos', 'Videojuegos para todas las plataformas', 'videojuegos', TRUE, 4),
('Figuras', 'Figuras coleccionables y merchandising', 'figuras', TRUE, 5),
('Otros', 'Otros productos relacionados', 'otros', TRUE, 6);

-- Marcas
INSERT INTO marcas (nombre, descripcion, activo) VALUES
('Devir', 'Editorial de juegos de mesa', TRUE),
('Microsoft', 'Tecnología y gaming', TRUE),
('Sony', 'Consolas y entretenimiento', TRUE),
('Nintendo', 'Consolas y videojuegos', TRUE),
('Days of Wonder', 'Juegos de mesa premium', TRUE),
('Funko', 'Figuras coleccionables Pop!', TRUE),
('Logitech', 'Periféricos gaming', TRUE),
('Z-Man Games', 'Juegos de mesa cooperativos', TRUE);

-- Productos (usando IDs de categorías y marcas)
INSERT INTO productos (codigo, nombre, descripcion, descripcion_corta, categoria_id, marca_id, precio_base, precio_venta, costo, stock_actual, stock_minimo, imagen_principal, destacado, nuevo, oferta, descuento_porcentaje, activo, creado_por) VALUES
('JM001', 'Catan', 'Juego clásico de estrategia para construir y colonizar islas. Perfecto para 3-4 jugadores, con expansiones disponibles.', 'Juego clásico de estrategia', 1, 1, 29990, 29990, 18000, 15, 5, '/assets/imgs/destacado1.png', TRUE, FALSE, FALSE, 0.00, TRUE, 1),
('AC001', 'Control Xbox Series X', 'Control inalámbrico de última generación con tecnología háptica, gatillos adaptativos y batería recargable de larga duración.', 'Control inalámbrico Xbox', 2, 2, 59990, 53991, 40000, 20, 3, '/assets/imgs/destacado2.png', TRUE, TRUE, TRUE, 10.00, TRUE, 1),
('CO001', 'PlayStation 5', 'Consola de última generación con gráficos 4K, ray tracing en tiempo real, SSD ultra rápido y retrocompatibilidad con PS4.', 'Consola next-gen Sony', 3, 3, 549990, 549990, 450000, 8, 2, '/assets/imgs/destacado3.png', TRUE, TRUE, FALSE, 0.00, TRUE, 1),
('VJ001', 'The Legend of Zelda: Tears of the Kingdom', 'Aventura épica en mundo abierto. Explora los cielos de Hyrule. Exclusivo para Nintendo Switch.', 'Aventura mundo abierto', 4, 4, 59990, 56991, 45000, 25, 5, '/assets/imgs/zelda.png', FALSE, TRUE, TRUE, 5.00, TRUE, 1),
('JM002', 'Ticket to Ride', 'Juego de mesa de estrategia sobre construcción de rutas ferroviarias. Para 2-5 jugadores.', 'Estrategia ferrocarriles', 1, 5, 35990, 35990, 22000, 12, 3, '/assets/imgs/ticket.png', FALSE, FALSE, FALSE, 0.00, TRUE, 1),
('FG001', 'Figura Funko Pop Mario', 'Figura coleccionable de vinilo de Mario Bros. Edición limitada con detalles premium.', 'Funko Mario coleccionable', 5, 6, 19990, 16992, 12000, 30, 10, '/assets/imgs/funko_mario.png', FALSE, FALSE, TRUE, 15.00, TRUE, 1),
('AC002', 'Auriculares Gamer RGB', 'Auriculares con sonido 7.1 surround, micrófono retráctil con cancelación de ruido e iluminación RGB personalizable.', 'Auriculares 7.1 RGB', 2, 7, 45990, 45990, 30000, 18, 5, '/assets/imgs/auriculares.png', TRUE, FALSE, FALSE, 0.00, TRUE, 1),
('CO002', 'Nintendo Switch OLED', 'Consola híbrida con pantalla OLED de 7 pulgadas, 64GB de almacenamiento interno y base mejorada.', 'Switch pantalla OLED', 3, 4, 349990, 349990, 280000, 10, 3, '/assets/imgs/switch_oled.png', FALSE, TRUE, FALSE, 0.00, TRUE, 1),
('VJ002', 'God of War Ragnarök', 'Continuación épica de la saga nórdica de Kratos y Atreus. Exclusivo para PlayStation 5.', 'Aventura épica PS5', 4, 3, 69990, 69990, 55000, 22, 5, '/assets/imgs/gow.png', FALSE, TRUE, FALSE, 0.00, TRUE, 1),
('JM003', 'Pandemic', 'Juego cooperativo donde los jugadores trabajan juntos para salvar al mundo de 4 enfermedades mortales.', 'Juego cooperativo salvar mundo', 1, 8, 42990, 42990, 28000, 0, 3, '/assets/imgs/pandemic.png', FALSE, FALSE, FALSE, 0.00, FALSE, 1);

-- =============================================
-- MÓDULO 5: MÉTODOS DE PAGO
-- =============================================

INSERT INTO metodos_pago (nombre, codigo, descripcion, activo) VALUES
('Tarjeta de Crédito', 'CREDIT_CARD', 'Pago con tarjeta de crédito (Visa, Mastercard, American Express)', TRUE),
('Tarjeta de Débito', 'DEBIT_CARD', 'Pago con tarjeta de débito (RedCompra)', TRUE),
('Transferencia Bancaria', 'BANK_TRANSFER', 'Transferencia electrónica o depósito bancario', TRUE),
('Efectivo', 'CASH', 'Pago en efectivo contra entrega', TRUE),
('PayPal', 'PAYPAL', 'Pago a través de PayPal', TRUE),
('Mercado Pago', 'MERCADOPAGO', 'Pago a través de Mercado Pago', TRUE);

-- =============================================
-- MÓDULO 6: DOCUMENTOS TRIBUTARIOS
-- =============================================

INSERT INTO tipo_documento (codigo, nombre, descripcion, requiere_rut, activo) VALUES
('39', 'Boleta Electrónica', 'Boleta electrónica para ventas al público', FALSE, TRUE),
('33', 'Factura Electrónica', 'Factura electrónica para empresas', TRUE, TRUE),
('61', 'Nota de Crédito Electrónica', 'Nota de crédito electrónica', TRUE, TRUE),
('56', 'Nota de Débito Electrónica', 'Nota de débito electrónica', TRUE, TRUE);

-- =============================================
-- MÓDULO 7: TRANSPORTISTAS
-- =============================================

INSERT INTO transportistas (nombre, codigo, telefono, email, activo) VALUES
('Chilexpress', 'CHILEXPRESS', '600-600-6000', 'contacto@chilexpress.cl', TRUE),
('Starken', 'STARKEN', '600-200-0102', 'contacto@starken.cl', TRUE),
('Blue Express', 'BLUEXPRESS', '600-390-9090', 'contacto@bluex.cl', TRUE),
('Correos de Chile', 'CORREOS', '600-950-2020', 'contacto@correos.cl', TRUE);

-- Tarifas de envío
INSERT INTO tarifas_envio (nombre, region, tarifa, tiempo_estimado_dias, activo) VALUES
('Región Metropolitana - Express', 'Región Metropolitana', 5990, 1, TRUE),
('Región Metropolitana - Normal', 'Región Metropolitana', 3990, 3, TRUE),
('Regiones - Express', 'Otras Regiones', 8990, 2, TRUE),
('Regiones - Normal', 'Otras Regiones', 5990, 5, TRUE),
('Envío Gratis (Compras >$50.000)', NULL, 0, 5, TRUE);

-- =============================================
-- MÓDULO 3: CARRITOS (Ejemplos)
-- =============================================

-- Carrito activo del usuario 2
INSERT INTO carritos (usuario_id, estado) VALUES
(2, 'ACTIVO');

INSERT INTO items_carrito (carrito_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 2, 29990),
(1, 7, 1, 45990);

-- Carrito del usuario 3
INSERT INTO carritos (usuario_id, estado) VALUES
(3, 'ACTIVO');

INSERT INTO items_carrito (carrito_id, producto_id, cantidad, precio_unitario) VALUES
(2, 4, 1, 56991);

-- =============================================
-- MÓDULO 4: ÓRDENES (Ejemplos)
-- =============================================

-- Orden 1: Juan Pérez - Entregada
INSERT INTO ordenes (
    numero_orden, usuario_id, cliente_nombre, cliente_correo, cliente_telefono, cliente_run,
    direccion_envio, comuna_envio, ciudad_envio, region_envio,
    subtotal, descuento_total, envio, iva, total,
    estado, metodo_pago, estado_pago, fecha_pago
) VALUES (
    'ORD-20251110-000001', 3, 'Juan Pérez González', 'juan.perez@email.cl', '956789012', '11111111-1',
    'Av. Libertad 456', 'Viña del Mar', 'Viña del Mar', 'Región de Valparaíso',
    75622.69, 0, 5990, 14367.31, 89980,
    'ENTREGADA', 'Tarjeta de Crédito', 'APROBADO', '2025-11-10 15:35:00'
);

-- Detalles de orden 1
INSERT INTO detalle_ordenes (orden_id, producto_id, producto_codigo, producto_nombre, cantidad, precio_unitario, descuento_unitario, precio_final, subtotal, iva, total) VALUES
(1, 2, 'AC001', 'Control Xbox Series X', 1, 59990, 5999, 53991, 45370.59, 8620.41, 53991),
(1, 1, 'JM001', 'Catan', 1, 29990, 0, 29990, 25201.68, 4788.32, 29990);

-- Orden 2: María López - En tránsito
INSERT INTO ordenes (
    numero_orden, usuario_id, cliente_nombre, cliente_correo, cliente_telefono, cliente_run,
    direccion_envio, comuna_envio, ciudad_envio, region_envio,
    subtotal, descuento_total, envio, iva, total,
    estado, metodo_pago, estado_pago, fecha_pago
) VALUES (
    'ORD-20251112-000002', 4, 'María López Silva', 'maria.lopez@email.cl', '945678901', '22222222-2',
    'Calle Los Aromos 123', 'Valparaíso', 'Valparaíso', 'Región de Valparaíso',
    462176.47, 0, 8990, 89563.53, 555980,
    'EN_TRANSITO', 'Transferencia Bancaria', 'APROBADO', '2025-11-12 10:00:00'
);

INSERT INTO detalle_ordenes (orden_id, producto_id, producto_codigo, producto_nombre, cantidad, precio_unitario, descuento_unitario, precio_final, subtotal, iva, total) VALUES
(2, 3, 'CO001', 'PlayStation 5', 1, 549990, 0, 549990, 462176.47, 87813.53, 549990);

-- Orden 3: Juan Pérez - Procesando
INSERT INTO ordenes (
    numero_orden, usuario_id, cliente_nombre, cliente_correo, cliente_telefono, cliente_run,
    direccion_envio, comuna_envio, ciudad_envio, region_envio,
    subtotal, descuento_total, envio, iva, total,
    estado, metodo_pago, estado_pago
) VALUES (
    'ORD-20251113-000003', 3, 'Juan Pérez González', 'juan.perez@email.cl', '956789012', '11111111-1',
    'Av. Libertad 456', 'Viña del Mar', 'Viña del Mar', 'Región de Valparaíso',
    100815.13, 0, 5990, 19154.87, 119970,
    'PROCESANDO', 'Tarjeta de Débito', 'APROBADO'
);

INSERT INTO detalle_ordenes (orden_id, producto_id, producto_codigo, producto_nombre, cantidad, precio_unitario, descuento_unitario, precio_final, subtotal, iva, total) VALUES
(3, 7, 'AC002', 'Auriculares Gamer RGB', 2, 45990, 0, 45990, 77294.12, 14695.88, 91980),
(3, 1, 'JM001', 'Catan', 1, 29990, 0, 29990, 25201.68, 4788.32, 29990);

-- =============================================
-- MÓDULO 8: CUPONES
-- =============================================

INSERT INTO cupones (codigo, descripcion, tipo_descuento, valor_descuento, compra_minima, usos_maximos, usos_por_cliente, fecha_inicio, fecha_fin, activo) VALUES
('BIENVENIDO10', 'Descuento 10% primera compra', 'PORCENTAJE', 10.00, 0, 100, 1, '2025-11-01', '2025-12-31', TRUE),
('ENVIOGRATIS', 'Envío gratis en compras sobre $50.000', 'ENVIO_GRATIS', 0, 50000, NULL, 3, '2025-11-01', '2025-12-31', TRUE),
('CYBER25', 'CyberDay - 25% descuento', 'PORCENTAJE', 25.00, 30000, 500, 1, '2025-11-14', '2025-11-17', TRUE),
('FIJO5000', '$5.000 de descuento', 'MONTO_FIJO', 5000.00, 20000, 200, 2, '2025-11-01', '2025-11-30', TRUE);

-- =============================================
-- MÓDULO 11: LOGS DEL SISTEMA
-- =============================================

INSERT INTO logs_sistema (tipo, nivel, usuario_id, modulo, accion, descripcion, ip_address) VALUES
('SISTEMA', 'INFO', NULL, 'DATABASE', 'INICIALIZACION', 'Base de datos inicializada con datos de ejemplo', '127.0.0.1'),
('ADMIN', 'INFO', 1, 'PRODUCTOS', 'CREACION_MASIVA', 'Se crearon 10 productos iniciales', '192.168.1.100'),
('USUARIO', 'INFO', 2, 'CARRITO', 'AGREGAR_ITEM', 'Usuario agregó producto al carrito', '192.168.1.150'),
('USUARIO', 'INFO', 3, 'ORDEN', 'CREAR_ORDEN', 'Usuario creó orden ORD-20251110-000001', '192.168.1.105'),
('SISTEMA', 'INFO', NULL, 'INVENTARIO', 'ACTUALIZACION_STOCK', 'Stock actualizado por venta', '127.0.0.1');

-- =============================================
-- MÓDULO 12: MENSAJES DE CONTACTO
-- =============================================

INSERT INTO mensajes_contacto (nombre, correo, comentario, usuario_id, estado, leido, ip_address) VALUES
('Juan Pérez', 'juan.perez@email.cl', 'Cuando recibiré mi pedido? Lo hice hace 3 días y aún no tengo información de seguimiento.', 3, 'RESPONDIDO', TRUE, '192.168.1.105'),
('María López', 'maria.lopez@email.cl', 'Excelente servicio, quiero saber si tienen más stock del producto Catan. Me gustaría comprar 3 unidades más.', 4, 'RESPONDIDO', TRUE, '192.168.1.120'),
('Carlos Gómez', 'carlos.gomez@email.cl', 'Me gustaría saber si hacen envíos a regiones. Específicamente a Punta Arenas.', NULL, 'PENDIENTE', FALSE, '192.168.1.130'),
('Ana Rodríguez', 'ana.rodriguez@email.cl', 'Consulta sobre métodos de pago disponibles. Aceptan transferencia bancaria?', NULL, 'EN_REVISION', TRUE, '192.168.1.140'),
('Pedro Silva', 'pedro.silva@email.cl', 'Tienen descuentos por compras al por mayor? Necesito comprar varios juegos de mesa para un colegio.', NULL, 'PENDIENTE', FALSE, '192.168.1.150');

-- =============================================
-- FIN DE DATOS INICIALES
-- =============================================

DO $$
DECLARE
    v_usuarios INTEGER;
    v_productos INTEGER;
    v_ordenes INTEGER;
    v_categorias INTEGER;
    v_marcas INTEGER;
    v_mensajes_contacto INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_usuarios FROM usuarios;
    SELECT COUNT(*) INTO v_productos FROM productos;
    SELECT COUNT(*) INTO v_ordenes FROM ordenes;
    SELECT COUNT(*) INTO v_categorias FROM categorias;
    SELECT COUNT(*) INTO v_marcas FROM marcas;
    SELECT COUNT(*) INTO v_mensajes_contacto FROM mensajes_contacto;

    RAISE NOTICE '===================================================';
    RAISE NOTICE 'DATOS INICIALES INSERTADOS CORRECTAMENTE';
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'Usuarios: %', v_usuarios;
    RAISE NOTICE 'Categorías: %', v_categorias;
    RAISE NOTICE 'Marcas: %', v_marcas;
    RAISE NOTICE 'Productos: %', v_productos;
    RAISE NOTICE 'Órdenes: %', v_ordenes;
    RAISE NOTICE 'Mensajes de Contacto: %', v_mensajes_contacto;
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'Base de datos Level Up lista para usar';
    RAISE NOTICE '===================================================';
END $$;

