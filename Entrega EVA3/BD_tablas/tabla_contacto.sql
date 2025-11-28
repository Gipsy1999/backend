-- =============================================
-- TABLA MENSAJES_CONTACTO - Standalone
-- Puede ejecutarse independientemente si ya tienes el schema
-- =============================================

-- Crear tabla si no existe
CREATE TABLE IF NOT EXISTS mensajes_contacto (
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

-- Índices
CREATE INDEX IF NOT EXISTS idx_mensajes_correo ON mensajes_contacto(correo);
CREATE INDEX IF NOT EXISTS idx_mensajes_usuario ON mensajes_contacto(usuario_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_estado ON mensajes_contacto(estado);
CREATE INDEX IF NOT EXISTS idx_mensajes_leido ON mensajes_contacto(leido);
CREATE INDEX IF NOT EXISTS idx_mensajes_fecha ON mensajes_contacto(fecha_creacion DESC);

-- Trigger para actualizar fecha_actualizacion
CREATE OR REPLACE FUNCTION actualizar_fecha_mensaje()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_mensajes_contacto_actualizacion
    BEFORE UPDATE ON mensajes_contacto
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_mensaje();

-- Comentarios
COMMENT ON TABLE mensajes_contacto IS 'Mensajes enviados desde el formulario de contacto de la página web';
COMMENT ON COLUMN mensajes_contacto.nombre IS 'Nombre del remitente (máximo 100 caracteres)';
COMMENT ON COLUMN mensajes_contacto.correo IS 'Email de contacto del remitente';
COMMENT ON COLUMN mensajes_contacto.comentario IS 'Mensaje o comentario (máximo 500 caracteres)';
COMMENT ON COLUMN mensajes_contacto.usuario_id IS 'ID del usuario si estaba autenticado al enviar el mensaje';

-- =============================================
-- DATOS DE EJEMPLO
-- =============================================

INSERT INTO mensajes_contacto (nombre, correo, comentario, usuario_id, estado, leido, ip_address) VALUES
('Juan Pérez', 'juan.perez@email.cl', '¿Cuándo recibiré mi pedido? Lo hice hace 3 días.', 3, 'RESPONDIDO', TRUE, '192.168.1.105'),
('María López', 'maria.lopez@email.cl', 'Excelente servicio, quiero saber si tienen más stock del producto Catan.', 4, 'RESPONDIDO', TRUE, '192.168.1.120'),
('Carlos Gómez', 'carlos.gomez@email.cl', 'Me gustaría saber si hacen envíos a regiones.', NULL, 'PENDIENTE', FALSE, '192.168.1.130'),
('Ana Rodríguez', 'ana.rodriguez@email.cl', 'Consulta sobre métodos de pago disponibles.', NULL, 'EN_REVISION', TRUE, '192.168.1.140'),
('Pedro Silva', 'pedro.silva@email.cl', '¿Tienen descuentos por compras al por mayor?', NULL, 'PENDIENTE', FALSE, '192.168.1.150');

-- =============================================
-- FUNCIONES ÚTILES PARA CONTACTO
-- =============================================

-- Función: Obtener mensajes pendientes
CREATE OR REPLACE FUNCTION obtener_mensajes_pendientes()
RETURNS TABLE(
    id BIGINT,
    nombre VARCHAR,
    correo VARCHAR,
    comentario TEXT,
    fecha_creacion TIMESTAMP
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        mc.id,
        mc.nombre,
        mc.correo,
        mc.comentario,
        mc.fecha_creacion
    FROM mensajes_contacto mc
    WHERE mc.estado = 'PENDIENTE' AND mc.leido = FALSE
    ORDER BY mc.fecha_creacion DESC;
END;
$$;

-- Función: Marcar mensaje como leído
CREATE OR REPLACE FUNCTION marcar_mensaje_leido(p_mensaje_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE mensajes_contacto
    SET leido = TRUE,
        estado = CASE
            WHEN estado = 'PENDIENTE' THEN 'EN_REVISION'
            ELSE estado
        END
    WHERE id = p_mensaje_id;

    RETURN FOUND;
END;
$$;

-- Función: Responder mensaje
CREATE OR REPLACE FUNCTION responder_mensaje_contacto(
    p_mensaje_id BIGINT,
    p_respuesta TEXT,
    p_usuario_admin_id BIGINT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE mensajes_contacto
    SET estado = 'RESPONDIDO',
        leido = TRUE,
        respuesta = p_respuesta,
        respondido_por = p_usuario_admin_id,
        fecha_respuesta = CURRENT_TIMESTAMP
    WHERE id = p_mensaje_id;

    -- Registrar en logs
    INSERT INTO logs_sistema (tipo, nivel, usuario_id, modulo, accion, descripcion, entidad_tipo, entidad_id)
    VALUES (
        'ADMIN', 'INFO', p_usuario_admin_id, 'CONTACTO', 'RESPONDER_MENSAJE',
        'Mensaje de contacto respondido',
        'MENSAJE_CONTACTO', p_mensaje_id
    );

    RETURN FOUND;
END;
$$;

-- =============================================
-- VISTA ÚTIL
-- =============================================

CREATE OR REPLACE VIEW v_mensajes_contacto_resumen AS
SELECT
    mc.id,
    mc.nombre,
    mc.correo,
    mc.comentario,
    mc.estado,
    mc.leido,
    mc.fecha_creacion,
    u.nombre || ' ' || u.apellidos as usuario_nombre,
    mc.respuesta,
    admin.nombre || ' ' || admin.apellidos as respondido_por_nombre,
    mc.fecha_respuesta
FROM mensajes_contacto mc
LEFT JOIN usuarios u ON mc.usuario_id = u.id
LEFT JOIN usuarios admin ON mc.respondido_por = admin.id
ORDER BY mc.fecha_creacion DESC;

-- =============================================
-- CONSULTAS ÚTILES
-- =============================================

-- Ver mensajes pendientes
-- SELECT * FROM obtener_mensajes_pendientes();

-- Ver todos los mensajes con resumen
-- SELECT * FROM v_mensajes_contacto_resumen;

-- Marcar mensaje como leído
-- SELECT marcar_mensaje_leido(1);

-- Responder mensaje
-- SELECT responder_mensaje_contacto(1, 'Gracias por contactarnos...', 1);

-- Estadísticas de mensajes
-- SELECT
--     estado,
--     COUNT(*) as total,
--     COUNT(*) FILTER (WHERE leido = TRUE) as leidos,
--     COUNT(*) FILTER (WHERE leido = FALSE) as no_leidos
-- FROM mensajes_contacto
-- GROUP BY estado;

RAISE NOTICE 'Tabla mensajes_contacto creada exitosamente';
RAISE NOTICE 'Se insertaron % mensajes de ejemplo', (SELECT COUNT(*) FROM mensajes_contacto);
RAISE NOTICE 'Funciones y vistas creadas correctamente';

