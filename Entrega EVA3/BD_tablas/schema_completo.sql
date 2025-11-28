-- =============================================
-- BASE DE DATOS COMPLETA - LEVEL UP E-COMMERCE
-- Sistema completo con lógica de negocio
-- Base de Datos: PostgreSQL (Supabase)
-- =============================================

-- =============================================
-- MÓDULO 1: GESTIÓN DE USUARIOS Y AUTENTICACIÓN
-- =============================================

-- TABLA: usuarios
CREATE TABLE usuarios (
    id BIGSERIAL PRIMARY KEY,
    run VARCHAR(12) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    correo VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    telefono VARCHAR(15),
    direccion TEXT,
    comuna VARCHAR(100),
    ciudad VARCHAR(100),
    region VARCHAR(100),
    codigo_postal VARCHAR(10),
    fecha_nacimiento DATE,
    rol VARCHAR(20) NOT NULL DEFAULT 'CLIENTE',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    verificado BOOLEAN NOT NULL DEFAULT FALSE,
    token_verificacion VARCHAR(255),
    ultimo_acceso TIMESTAMP,
    intentos_fallidos INTEGER DEFAULT 0,
    bloqueado_hasta TIMESTAMP,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_rol CHECK (rol IN ('CLIENTE', 'ADMIN', 'VENDEDOR', 'BODEGUERO'))
);

-- Índices usuarios
CREATE INDEX IF NOT EXISTS idx_usuarios_correo ON usuarios(correo);
CREATE INDEX IF NOT EXISTS idx_usuarios_run ON usuarios(run);
CREATE INDEX IF NOT EXISTS idx_usuarios_rol ON usuarios(rol);
CREATE INDEX IF NOT EXISTS idx_usuarios_activo ON usuarios(activo);

COMMENT ON TABLE usuarios IS 'Usuarios del sistema con roles y datos completos';

-- =============================================
-- MÓDULO 2: CATÁLOGO DE PRODUCTOS E INVENTARIO
-- =============================================

-- TABLA: categorias
CREATE TABLE categorias (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    slug VARCHAR(100) UNIQUE NOT NULL,
    imagen_url VARCHAR(500),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    orden INTEGER DEFAULT 0,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_categorias_slug ON categorias(slug);
CREATE INDEX IF NOT EXISTS idx_categorias_activo ON categorias(activo);

-- TABLA: marcas
CREATE TABLE marcas (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    logo_url VARCHAR(500),
    sitio_web VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- TABLA: productos
CREATE TABLE productos (
    id BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    descripcion_corta VARCHAR(500),
    categoria_id BIGINT NOT NULL,
    marca_id BIGINT,
    precio_base DECIMAL(12,2) NOT NULL CHECK (precio_base >= 0),
    precio_venta DECIMAL(12,2) NOT NULL CHECK (precio_venta >= 0),
    costo DECIMAL(12,2) CHECK (costo >= 0),
    iva DECIMAL(5,2) DEFAULT 19.00,
    stock_actual INTEGER NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo INTEGER DEFAULT 5,
    stock_maximo INTEGER DEFAULT 1000,
    imagen_principal VARCHAR(500),
    peso_gramos INTEGER,
    dimensiones VARCHAR(100),
    destacado BOOLEAN NOT NULL DEFAULT FALSE,
    nuevo BOOLEAN NOT NULL DEFAULT FALSE,
    oferta BOOLEAN NOT NULL DEFAULT FALSE,
    descuento_porcentaje DECIMAL(5,2) DEFAULT 0.00 CHECK (descuento_porcentaje >= 0 AND descuento_porcentaje <= 100),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    creado_por BIGINT,

    CONSTRAINT fk_productos_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categorias(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_productos_marca
        FOREIGN KEY (marca_id)
        REFERENCES marcas(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_productos_creador
        FOREIGN KEY (creado_por)
        REFERENCES usuarios(id)
        ON DELETE SET NULL
);

-- Índices productos
CREATE INDEX IF NOT EXISTS idx_productos_codigo ON productos(codigo);
CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_productos_marca ON productos(marca_id);
CREATE INDEX IF NOT EXISTS idx_productos_activo ON productos(activo);
CREATE INDEX IF NOT EXISTS idx_productos_destacado ON productos(destacado);
CREATE INDEX IF NOT EXISTS idx_productos_nombre ON productos USING gin(to_tsvector('spanish', nombre));

-- TABLA: imagenes_producto
CREATE TABLE imagenes_producto (
    id BIGSERIAL PRIMARY KEY,
    producto_id BIGINT NOT NULL,
    url VARCHAR(500) NOT NULL,
    orden INTEGER DEFAULT 0,
    es_principal BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_imagenes_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_imagenes_producto ON imagenes_producto(producto_id);

-- TABLA: movimientos_inventario
CREATE TABLE movimientos_inventario (
    id BIGSERIAL PRIMARY KEY,
    producto_id BIGINT NOT NULL,
    tipo_movimiento VARCHAR(20) NOT NULL,
    cantidad INTEGER NOT NULL,
    stock_anterior INTEGER NOT NULL,
    stock_nuevo INTEGER NOT NULL,
    motivo TEXT,
    referencia_id BIGINT,
    referencia_tipo VARCHAR(50),
    usuario_id BIGINT,
    fecha_movimiento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_movimiento_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_movimiento_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_tipo_movimiento CHECK (tipo_movimiento IN (
        'COMPRA', 'VENTA', 'DEVOLUCION', 'AJUSTE', 'MERMA', 'INVENTARIO_INICIAL'
    ))
);

CREATE INDEX IF NOT EXISTS idx_movimientos_producto ON movimientos_inventario(producto_id);
CREATE INDEX IF NOT EXISTS idx_movimientos_fecha ON movimientos_inventario(fecha_movimiento DESC);
CREATE INDEX IF NOT EXISTS idx_movimientos_tipo ON movimientos_inventario(tipo_movimiento);

-- =============================================
-- MÓDULO 3: CARRITOS DE COMPRA
-- =============================================

-- TABLA: carritos
CREATE TABLE carritos (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT,
    session_id VARCHAR(255),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP,

    CONSTRAINT fk_carrito_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_carrito_estado CHECK (estado IN ('ACTIVO', 'CONVERTIDO', 'ABANDONADO', 'EXPIRADO'))
);

CREATE INDEX IF NOT EXISTS idx_carritos_usuario ON carritos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_carritos_session ON carritos(session_id);
CREATE INDEX IF NOT EXISTS idx_carritos_estado ON carritos(estado);

-- TABLA: items_carrito
CREATE TABLE items_carrito (
    id BIGSERIAL PRIMARY KEY,
    carrito_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(12,2) NOT NULL,
    fecha_agregado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_item_carrito
        FOREIGN KEY (carrito_id)
        REFERENCES carritos(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_item_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(id)
        ON DELETE CASCADE,

    CONSTRAINT uk_carrito_producto UNIQUE (carrito_id, producto_id)
);

CREATE INDEX IF NOT EXISTS idx_items_carrito ON items_carrito(carrito_id);
CREATE INDEX IF NOT EXISTS idx_items_producto ON items_carrito(producto_id);

-- =============================================
-- MÓDULO 4: ÓRDENES DE COMPRA
-- =============================================

-- TABLA: ordenes
CREATE TABLE ordenes (
    id BIGSERIAL PRIMARY KEY,
    numero_orden VARCHAR(20) UNIQUE NOT NULL,
    usuario_id BIGINT NOT NULL,
    carrito_id BIGINT,

    -- Información del cliente (snapshot)
    cliente_nombre VARCHAR(150) NOT NULL,
    cliente_correo VARCHAR(255) NOT NULL,
    cliente_telefono VARCHAR(15),
    cliente_run VARCHAR(12),

    -- Dirección de envío
    direccion_envio TEXT NOT NULL,
    comuna_envio VARCHAR(100),
    ciudad_envio VARCHAR(100),
    region_envio VARCHAR(100),
    codigo_postal_envio VARCHAR(10),

    -- Totales
    subtotal DECIMAL(12,2) NOT NULL CHECK (subtotal >= 0),
    descuento_total DECIMAL(12,2) DEFAULT 0.00,
    envio DECIMAL(12,2) DEFAULT 0.00,
    iva DECIMAL(12,2) NOT NULL,
    total DECIMAL(12,2) NOT NULL CHECK (total >= 0),

    -- Estado y fechas
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    metodo_pago VARCHAR(50),
    estado_pago VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    fecha_pago TIMESTAMP,

    notas_cliente TEXT,
    notas_internas TEXT,

    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_completada TIMESTAMP,
    fecha_cancelada TIMESTAMP,

    CONSTRAINT fk_orden_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_orden_carrito
        FOREIGN KEY (carrito_id)
        REFERENCES carritos(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_estado_orden CHECK (estado IN (
        'PENDIENTE', 'CONFIRMADA', 'PROCESANDO', 'EMPACADA',
        'EN_TRANSITO', 'ENTREGADA', 'CANCELADA', 'DEVUELTA'
    )),

    CONSTRAINT chk_estado_pago CHECK (estado_pago IN (
        'PENDIENTE', 'PROCESANDO', 'APROBADO', 'RECHAZADO', 'REEMBOLSADO'
    ))
);

-- Índices ordenes
CREATE INDEX IF NOT EXISTS idx_ordenes_numero ON ordenes(numero_orden);
CREATE INDEX IF NOT EXISTS idx_ordenes_usuario ON ordenes(usuario_id);
CREATE INDEX IF NOT EXISTS idx_ordenes_estado ON ordenes(estado);
CREATE INDEX IF NOT EXISTS idx_ordenes_estado_pago ON ordenes(estado_pago);
CREATE INDEX IF NOT EXISTS idx_ordenes_fecha ON ordenes(fecha_creacion DESC);

-- TABLA: detalle_ordenes
CREATE TABLE detalle_ordenes (
    id BIGSERIAL PRIMARY KEY,
    orden_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,

    -- Snapshot del producto al momento de la compra
    producto_codigo VARCHAR(50) NOT NULL,
    producto_nombre VARCHAR(200) NOT NULL,
    producto_descripcion TEXT,

    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(12,2) NOT NULL,
    descuento_unitario DECIMAL(12,2) DEFAULT 0.00,
    precio_final DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    iva DECIMAL(12,2) NOT NULL,
    total DECIMAL(12,2) NOT NULL,

    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_detalle_orden
        FOREIGN KEY (orden_id)
        REFERENCES ordenes(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_detalle_orden ON detalle_ordenes(orden_id);
CREATE INDEX IF NOT EXISTS idx_detalle_producto ON detalle_ordenes(producto_id);

-- TABLA: seguimiento_orden
CREATE TABLE seguimiento_orden (
    id BIGSERIAL PRIMARY KEY,
    orden_id BIGINT NOT NULL,
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20) NOT NULL,
    comentario TEXT,
    usuario_id BIGINT,
    fecha_cambio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_seguimiento_orden
        FOREIGN KEY (orden_id)
        REFERENCES ordenes(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_seguimiento_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_seguimiento_orden ON seguimiento_orden(orden_id);
CREATE INDEX IF NOT EXISTS idx_seguimiento_orden_fecha ON seguimiento_orden(fecha_cambio DESC);

-- =============================================
-- MÓDULO 5: PAGOS Y TRANSACCIONES
-- =============================================

-- TABLA: metodos_pago
CREATE TABLE metodos_pago (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    requiere_datos_bancarios BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- TABLA: pagos
CREATE TABLE pagos (
    id BIGSERIAL PRIMARY KEY,
    orden_id BIGINT NOT NULL,
    metodo_pago_id BIGINT NOT NULL,

    monto DECIMAL(12,2) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',

    -- Información de pago externo
    transaccion_id VARCHAR(255),
    autorizacion_codigo VARCHAR(255),
    referencia_externa VARCHAR(255),

    -- Datos adicionales
    datos_pago JSONB,
    respuesta_gateway JSONB,

    fecha_pago TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_confirmacion TIMESTAMP,

    CONSTRAINT fk_pago_orden
        FOREIGN KEY (orden_id)
        REFERENCES ordenes(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_pago_metodo
        FOREIGN KEY (metodo_pago_id)
        REFERENCES metodos_pago(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_pago_estado CHECK (estado IN (
        'PENDIENTE', 'PROCESANDO', 'APROBADO', 'RECHAZADO', 'REEMBOLSADO', 'ERROR'
    ))
);

CREATE INDEX IF NOT EXISTS idx_pagos_orden ON pagos(orden_id);
CREATE INDEX IF NOT EXISTS idx_pagos_estado ON pagos(estado);
CREATE INDEX IF NOT EXISTS idx_pagos_transaccion ON pagos(transaccion_id);

-- =============================================
-- MÓDULO 6: DOCUMENTOS TRIBUTARIOS (BOLETAS/FACTURAS)
-- =============================================

-- TABLA: tipo_documento
CREATE TABLE tipo_documento (
    id BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    requiere_rut BOOLEAN DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- TABLA: documentos_tributarios
CREATE TABLE documentos_tributarios (
    id BIGSERIAL PRIMARY KEY,
    tipo_documento_id BIGINT NOT NULL,
    orden_id BIGINT NOT NULL,

    -- Numeración
    numero_documento VARCHAR(20) UNIQUE NOT NULL,
    serie VARCHAR(10),

    -- Datos del emisor (empresa)
    emisor_razon_social VARCHAR(255) NOT NULL,
    emisor_rut VARCHAR(12) NOT NULL,
    emisor_direccion TEXT,
    emisor_giro VARCHAR(255),

    -- Datos del receptor (cliente)
    receptor_nombre VARCHAR(255) NOT NULL,
    receptor_rut VARCHAR(12),
    receptor_direccion TEXT,

    -- Montos
    neto DECIMAL(12,2),
    iva DECIMAL(12,2),
    exento DECIMAL(12,2) DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL,

    -- Estado
    estado VARCHAR(20) NOT NULL DEFAULT 'EMITIDA',
    fecha_emision TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_anulacion TIMESTAMP,
    motivo_anulacion TEXT,

    -- Datos SII (Chile)
    folio_sii VARCHAR(50),
    fecha_envio_sii TIMESTAMP,
    estado_sii VARCHAR(50),
    track_id_sii VARCHAR(50),

    -- XML y PDF
    xml_documento TEXT,
    pdf_url VARCHAR(500),

    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_documento_tipo
        FOREIGN KEY (tipo_documento_id)
        REFERENCES tipo_documento(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_documento_orden
        FOREIGN KEY (orden_id)
        REFERENCES ordenes(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_documento_estado CHECK (estado IN (
        'EMITIDA', 'ENVIADA_SII', 'ACEPTADA', 'RECHAZADA', 'ANULADA'
    ))
);

CREATE INDEX IF NOT EXISTS idx_documentos_tipo ON documentos_tributarios(tipo_documento_id);
CREATE INDEX IF NOT EXISTS idx_documentos_orden ON documentos_tributarios(orden_id);
CREATE INDEX IF NOT EXISTS idx_documentos_numero ON documentos_tributarios(numero_documento);
CREATE INDEX IF NOT EXISTS idx_documentos_fecha ON documentos_tributarios(fecha_emision DESC);

-- TABLA: detalle_documento
CREATE TABLE detalle_documento (
    id BIGSERIAL PRIMARY KEY,
    documento_id BIGINT NOT NULL,

    linea INTEGER NOT NULL,
    codigo_producto VARCHAR(50),
    descripcion VARCHAR(500) NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    descuento DECIMAL(12,2) DEFAULT 0.00,
    recargo DECIMAL(12,2) DEFAULT 0.00,
    monto_neto DECIMAL(12,2),
    monto_exento DECIMAL(12,2) DEFAULT 0.00,
    monto_iva DECIMAL(12,2),
    total_linea DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_detalle_documento
        FOREIGN KEY (documento_id)
        REFERENCES documentos_tributarios(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_detalle_documento ON detalle_documento(documento_id);

-- =============================================
-- MÓDULO 7: ENVÍOS Y DESPACHOS
-- =============================================

-- TABLA: transportistas
CREATE TABLE transportistas (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(255),
    sitio_web VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- TABLA: tarifas_envio
CREATE TABLE tarifas_envio (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    region VARCHAR(100),
    comuna VARCHAR(100),
    peso_minimo_gramos INTEGER,
    peso_maximo_gramos INTEGER,
    tarifa DECIMAL(12,2) NOT NULL,
    tiempo_estimado_dias INTEGER,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- TABLA: envios
CREATE TABLE envios (
    id BIGSERIAL PRIMARY KEY,
    orden_id BIGINT NOT NULL UNIQUE,
    transportista_id BIGINT,

    numero_seguimiento VARCHAR(100),
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',

    direccion_retiro TEXT,
    direccion_destino TEXT NOT NULL,
    contacto_nombre VARCHAR(150),
    contacto_telefono VARCHAR(15),

    peso_total_gramos INTEGER,
    bultos INTEGER DEFAULT 1,

    fecha_despacho TIMESTAMP,
    fecha_entrega_estimada TIMESTAMP,
    fecha_entrega_real TIMESTAMP,

    costo_envio DECIMAL(12,2),

    notas TEXT,

    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_envio_orden
        FOREIGN KEY (orden_id)
        REFERENCES ordenes(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_envio_transportista
        FOREIGN KEY (transportista_id)
        REFERENCES transportistas(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_envio_estado CHECK (estado IN (
        'PENDIENTE', 'PREPARANDO', 'DESPACHADO', 'EN_TRANSITO',
        'EN_REPARTO', 'ENTREGADO', 'DEVUELTO', 'EXTRAVIADO'
    ))
);

CREATE INDEX IF NOT EXISTS idx_envios_orden ON envios(orden_id);
CREATE INDEX IF NOT EXISTS idx_envios_seguimiento ON envios(numero_seguimiento);
CREATE INDEX IF NOT EXISTS idx_envios_estado ON envios(estado);

-- TABLA: seguimiento_envio
CREATE TABLE seguimiento_envio (
    id BIGSERIAL PRIMARY KEY,
    envio_id BIGINT NOT NULL,

    estado VARCHAR(20) NOT NULL,
    ubicacion VARCHAR(255),
    descripcion TEXT,
    fecha_evento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_seguimiento_envio
        FOREIGN KEY (envio_id)
        REFERENCES envios(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_seguimiento_envio ON seguimiento_envio(envio_id);
CREATE INDEX IF NOT EXISTS idx_seguimiento_envio_fecha ON seguimiento_envio(fecha_evento DESC);

-- =============================================
-- MÓDULO 8: CUPONES Y PROMOCIONES
-- =============================================

-- TABLA: cupones
CREATE TABLE cupones (
    id BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,

    tipo_descuento VARCHAR(20) NOT NULL,
    valor_descuento DECIMAL(12,2) NOT NULL,
    descuento_maximo DECIMAL(12,2),
    compra_minima DECIMAL(12,2),

    usos_maximos INTEGER,
    usos_por_cliente INTEGER DEFAULT 1,
    usos_totales INTEGER DEFAULT 0,

    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,

    activo BOOLEAN NOT NULL DEFAULT TRUE,

    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_tipo_descuento CHECK (tipo_descuento IN ('PORCENTAJE', 'MONTO_FIJO', 'ENVIO_GRATIS'))
);

CREATE INDEX IF NOT EXISTS idx_cupones_codigo ON cupones(codigo);
CREATE INDEX IF NOT EXISTS idx_cupones_activo ON cupones(activo);
CREATE INDEX IF NOT EXISTS idx_cupones_fechas ON cupones(fecha_inicio, fecha_fin);

-- TABLA: uso_cupones
CREATE TABLE uso_cupones (
    id BIGSERIAL PRIMARY KEY,
    cupon_id BIGINT NOT NULL,
    orden_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,

    descuento_aplicado DECIMAL(12,2) NOT NULL,
    fecha_uso TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_uso_cupon
        FOREIGN KEY (cupon_id)
        REFERENCES cupones(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_uso_orden
        FOREIGN KEY (orden_id)
        REFERENCES ordenes(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_uso_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_uso_cupones_cupon ON uso_cupones(cupon_id);
CREATE INDEX IF NOT EXISTS idx_uso_cupones_orden ON uso_cupones(orden_id);
CREATE INDEX IF NOT EXISTS idx_uso_cupones_usuario ON uso_cupones(usuario_id);

-- =============================================
-- MÓDULO 9: REVIEWS Y CALIFICACIONES
-- =============================================

-- TABLA: reviews_productos
CREATE TABLE reviews_productos (
    id BIGSERIAL PRIMARY KEY,
    producto_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,
    orden_id BIGINT,

    calificacion INTEGER NOT NULL CHECK (calificacion >= 1 AND calificacion <= 5),
    titulo VARCHAR(200),
    comentario TEXT,

    verificada BOOLEAN DEFAULT FALSE,
    aprobada BOOLEAN DEFAULT TRUE,

    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_review_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_review_orden
        FOREIGN KEY (orden_id)
        REFERENCES ordenes(id)
        ON DELETE SET NULL,

    CONSTRAINT uk_review_usuario_producto UNIQUE (usuario_id, producto_id, orden_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_producto ON reviews_productos(producto_id);
CREATE INDEX IF NOT EXISTS idx_reviews_usuario ON reviews_productos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_reviews_calificacion ON reviews_productos(calificacion);

-- =============================================
-- MÓDULO 10: DEVOLUCIONES Y REEMBOLSOS
-- =============================================

-- TABLA: devoluciones
CREATE TABLE devoluciones (
    id BIGSERIAL PRIMARY KEY,
    orden_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,

    numero_devolucion VARCHAR(20) UNIQUE NOT NULL,

    motivo VARCHAR(100) NOT NULL,
    descripcion TEXT,

    monto_devolucion DECIMAL(12,2) NOT NULL,

    estado VARCHAR(20) NOT NULL DEFAULT 'SOLICITADA',

    fecha_solicitud TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_aprobacion TIMESTAMP,
    fecha_recepcion TIMESTAMP,
    fecha_reembolso TIMESTAMP,

    aprobada_por BIGINT,
    notas_admin TEXT,

    CONSTRAINT fk_devolucion_orden
        FOREIGN KEY (orden_id)
        REFERENCES ordenes(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_devolucion_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_devolucion_aprobador
        FOREIGN KEY (aprobada_por)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_devolucion_estado CHECK (estado IN (
        'SOLICITADA', 'EN_REVISION', 'APROBADA', 'RECHAZADA',
        'PRODUCTO_RECIBIDO', 'REEMBOLSADA', 'CANCELADA'
    ))
);

CREATE INDEX IF NOT EXISTS idx_devoluciones_orden ON devoluciones(orden_id);
CREATE INDEX IF NOT EXISTS idx_devoluciones_usuario ON devoluciones(usuario_id);
CREATE INDEX IF NOT EXISTS idx_devoluciones_estado ON devoluciones(estado);

-- TABLA: items_devolucion
CREATE TABLE items_devolucion (
    id BIGSERIAL PRIMARY KEY,
    devolucion_id BIGINT NOT NULL,
    detalle_orden_id BIGINT NOT NULL,

    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    motivo_item VARCHAR(200),

    CONSTRAINT fk_item_devolucion
        FOREIGN KEY (devolucion_id)
        REFERENCES devoluciones(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_item_detalle
        FOREIGN KEY (detalle_orden_id)
        REFERENCES detalle_ordenes(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_items_devolucion ON items_devolucion(devolucion_id);

-- =============================================
-- MÓDULO 11: AUDITORÍA Y LOGS
-- =============================================

-- TABLA: logs_sistema
CREATE TABLE logs_sistema (
    id BIGSERIAL PRIMARY KEY,
    tipo VARCHAR(20) NOT NULL,
    nivel VARCHAR(20) NOT NULL DEFAULT 'INFO',

    usuario_id BIGINT,

    modulo VARCHAR(100),
    accion VARCHAR(100) NOT NULL,
    descripcion TEXT,

    entidad_tipo VARCHAR(50),
    entidad_id BIGINT,

    datos_anteriores JSONB,
    datos_nuevos JSONB,

    ip_address VARCHAR(45),
    user_agent TEXT,

    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_log_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_log_tipo CHECK (tipo IN ('USUARIO', 'ADMIN', 'SISTEMA', 'ERROR', 'SEGURIDAD')),
    CONSTRAINT chk_log_nivel CHECK (nivel IN ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'))
);

CREATE INDEX IF NOT EXISTS idx_logs_tipo ON logs_sistema(tipo);
CREATE INDEX IF NOT EXISTS idx_logs_nivel ON logs_sistema(nivel);
CREATE INDEX IF NOT EXISTS idx_logs_usuario ON logs_sistema(usuario_id);
CREATE INDEX IF NOT EXISTS idx_logs_fecha ON logs_sistema(fecha DESC);
CREATE INDEX IF NOT EXISTS idx_logs_entidad ON logs_sistema(entidad_tipo, entidad_id);

-- =============================================
-- MÓDULO 12: MENSAJES DE CONTACTO
-- =============================================

-- TABLA: mensajes_contacto
CREATE TABLE mensajes_contacto (
    id BIGSERIAL PRIMARY KEY,

    -- Datos del remitente
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(255) NOT NULL,

    -- Contenido del mensaje
    comentario TEXT NOT NULL,

    -- Usuario asociado (si está autenticado)
    usuario_id BIGINT,

    -- Estado del mensaje
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    leido BOOLEAN NOT NULL DEFAULT FALSE,

    -- Respuesta
    respuesta TEXT,
    respondido_por BIGINT,
    fecha_respuesta TIMESTAMP,

    -- Metadata
    ip_address VARCHAR(45),
    user_agent TEXT,

    -- Auditoría
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Keys
    CONSTRAINT fk_mensaje_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_mensaje_respondedor
        FOREIGN KEY (respondido_por)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    -- Constraints de validación
    CONSTRAINT chk_mensaje_estado CHECK (estado IN ('PENDIENTE', 'EN_REVISION', 'RESPONDIDO', 'ARCHIVADO', 'SPAM')),
    CONSTRAINT chk_comentario_longitud CHECK (char_length(comentario) <= 500)
);

-- Índices para mensajes_contacto
CREATE INDEX IF NOT EXISTS idx_mensajes_correo ON mensajes_contacto(correo);
CREATE INDEX IF NOT EXISTS idx_mensajes_usuario ON mensajes_contacto(usuario_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_estado ON mensajes_contacto(estado);
CREATE INDEX IF NOT EXISTS idx_mensajes_leido ON mensajes_contacto(leido);
CREATE INDEX IF NOT EXISTS idx_mensajes_fecha ON mensajes_contacto(fecha_creacion DESC);

COMMENT ON TABLE mensajes_contacto IS 'Mensajes enviados desde el formulario de contacto de la página web';
COMMENT ON COLUMN mensajes_contacto.nombre IS 'Nombre del remitente (máximo 100 caracteres)';
COMMENT ON COLUMN mensajes_contacto.correo IS 'Email de contacto del remitente';
COMMENT ON COLUMN mensajes_contacto.comentario IS 'Mensaje o comentario (máximo 500 caracteres)';
COMMENT ON COLUMN mensajes_contacto.usuario_id IS 'ID del usuario si estaba autenticado al enviar el mensaje';
COMMENT ON COLUMN mensajes_contacto.estado IS 'Estado del mensaje: PENDIENTE, EN_REVISION, RESPONDIDO, ARCHIVADO, SPAM';

-- =============================================
-- FUNCIONES Y TRIGGERS
-- =============================================

-- Función para actualizar fecha_actualizacion
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas relevantes
CREATE TRIGGER trigger_usuarios_actualizacion
    BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trigger_productos_actualizacion
    BEFORE UPDATE ON productos
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trigger_ordenes_actualizacion
    BEFORE UPDATE ON ordenes
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trigger_carritos_actualizacion
    BEFORE UPDATE ON carritos
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trigger_items_carrito_actualizacion
    BEFORE UPDATE ON items_carrito
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trigger_mensajes_contacto_actualizacion
    BEFORE UPDATE ON mensajes_contacto
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

-- Función para generar número de orden
CREATE OR REPLACE FUNCTION generar_numero_orden()
RETURNS TRIGGER AS $$
BEGIN
    NEW.numero_orden = 'ORD-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD') || '-' ||
                       LPAD(nextval('seq_numero_orden')::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE seq_numero_orden;

CREATE TRIGGER trigger_generar_numero_orden
    BEFORE INSERT ON ordenes
    FOR EACH ROW
    WHEN (NEW.numero_orden IS NULL)
    EXECUTE FUNCTION generar_numero_orden();

-- Función para registrar cambios de estado en órdenes
CREATE OR REPLACE FUNCTION registrar_cambio_estado_orden()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.estado IS DISTINCT FROM NEW.estado THEN
        INSERT INTO seguimiento_orden (orden_id, estado_anterior, estado_nuevo, comentario)
        VALUES (NEW.id, OLD.estado, NEW.estado, 'Cambio automático de estado');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_seguimiento_orden
    AFTER UPDATE ON ordenes
    FOR EACH ROW
    EXECUTE FUNCTION registrar_cambio_estado_orden();

-- Función para actualizar stock al crear detalle de orden
CREATE OR REPLACE FUNCTION actualizar_stock_venta()
RETURNS TRIGGER AS $$
DECLARE
    v_stock_anterior INTEGER;
    v_stock_nuevo INTEGER;
BEGIN
    -- Obtener stock actual
    SELECT stock_actual INTO v_stock_anterior
    FROM productos
    WHERE id = NEW.producto_id;

    -- Calcular nuevo stock
    v_stock_nuevo := v_stock_anterior - NEW.cantidad;

    -- Actualizar stock del producto
    UPDATE productos
    SET stock_actual = v_stock_nuevo
    WHERE id = NEW.producto_id;

    -- Registrar movimiento de inventario
    INSERT INTO movimientos_inventario (
        producto_id, tipo_movimiento, cantidad, stock_anterior, stock_nuevo,
        motivo, referencia_id, referencia_tipo
    ) VALUES (
        NEW.producto_id, 'VENTA', -NEW.cantidad, v_stock_anterior, v_stock_nuevo,
        'Venta - Orden #' || NEW.orden_id, NEW.orden_id, 'ORDEN'
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_stock_venta
    AFTER INSERT ON detalle_ordenes
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_stock_venta();

-- =============================================
-- VISTAS ÚTILES
-- =============================================

-- Vista de productos con información completa
CREATE OR REPLACE VIEW v_productos_completos AS
SELECT
    p.id,
    p.codigo,
    p.nombre,
    p.descripcion_corta,
    p.descripcion,
    c.nombre as categoria,
    c.slug as categoria_slug,
    m.nombre as marca,
    p.precio_base,
    p.precio_venta,
    p.descuento_porcentaje,
    ROUND(p.precio_venta * (1 - p.descuento_porcentaje / 100), 0) as precio_final,
    p.stock_actual,
    p.stock_minimo,
    p.imagen_principal,
    p.destacado,
    p.nuevo,
    p.oferta,
    p.activo,
    COALESCE(AVG(r.calificacion), 0) as calificacion_promedio,
    COUNT(DISTINCT r.id) as total_reviews
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN marcas m ON p.marca_id = m.id
LEFT JOIN reviews_productos r ON p.id = r.producto_id AND r.aprobada = TRUE
GROUP BY p.id, c.nombre, c.slug, m.nombre;

-- Vista de órdenes con totales
CREATE OR REPLACE VIEW v_ordenes_resumen AS
SELECT
    o.id,
    o.numero_orden,
    o.usuario_id,
    u.nombre || ' ' || u.apellidos as cliente,
    o.cliente_correo,
    o.estado,
    o.estado_pago,
    o.total,
    o.fecha_creacion,
    COUNT(d.id) as total_items,
    SUM(d.cantidad) as total_productos,
    e.estado as estado_envio,
    e.numero_seguimiento
FROM ordenes o
LEFT JOIN usuarios u ON o.usuario_id = u.id
LEFT JOIN detalle_ordenes d ON o.id = d.orden_id
LEFT JOIN envios e ON o.id = e.orden_id
GROUP BY o.id, u.nombre, u.apellidos, e.estado, e.numero_seguimiento;

-- =============================================
-- FIN DE SCHEMA
-- =============================================

COMMENT ON DATABASE postgres IS 'Base de datos completa Level Up E-commerce con lógica de negocio';

