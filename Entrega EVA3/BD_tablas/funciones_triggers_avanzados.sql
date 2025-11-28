-- =============================================
-- FUNCIONES DE NEGOCIO AVANZADAS - LEVEL UP
-- Funciones, Triggers, Stored Procedures y Packages
-- =============================================

-- IMPORTANTE: Ejecutar DESPUÉS de schema_completo.sql

-- =============================================
-- SECCIÓN 1: FUNCIONES DE CÁLCULO
-- =============================================

-- Función: Calcular precio con descuento
CREATE OR REPLACE FUNCTION calcular_precio_con_descuento(
    p_precio_base DECIMAL(12,2),
    p_descuento_porcentaje DECIMAL(5,2)
)
RETURNS DECIMAL(12,2)
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN ROUND(p_precio_base * (1 - p_descuento_porcentaje / 100), 0);
END;
$$;

COMMENT ON FUNCTION calcular_precio_con_descuento IS 'Calcula el precio final aplicando el descuento porcentual';

-- Función: Calcular IVA (19% en Chile)
CREATE OR REPLACE FUNCTION calcular_iva(
    p_monto_neto DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN ROUND(p_monto_neto * 0.19, 2);
END;
$$;

-- Función: Calcular neto desde total con IVA
CREATE OR REPLACE FUNCTION calcular_neto(
    p_total DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN ROUND(p_total / 1.19, 2);
END;
$$;

-- Función: Validar stock disponible
CREATE OR REPLACE FUNCTION validar_stock_disponible(
    p_producto_id BIGINT,
    p_cantidad INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_stock_actual INTEGER;
BEGIN
    SELECT stock_actual INTO v_stock_actual
    FROM productos
    WHERE id = p_producto_id AND activo = TRUE;

    IF v_stock_actual IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN v_stock_actual >= p_cantidad;
END;
$$;

COMMENT ON FUNCTION validar_stock_disponible IS 'Verifica si hay stock suficiente del producto';

-- =============================================
-- SECCIÓN 2: FUNCIONES DE VALIDACIÓN
-- =============================================

-- Función: Validar RUT chileno
CREATE OR REPLACE FUNCTION validar_rut(p_rut VARCHAR)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_rut VARCHAR;
    v_dv VARCHAR;
    v_suma INTEGER := 0;
    v_multiplicador INTEGER := 2;
    v_i INTEGER;
    v_digito INTEGER;
    v_dv_calculado VARCHAR;
BEGIN
    -- Limpiar RUT (remover puntos y guión)
    v_rut := REPLACE(REPLACE(p_rut, '.', ''), '-', '');

    -- Separar número y dígito verificador
    v_dv := UPPER(SUBSTRING(v_rut FROM LENGTH(v_rut)));
    v_rut := SUBSTRING(v_rut FROM 1 FOR LENGTH(v_rut) - 1);

    -- Calcular dígito verificador
    FOR v_i IN REVERSE LENGTH(v_rut)..1 LOOP
        v_digito := CAST(SUBSTRING(v_rut FROM v_i FOR 1) AS INTEGER);
        v_suma := v_suma + (v_digito * v_multiplicador);
        v_multiplicador := v_multiplicador + 1;
        IF v_multiplicador > 7 THEN
            v_multiplicador := 2;
        END IF;
    END LOOP;

    v_digito := 11 - (v_suma % 11);

    IF v_digito = 11 THEN
        v_dv_calculado := '0';
    ELSIF v_digito = 10 THEN
        v_dv_calculado := 'K';
    ELSE
        v_dv_calculado := v_digito::VARCHAR;
    END IF;

    RETURN v_dv = v_dv_calculado;
END;
$$;

COMMENT ON FUNCTION validar_rut IS 'Valida formato y dígito verificador de RUT chileno';

-- Función: Validar email
CREATE OR REPLACE FUNCTION validar_email(p_email VARCHAR)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END;
$$;

-- Función: Validar cupón
CREATE OR REPLACE FUNCTION validar_cupon(
    p_codigo VARCHAR,
    p_usuario_id BIGINT,
    p_total_compra DECIMAL
)
RETURNS TABLE(
    valido BOOLEAN,
    mensaje TEXT,
    descuento DECIMAL
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_cupon RECORD;
    v_usos_usuario INTEGER;
BEGIN
    -- Buscar cupón
    SELECT * INTO v_cupon
    FROM cupones
    WHERE codigo = p_codigo AND activo = TRUE;

    -- Cupón no existe
    IF v_cupon IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Cupón no válido'::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Verificar fechas
    IF CURRENT_TIMESTAMP NOT BETWEEN v_cupon.fecha_inicio AND v_cupon.fecha_fin THEN
        RETURN QUERY SELECT FALSE, 'Cupón expirado'::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Verificar compra mínima
    IF p_total_compra < v_cupon.compra_minima THEN
        RETURN QUERY SELECT FALSE,
            'Compra mínima requerida: $' || v_cupon.compra_minima::TEXT,
            0::DECIMAL;
        RETURN;
    END IF;

    -- Verificar usos del usuario
    SELECT COUNT(*) INTO v_usos_usuario
    FROM uso_cupones
    WHERE cupon_id = v_cupon.id AND usuario_id = p_usuario_id;

    IF v_usos_usuario >= v_cupon.usos_por_cliente THEN
        RETURN QUERY SELECT FALSE, 'Ya usaste este cupón'::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Verificar usos totales
    IF v_cupon.usos_maximos IS NOT NULL AND v_cupon.usos_totales >= v_cupon.usos_maximos THEN
        RETURN QUERY SELECT FALSE, 'Cupón agotado'::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Calcular descuento
    DECLARE
        v_descuento DECIMAL;
    BEGIN
        IF v_cupon.tipo_descuento = 'PORCENTAJE' THEN
            v_descuento := ROUND(p_total_compra * v_cupon.valor_descuento / 100, 0);
            IF v_cupon.descuento_maximo IS NOT NULL THEN
                v_descuento := LEAST(v_descuento, v_cupon.descuento_maximo);
            END IF;
        ELSIF v_cupon.tipo_descuento = 'MONTO_FIJO' THEN
            v_descuento := v_cupon.valor_descuento;
        ELSE
            v_descuento := 0;
        END IF;

        RETURN QUERY SELECT TRUE, 'Cupón aplicado'::TEXT, v_descuento;
    END;
END;
$$;

COMMENT ON FUNCTION validar_cupon IS 'Valida cupón y calcula descuento aplicable';

-- =============================================
-- SECCIÓN 3: FUNCIONES DE CONSULTA
-- =============================================

-- Función: Obtener productos con bajo stock
CREATE OR REPLACE FUNCTION obtener_productos_bajo_stock()
RETURNS TABLE(
    producto_id BIGINT,
    codigo VARCHAR,
    nombre VARCHAR,
    stock_actual INTEGER,
    stock_minimo INTEGER,
    diferencia INTEGER
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.codigo,
        p.nombre,
        p.stock_actual,
        p.stock_minimo,
        p.stock_minimo - p.stock_actual as diferencia
    FROM productos p
    WHERE p.stock_actual < p.stock_minimo
        AND p.activo = TRUE
    ORDER BY diferencia DESC;
END;
$$;

-- Función: Calcular total de ventas por período
CREATE OR REPLACE FUNCTION calcular_ventas_periodo(
    p_fecha_inicio TIMESTAMPTZ,
    p_fecha_fin TIMESTAMPTZ
)
RETURNS TABLE(
    total_ordenes BIGINT,
    total_vendido DECIMAL,
    total_productos INTEGER,
    ticket_promedio DECIMAL
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT o.id)::BIGINT,
        COALESCE(SUM(o.total), 0)::DECIMAL,
        COALESCE(SUM(d.cantidad), 0)::INTEGER,
        COALESCE(AVG(o.total), 0)::DECIMAL
    FROM ordenes o
    LEFT JOIN detalle_ordenes d ON o.id = d.orden_id
    WHERE o.fecha_creacion BETWEEN p_fecha_inicio AND p_fecha_fin
        AND o.estado != 'CANCELADA';
END;
$$;

-- Función: Top productos vendidos
CREATE OR REPLACE FUNCTION top_productos_vendidos(
    p_limite INTEGER DEFAULT 10,
    p_fecha_inicio TIMESTAMPTZ DEFAULT NULL,
    p_fecha_fin TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE(
    producto_id BIGINT,
    codigo VARCHAR,
    nombre VARCHAR,
    cantidad_vendida BIGINT,
    ingresos_totales DECIMAL
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.codigo,
        p.nombre,
        SUM(d.cantidad)::BIGINT as cantidad_vendida,
        SUM(d.total)::DECIMAL as ingresos_totales
    FROM productos p
    INNER JOIN detalle_ordenes d ON p.id = d.producto_id
    INNER JOIN ordenes o ON d.orden_id = o.id
    WHERE o.estado != 'CANCELADA'
        AND (p_fecha_inicio IS NULL OR o.fecha_creacion >= p_fecha_inicio)
        AND (p_fecha_fin IS NULL OR o.fecha_creacion <= p_fecha_fin)
    GROUP BY p.id, p.codigo, p.nombre
    ORDER BY cantidad_vendida DESC
    LIMIT p_limite;
END;
$$;

-- Función: Obtener valor del carrito
CREATE OR REPLACE FUNCTION calcular_total_carrito(p_carrito_id BIGINT)
RETURNS DECIMAL
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_total DECIMAL;
BEGIN
    SELECT COALESCE(SUM(i.cantidad * i.precio_unitario), 0)
    INTO v_total
    FROM items_carrito i
    WHERE i.carrito_id = p_carrito_id;

    RETURN v_total;
END;
$$;

-- =============================================
-- SECCIÓN 4: STORED PROCEDURES (PROCEDIMIENTOS)
-- =============================================

-- Procedure: Procesar orden completa
CREATE OR REPLACE FUNCTION procesar_orden(
    p_usuario_id BIGINT,
    p_carrito_id BIGINT,
    p_direccion_envio TEXT,
    p_metodo_pago VARCHAR,
    p_codigo_cupon VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    orden_id BIGINT,
    numero_orden VARCHAR,
    total DECIMAL,
    mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_orden_id BIGINT;
    v_numero_orden VARCHAR;
    v_subtotal DECIMAL := 0;
    v_descuento DECIMAL := 0;
    v_envio DECIMAL := 3990;
    v_iva DECIMAL;
    v_total DECIMAL;
    v_usuario RECORD;
    v_item RECORD;
BEGIN
    -- Obtener datos del usuario
    SELECT * INTO v_usuario FROM usuarios WHERE id = p_usuario_id;

    IF v_usuario IS NULL THEN
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    -- Validar items del carrito
    IF NOT EXISTS (SELECT 1 FROM items_carrito WHERE carrito_id = p_carrito_id) THEN
        RAISE EXCEPTION 'Carrito vacío';
    END IF;

    -- Validar stock
    FOR v_item IN
        SELECT ic.producto_id, ic.cantidad, p.stock_actual, p.nombre
        FROM items_carrito ic
        JOIN productos p ON ic.producto_id = p.id
        WHERE ic.carrito_id = p_carrito_id
    LOOP
        IF v_item.stock_actual < v_item.cantidad THEN
            RAISE EXCEPTION 'Stock insuficiente para %', v_item.nombre;
        END IF;
    END LOOP;

    -- Calcular subtotal
    SELECT SUM(ic.cantidad * ic.precio_unitario)
    INTO v_subtotal
    FROM items_carrito ic
    WHERE ic.carrito_id = p_carrito_id;

    -- Aplicar cupón si existe
    IF p_codigo_cupon IS NOT NULL THEN
        DECLARE
            v_cupon_valido BOOLEAN;
            v_cupon_descuento DECIMAL;
        BEGIN
            SELECT valido, descuento
            INTO v_cupon_valido, v_cupon_descuento
            FROM validar_cupon(p_codigo_cupon, p_usuario_id, v_subtotal);

            IF v_cupon_valido THEN
                v_descuento := v_cupon_descuento;
            END IF;
        END;
    END IF;

    -- Calcular totales
    v_iva := calcular_iva(v_subtotal - v_descuento);
    v_total := v_subtotal - v_descuento + v_envio;

    -- Crear orden
    INSERT INTO ordenes (
        usuario_id, carrito_id,
        cliente_nombre, cliente_correo, cliente_telefono, cliente_run,
        direccion_envio, comuna_envio, ciudad_envio, region_envio,
        subtotal, descuento_total, envio, iva, total,
        estado, metodo_pago, estado_pago
    ) VALUES (
        p_usuario_id, p_carrito_id,
        v_usuario.nombre || ' ' || v_usuario.apellidos,
        v_usuario.correo, v_usuario.telefono, v_usuario.run,
        p_direccion_envio, v_usuario.comuna, v_usuario.ciudad, v_usuario.region,
        v_subtotal, v_descuento, v_envio, v_iva, v_total,
        'PENDIENTE', p_metodo_pago, 'PENDIENTE'
    )
    RETURNING id, ordenes.numero_orden INTO v_orden_id, v_numero_orden_resultado;

    -- Crear detalles de la orden
    INSERT INTO detalle_ordenes (
        orden_id, producto_id, producto_codigo, producto_nombre,
        cantidad, precio_unitario, descuento_unitario, precio_final,
        subtotal, iva, total
    )
    SELECT
        v_orden_id,
        p.id,
        p.codigo,
        p.nombre,
        ic.cantidad,
        ic.precio_unitario,
        0,
        ic.precio_unitario,
        ic.cantidad * ic.precio_unitario / 1.19,
        calcular_iva(ic.cantidad * ic.precio_unitario / 1.19),
        ic.cantidad * ic.precio_unitario
    FROM items_carrito ic
    JOIN productos p ON ic.producto_id = p.id
    WHERE ic.carrito_id = p_carrito_id;

    -- Actualizar estado del carrito
    UPDATE carritos SET estado = 'CONVERTIDO' WHERE id = p_carrito_id;

    -- Registrar uso de cupón
    IF p_codigo_cupon IS NOT NULL AND v_descuento > 0 THEN
        DECLARE
            v_cupon_id BIGINT;
        BEGIN
            SELECT id INTO v_cupon_id FROM cupones WHERE codigo = p_codigo_cupon;

            INSERT INTO uso_cupones (cupon_id, orden_id, usuario_id, descuento_aplicado)
            VALUES (v_cupon_id, v_orden_id, p_usuario_id, v_descuento);

            UPDATE cupones SET usos_totales = usos_totales + 1 WHERE id = v_cupon_id;
        END;
    END IF;

    -- Log
    INSERT INTO logs_sistema (tipo, nivel, usuario_id, modulo, accion, descripcion)
    VALUES ('USUARIO', 'INFO', p_usuario_id, 'ORDEN', 'CREAR',
            'Orden ' || v_numero_orden || ' creada por $' || v_total);

    RETURN QUERY SELECT v_orden_id, v_numero_orden, v_total, 'Orden creada exitosamente'::TEXT;
END;
$$;

COMMENT ON FUNCTION procesar_orden IS 'Procesa una orden completa: valida stock, crea orden, aplica cupón, registra logs';

-- Procedure: Cancelar orden
CREATE OR REPLACE FUNCTION cancelar_orden(
    p_orden_id BIGINT,
    p_motivo TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_orden RECORD;
BEGIN
    SELECT * INTO v_orden FROM ordenes WHERE id = p_orden_id;

    IF v_orden IS NULL THEN
        RAISE EXCEPTION 'Orden no encontrada';
    END IF;

    IF v_orden.estado IN ('ENTREGADA', 'CANCELADA') THEN
        RAISE EXCEPTION 'No se puede cancelar orden en estado %', v_orden.estado;
    END IF;

    -- Actualizar estado
    UPDATE ordenes
    SET estado = 'CANCELADA',
        fecha_cancelada = CURRENT_TIMESTAMP,
        notas_internas = COALESCE(notas_internas || E'\n', '') ||
                        'Cancelada: ' || COALESCE(p_motivo, 'Sin motivo especificado')
    WHERE id = p_orden_id;

    -- Devolver stock (se hace automático con el trigger de seguimiento)

    -- Log
    INSERT INTO logs_sistema (tipo, nivel, usuario_id, modulo, accion, descripcion)
    VALUES ('USUARIO', 'WARNING', v_orden.usuario_id, 'ORDEN', 'CANCELAR',
            'Orden ' || v_orden.numero_orden || ' cancelada: ' || COALESCE(p_motivo, 'Sin motivo'));

    RETURN TRUE;
END;
$$;

-- =============================================
-- SECCIÓN 5: TRIGGERS AVANZADOS
-- =============================================

-- Trigger: Validar stock antes de agregar al carrito
CREATE OR REPLACE FUNCTION validar_stock_carrito()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock INTEGER;
BEGIN
    SELECT stock_actual INTO v_stock
    FROM productos
    WHERE id = NEW.producto_id AND activo = TRUE;

    IF v_stock IS NULL THEN
        RAISE EXCEPTION 'Producto no disponible';
    END IF;

    IF v_stock < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente. Disponible: %', v_stock;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_validar_stock_carrito
    BEFORE INSERT OR UPDATE ON items_carrito
    FOR EACH ROW
    EXECUTE FUNCTION validar_stock_carrito();

-- Trigger: Actualizar precio del carrito al cambiar producto
CREATE OR REPLACE FUNCTION actualizar_precio_item_carrito()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Actualizar precio del item con el precio actual del producto
    SELECT precio_venta INTO NEW.precio_unitario
    FROM productos
    WHERE id = NEW.producto_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_actualizar_precio_item_carrito
    BEFORE INSERT ON items_carrito
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_precio_item_carrito();

-- Trigger: Devolver stock al cancelar orden
CREATE OR REPLACE FUNCTION devolver_stock_cancelacion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_detalle RECORD;
BEGIN
    -- Solo devolver stock si la orden fue cancelada
    IF NEW.estado = 'CANCELADA' AND OLD.estado != 'CANCELADA' THEN
        -- Devolver stock de cada producto
        FOR v_detalle IN
            SELECT producto_id, cantidad
            FROM detalle_ordenes
            WHERE orden_id = NEW.id
        LOOP
            UPDATE productos
            SET stock_actual = stock_actual + v_detalle.cantidad
            WHERE id = v_detalle.producto_id;

            -- Registrar movimiento
            INSERT INTO movimientos_inventario (
                producto_id, tipo_movimiento, cantidad,
                stock_anterior, stock_nuevo,
                motivo, referencia_id, referencia_tipo
            )
            SELECT
                v_detalle.producto_id,
                'DEVOLUCION',
                v_detalle.cantidad,
                stock_actual - v_detalle.cantidad,
                stock_actual,
                'Devolución por cancelación de orden',
                NEW.id,
                'ORDEN'
            FROM productos WHERE id = v_detalle.producto_id;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_devolver_stock_cancelacion
    AFTER UPDATE ON ordenes
    FOR EACH ROW
    WHEN (NEW.estado = 'CANCELADA' AND OLD.estado != 'CANCELADA')
    EXECUTE FUNCTION devolver_stock_cancelacion();

-- Trigger: Alertar stock crítico
CREATE OR REPLACE FUNCTION alertar_stock_critico()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.stock_actual <= NEW.stock_minimo AND OLD.stock_actual > OLD.stock_minimo THEN
        INSERT INTO logs_sistema (
            tipo, nivel, modulo, accion, descripcion,
            entidad_tipo, entidad_id
        ) VALUES (
            'SISTEMA', 'WARNING', 'INVENTARIO', 'STOCK_BAJO',
            'Producto "' || NEW.nombre || '" tiene stock bajo: ' || NEW.stock_actual,
            'PRODUCTO', NEW.id
        );
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_alertar_stock_critico
    AFTER UPDATE ON productos
    FOR EACH ROW
    WHEN (NEW.stock_actual IS DISTINCT FROM OLD.stock_actual)
    EXECUTE FUNCTION alertar_stock_critico();

-- Trigger: Validar orden antes de crear
CREATE OR REPLACE FUNCTION validar_orden_antes_crear()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar montos
    IF NEW.total <= 0 THEN
        RAISE EXCEPTION 'El total de la orden debe ser mayor a 0';
    END IF;

    IF NEW.subtotal <= 0 THEN
        RAISE EXCEPTION 'El subtotal debe ser mayor a 0';
    END IF;

    -- Validar usuario activo
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = NEW.usuario_id AND activo = TRUE) THEN
        RAISE EXCEPTION 'Usuario no activo';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_validar_orden_antes_crear
    BEFORE INSERT ON ordenes
    FOR EACH ROW
    EXECUTE FUNCTION validar_orden_antes_crear();

-- Trigger: Incrementar contador de reviews del producto
CREATE OR REPLACE FUNCTION actualizar_contador_reviews()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Este trigger podría actualizar un campo de conteo en la tabla productos
    -- Por ahora solo registra en logs
    INSERT INTO logs_sistema (
        tipo, nivel, usuario_id, modulo, accion,
        entidad_tipo, entidad_id
    ) VALUES (
        'USUARIO', 'INFO', NEW.usuario_id, 'REVIEWS', 'NUEVA_REVIEW',
        'PRODUCTO', NEW.producto_id
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_actualizar_contador_reviews
    AFTER INSERT ON reviews_productos
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_contador_reviews();

-- =============================================
-- SECCIÓN 6: FUNCIONES DE UTILIDAD
-- =============================================

-- Función: Limpiar carritos abandonados
CREATE OR REPLACE FUNCTION limpiar_carritos_abandonados(
    p_dias_inactividad INTEGER DEFAULT 30
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_fecha_limite TIMESTAMP;
    v_carritos_eliminados INTEGER;
BEGIN
    v_fecha_limite := CURRENT_TIMESTAMP - (p_dias_inactividad || ' days')::INTERVAL;

    -- Marcar carritos como expirados
    UPDATE carritos
    SET estado = 'EXPIRADO'
    WHERE estado = 'ACTIVO'
        AND fecha_actualizacion < v_fecha_limite;

    GET DIAGNOSTICS v_carritos_eliminados = ROW_COUNT;

    -- Log
    INSERT INTO logs_sistema (
        tipo, nivel, modulo, accion, descripcion
    ) VALUES (
        'SISTEMA', 'INFO', 'CARRITOS', 'LIMPIEZA',
        'Se marcaron ' || v_carritos_eliminados || ' carritos como expirados'
    );

    RETURN v_carritos_eliminados;
END;
$$;

-- Función: Generar reporte de ventas
CREATE OR REPLACE FUNCTION generar_reporte_ventas(
    p_fecha_inicio DATE,
    p_fecha_fin DATE
)
RETURNS TABLE(
    fecha DATE,
    total_ordenes BIGINT,
    total_vendido DECIMAL,
    ticket_promedio DECIMAL,
    productos_vendidos BIGINT
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.fecha_creacion::DATE as fecha,
        COUNT(DISTINCT o.id)::BIGINT as total_ordenes,
        SUM(o.total)::DECIMAL as total_vendido,
        AVG(o.total)::DECIMAL as ticket_promedio,
        SUM(d.cantidad)::BIGINT as productos_vendidos
    FROM ordenes o
    LEFT JOIN detalle_ordenes d ON o.id = d.orden_id
    WHERE o.fecha_creacion::DATE BETWEEN p_fecha_inicio AND p_fecha_fin
        AND o.estado != 'CANCELADA'
    GROUP BY o.fecha_creacion::DATE
    ORDER BY fecha DESC;
END;
$$;

-- =============================================
-- FIN DE FUNCIONES Y TRIGGERS
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE '✅ FUNCIONES Y TRIGGERS CREADOS';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'Funciones de cálculo: 4';
    RAISE NOTICE 'Funciones de validación: 3';
    RAISE NOTICE 'Funciones de consulta: 5';
    RAISE NOTICE 'Stored Procedures: 2';
    RAISE NOTICE 'Triggers avanzados: 6';
    RAISE NOTICE 'Funciones de utilidad: 2';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'Total funciones adicionales: 16+';
    RAISE NOTICE '═══════════════════════════════════════════════';
END $$;
-- =============================================
-- FUNCIONES DE NEGOCIO AVANZADAS - LEVEL UP
-- Funciones, Triggers, Stored Procedures y Packages
-- =============================================

-- IMPORTANTE: Ejecutar DESPUÉS de schema_completo.sql

-- =============================================
-- SECCIÓN 1: FUNCIONES DE CÁLCULO
-- =============================================

-- Función: Calcular precio con descuento
CREATE OR REPLACE FUNCTION calcular_precio_con_descuento(
    p_precio_base DECIMAL(12,2),
    p_descuento_porcentaje DECIMAL(5,2)
)
RETURNS DECIMAL(12,2)
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN ROUND(p_precio_base * (1 - p_descuento_porcentaje / 100), 0);
END;
$$;

COMMENT ON FUNCTION calcular_precio_con_descuento IS 'Calcula el precio final aplicando el descuento porcentual';

-- Función: Calcular IVA (19% en Chile)
CREATE OR REPLACE FUNCTION calcular_iva(
    p_monto_neto DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN ROUND(p_monto_neto * 0.19, 2);
END;
$$;

-- Función: Calcular neto desde total con IVA
CREATE OR REPLACE FUNCTION calcular_neto(
    p_total DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN ROUND(p_total / 1.19, 2);
END;
$$;

-- Función: Validar stock disponible
CREATE OR REPLACE FUNCTION validar_stock_disponible(
    p_producto_id BIGINT,
    p_cantidad INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_stock_actual INTEGER;
BEGIN
    SELECT stock_actual INTO v_stock_actual
    FROM productos
    WHERE id = p_producto_id AND activo = TRUE;

    IF v_stock_actual IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN v_stock_actual >= p_cantidad;
END;
$$;

COMMENT ON FUNCTION validar_stock_disponible IS 'Verifica si hay stock suficiente del producto';

-- =============================================
-- SECCIÓN 2: FUNCIONES DE VALIDACIÓN
-- =============================================

-- Función: Validar RUT chileno
CREATE OR REPLACE FUNCTION validar_rut(p_rut VARCHAR)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_rut VARCHAR;
    v_dv VARCHAR;
    v_suma INTEGER := 0;
    v_multiplicador INTEGER := 2;
    v_i INTEGER;
    v_digito INTEGER;
    v_dv_calculado VARCHAR;
BEGIN
    -- Limpiar RUT (remover puntos y guión)
    v_rut := REPLACE(REPLACE(p_rut, '.', ''), '-', '');

    -- Separar número y dígito verificador
    v_dv := UPPER(SUBSTRING(v_rut FROM LENGTH(v_rut)));
    v_rut := SUBSTRING(v_rut FROM 1 FOR LENGTH(v_rut) - 1);

    -- Calcular dígito verificador
    FOR v_i IN REVERSE LENGTH(v_rut)..1 LOOP
        v_digito := CAST(SUBSTRING(v_rut FROM v_i FOR 1) AS INTEGER);
        v_suma := v_suma + (v_digito * v_multiplicador);
        v_multiplicador := v_multiplicador + 1;
        IF v_multiplicador > 7 THEN
            v_multiplicador := 2;
        END IF;
    END LOOP;

    v_digito := 11 - (v_suma % 11);

    IF v_digito = 11 THEN
        v_dv_calculado := '0';
    ELSIF v_digito = 10 THEN
        v_dv_calculado := 'K';
    ELSE
        v_dv_calculado := v_digito::VARCHAR;
    END IF;

    RETURN v_dv = v_dv_calculado;
END;
$$;

COMMENT ON FUNCTION validar_rut IS 'Valida formato y dígito verificador de RUT chileno';

-- Función: Validar email
CREATE OR REPLACE FUNCTION validar_email(p_email VARCHAR)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END;
$$;

-- Función: Validar cupón
CREATE OR REPLACE FUNCTION validar_cupon(
    p_codigo VARCHAR,
    p_usuario_id BIGINT,
    p_total_compra DECIMAL
)
RETURNS TABLE(
    valido BOOLEAN,
    mensaje TEXT,
    descuento DECIMAL
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_cupon RECORD;
    v_usos_usuario INTEGER;
BEGIN
    -- Buscar cupón
    SELECT * INTO v_cupon
    FROM cupones
    WHERE codigo = p_codigo AND activo = TRUE;

    -- Cupón no existe
    IF v_cupon IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Cupón no válido'::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Verificar fechas
    IF CURRENT_TIMESTAMP NOT BETWEEN v_cupon.fecha_inicio AND v_cupon.fecha_fin THEN
        RETURN QUERY SELECT FALSE, 'Cupón expirado'::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Verificar compra mínima
    IF p_total_compra < v_cupon.compra_minima THEN
        RETURN QUERY SELECT FALSE,
            'Compra mínima requerida: $' || v_cupon.compra_minima::TEXT,
            0::DECIMAL;
        RETURN;
    END IF;

    -- Verificar usos del usuario
    SELECT COUNT(*) INTO v_usos_usuario
    FROM uso_cupones
    WHERE cupon_id = v_cupon.id AND usuario_id = p_usuario_id;

    IF v_usos_usuario >= v_cupon.usos_por_cliente THEN
        RETURN QUERY SELECT FALSE, 'Ya usaste este cupón'::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Verificar usos totales
    IF v_cupon.usos_maximos IS NOT NULL AND v_cupon.usos_totales >= v_cupon.usos_maximos THEN
        RETURN QUERY SELECT FALSE, 'Cupón agotado'::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Calcular descuento
    DECLARE
        v_descuento DECIMAL;
    BEGIN
        IF v_cupon.tipo_descuento = 'PORCENTAJE' THEN
            v_descuento := ROUND(p_total_compra * v_cupon.valor_descuento / 100, 0);
            IF v_cupon.descuento_maximo IS NOT NULL THEN
                v_descuento := LEAST(v_descuento, v_cupon.descuento_maximo);
            END IF;
        ELSIF v_cupon.tipo_descuento = 'MONTO_FIJO' THEN
            v_descuento := v_cupon.valor_descuento;
        ELSE
            v_descuento := 0;
        END IF;

        RETURN QUERY SELECT TRUE, 'Cupón aplicado'::TEXT, v_descuento;
    END;
END;
$$;

COMMENT ON FUNCTION validar_cupon IS 'Valida cupón y calcula descuento aplicable';

-- =============================================
-- SECCIÓN 3: FUNCIONES DE CONSULTA
-- =============================================

-- Función: Obtener productos con bajo stock
CREATE OR REPLACE FUNCTION obtener_productos_bajo_stock()
RETURNS TABLE(
    producto_id BIGINT,
    codigo VARCHAR,
    nombre VARCHAR,
    stock_actual INTEGER,
    stock_minimo INTEGER,
    diferencia INTEGER
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.codigo,
        p.nombre,
        p.stock_actual,
        p.stock_minimo,
        p.stock_minimo - p.stock_actual as diferencia
    FROM productos p
    WHERE p.stock_actual < p.stock_minimo
        AND p.activo = TRUE
    ORDER BY diferencia DESC;
END;
$$;

-- Función: Calcular total de ventas por período
CREATE OR REPLACE FUNCTION calcular_ventas_periodo(
    p_fecha_inicio TIMESTAMPTZ,
    p_fecha_fin TIMESTAMPTZ
)
RETURNS TABLE(
    total_ordenes BIGINT,
    total_vendido DECIMAL,
    total_productos INTEGER,
    ticket_promedio DECIMAL
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT o.id)::BIGINT,
        COALESCE(SUM(o.total), 0)::DECIMAL,
        COALESCE(SUM(d.cantidad), 0)::INTEGER,
        COALESCE(AVG(o.total), 0)::DECIMAL
    FROM ordenes o
    LEFT JOIN detalle_ordenes d ON o.id = d.orden_id
    WHERE o.fecha_creacion BETWEEN p_fecha_inicio AND p_fecha_fin
        AND o.estado != 'CANCELADA';
END;
$$;

-- Función: Top productos vendidos
CREATE OR REPLACE FUNCTION top_productos_vendidos(
    p_limite INTEGER DEFAULT 10,
    p_fecha_inicio TIMESTAMPTZ DEFAULT NULL,
    p_fecha_fin TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE(
    producto_id BIGINT,
    codigo VARCHAR,
    nombre VARCHAR,
    cantidad_vendida BIGINT,
    ingresos_totales DECIMAL
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.codigo,
        p.nombre,
        SUM(d.cantidad)::BIGINT as cantidad_vendida,
        SUM(d.total)::DECIMAL as ingresos_totales
    FROM productos p
    INNER JOIN detalle_ordenes d ON p.id = d.producto_id
    INNER JOIN ordenes o ON d.orden_id = o.id
    WHERE o.estado != 'CANCELADA'
        AND (p_fecha_inicio IS NULL OR o.fecha_creacion >= p_fecha_inicio)
        AND (p_fecha_fin IS NULL OR o.fecha_creacion <= p_fecha_fin)
    GROUP BY p.id, p.codigo, p.nombre
    ORDER BY cantidad_vendida DESC
    LIMIT p_limite;
END;
$$;

-- Función: Obtener valor del carrito
CREATE OR REPLACE FUNCTION calcular_total_carrito(p_carrito_id BIGINT)
RETURNS DECIMAL
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_total DECIMAL;
BEGIN
    SELECT COALESCE(SUM(i.cantidad * i.precio_unitario), 0)
    INTO v_total
    FROM items_carrito i
    WHERE i.carrito_id = p_carrito_id;

    RETURN v_total;
END;
$$;

-- =============================================
-- SECCIÓN 4: STORED PROCEDURES (PROCEDIMIENTOS)
-- =============================================

-- Procedure: Procesar orden completa
CREATE OR REPLACE FUNCTION procesar_orden(
    p_usuario_id BIGINT,
    p_carrito_id BIGINT,
    p_direccion_envio TEXT,
    p_metodo_pago VARCHAR,
    p_codigo_cupon VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    orden_id BIGINT,
    numero_orden VARCHAR,
    total DECIMAL,
    mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_orden_id BIGINT;
    v_numero_orden_resultado VARCHAR;  -- Renombrado para evitar conflicto
    v_subtotal DECIMAL := 0;
    v_descuento DECIMAL := 0;
    v_envio DECIMAL := 3990;
    v_iva DECIMAL;
    v_total DECIMAL;
    v_usuario RECORD;
    v_item RECORD;
BEGIN
    -- Obtener datos del usuario
    SELECT * INTO v_usuario FROM usuarios WHERE id = p_usuario_id;

    IF v_usuario IS NULL THEN
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    -- Validar items del carrito
    IF NOT EXISTS (SELECT 1 FROM items_carrito WHERE carrito_id = p_carrito_id) THEN
        RAISE EXCEPTION 'Carrito vacío';
    END IF;

    -- Validar stock
    FOR v_item IN
        SELECT ic.producto_id, ic.cantidad, p.stock_actual, p.nombre
        FROM items_carrito ic
        JOIN productos p ON ic.producto_id = p.id
        WHERE ic.carrito_id = p_carrito_id
    LOOP
        IF v_item.stock_actual < v_item.cantidad THEN
            RAISE EXCEPTION 'Stock insuficiente para %', v_item.nombre;
        END IF;
    END LOOP;

    -- Calcular subtotal
    SELECT SUM(ic.cantidad * ic.precio_unitario)
    INTO v_subtotal
    FROM items_carrito ic
    WHERE ic.carrito_id = p_carrito_id;

    -- Aplicar cupón si existe
    IF p_codigo_cupon IS NOT NULL THEN
        DECLARE
            v_cupon_valido BOOLEAN;
            v_cupon_descuento DECIMAL;
        BEGIN
            SELECT valido, descuento
            INTO v_cupon_valido, v_cupon_descuento
            FROM validar_cupon(p_codigo_cupon, p_usuario_id, v_subtotal);

            IF v_cupon_valido THEN
                v_descuento := v_cupon_descuento;
            END IF;
        END;
    END IF;

    -- Calcular totales
    v_iva := calcular_iva(v_subtotal - v_descuento);
    v_total := v_subtotal - v_descuento + v_envio;

    -- Crear orden
    INSERT INTO ordenes (
        usuario_id, carrito_id,
        cliente_nombre, cliente_correo, cliente_telefono, cliente_run,
        direccion_envio, comuna_envio, ciudad_envio, region_envio,
        subtotal, descuento_total, envio, iva, total,
        estado, metodo_pago, estado_pago
    ) VALUES (
        p_usuario_id, p_carrito_id,
        v_usuario.nombre || ' ' || v_usuario.apellidos,
        v_usuario.correo, v_usuario.telefono, v_usuario.run,
        p_direccion_envio, v_usuario.comuna, v_usuario.ciudad, v_usuario.region,
        v_subtotal, v_descuento, v_envio, v_iva, v_total,
        'PENDIENTE', p_metodo_pago, 'PENDIENTE'
    )
    RETURNING id, numero_orden INTO v_orden_id, v_numero_orden;

    -- Crear detalles de la orden
    INSERT INTO detalle_ordenes (
        orden_id, producto_id, producto_codigo, producto_nombre,
        cantidad, precio_unitario, descuento_unitario, precio_final,
        subtotal, iva, total
    )
    SELECT
        v_orden_id,
        p.id,
        p.codigo,
        p.nombre,
        ic.cantidad,
        ic.precio_unitario,
        0,
        ic.precio_unitario,
        ic.cantidad * ic.precio_unitario / 1.19,
        calcular_iva(ic.cantidad * ic.precio_unitario / 1.19),
        ic.cantidad * ic.precio_unitario
    FROM items_carrito ic
    JOIN productos p ON ic.producto_id = p.id
    WHERE ic.carrito_id = p_carrito_id;

    -- Actualizar estado del carrito
    UPDATE carritos SET estado = 'CONVERTIDO' WHERE id = p_carrito_id;

    -- Registrar uso de cupón
    IF p_codigo_cupon IS NOT NULL AND v_descuento > 0 THEN
        DECLARE
            v_cupon_id BIGINT;
        BEGIN
            SELECT id INTO v_cupon_id FROM cupones WHERE codigo = p_codigo_cupon;

            INSERT INTO uso_cupones (cupon_id, orden_id, usuario_id, descuento_aplicado)
            VALUES (v_cupon_id, v_orden_id, p_usuario_id, v_descuento);

            UPDATE cupones SET usos_totales = usos_totales + 1 WHERE id = v_cupon_id;
        END;
    END IF;

    -- Log
    INSERT INTO logs_sistema (tipo, nivel, usuario_id, modulo, accion, descripcion)
    VALUES ('USUARIO', 'INFO', p_usuario_id, 'ORDEN', 'CREAR',
            'Orden ' || v_numero_orden || ' creada por $' || v_total);

    RETURN QUERY SELECT v_orden_id, v_numero_orden, v_total, 'Orden creada exitosamente'::TEXT;
END;
$$;

COMMENT ON FUNCTION procesar_orden IS 'Procesa una orden completa: valida stock, crea orden, aplica cupón, registra logs';

-- Procedure: Cancelar orden
CREATE OR REPLACE FUNCTION cancelar_orden(
    p_orden_id BIGINT,
    p_motivo TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_orden RECORD;
BEGIN
    SELECT * INTO v_orden FROM ordenes WHERE id = p_orden_id;

    IF v_orden IS NULL THEN
        RAISE EXCEPTION 'Orden no encontrada';
    END IF;

    IF v_orden.estado IN ('ENTREGADA', 'CANCELADA') THEN
        RAISE EXCEPTION 'No se puede cancelar orden en estado %', v_orden.estado;
    END IF;

    -- Actualizar estado
    UPDATE ordenes
    SET estado = 'CANCELADA',
        fecha_cancelada = CURRENT_TIMESTAMP,
        notas_internas = COALESCE(notas_internas || E'\n', '') ||
                        'Cancelada: ' || COALESCE(p_motivo, 'Sin motivo especificado')
    WHERE id = p_orden_id;

    -- Devolver stock (se hace automático con el trigger de seguimiento)

    -- Log
    INSERT INTO logs_sistema (tipo, nivel, usuario_id, modulo, accion, descripcion)
    VALUES ('USUARIO', 'WARNING', v_orden.usuario_id, 'ORDEN', 'CANCELAR',
            'Orden ' || v_orden.numero_orden || ' cancelada: ' || COALESCE(p_motivo, 'Sin motivo'));

    RETURN TRUE;
END;
$$;

-- =============================================
-- SECCIÓN 5: TRIGGERS AVANZADOS
-- =============================================

-- Trigger: Validar stock antes de agregar al carrito
CREATE OR REPLACE FUNCTION validar_stock_carrito()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock INTEGER;
BEGIN
    SELECT stock_actual INTO v_stock
    FROM productos
    WHERE id = NEW.producto_id AND activo = TRUE;

    IF v_stock IS NULL THEN
        RAISE EXCEPTION 'Producto no disponible';
    END IF;

    IF v_stock < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente. Disponible: %', v_stock;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_validar_stock_carrito
    BEFORE INSERT OR UPDATE ON items_carrito
    FOR EACH ROW
    EXECUTE FUNCTION validar_stock_carrito();

-- Trigger: Actualizar precio del carrito al cambiar producto
CREATE OR REPLACE FUNCTION actualizar_precio_item_carrito()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Actualizar precio del item con el precio actual del producto
    SELECT precio_venta INTO NEW.precio_unitario
    FROM productos
    WHERE id = NEW.producto_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_actualizar_precio_item_carrito
    BEFORE INSERT ON items_carrito
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_precio_item_carrito();

-- Trigger: Devolver stock al cancelar orden
CREATE OR REPLACE FUNCTION devolver_stock_cancelacion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_detalle RECORD;
BEGIN
    -- Solo devolver stock si la orden fue cancelada
    IF NEW.estado = 'CANCELADA' AND OLD.estado != 'CANCELADA' THEN
        -- Devolver stock de cada producto
        FOR v_detalle IN
            SELECT producto_id, cantidad
            FROM detalle_ordenes
            WHERE orden_id = NEW.id
        LOOP
            UPDATE productos
            SET stock_actual = stock_actual + v_detalle.cantidad
            WHERE id = v_detalle.producto_id;

            -- Registrar movimiento
            INSERT INTO movimientos_inventario (
                producto_id, tipo_movimiento, cantidad,
                stock_anterior, stock_nuevo,
                motivo, referencia_id, referencia_tipo
            )
            SELECT
                v_detalle.producto_id,
                'DEVOLUCION',
                v_detalle.cantidad,
                stock_actual - v_detalle.cantidad,
                stock_actual,
                'Devolución por cancelación de orden',
                NEW.id,
                'ORDEN'
            FROM productos WHERE id = v_detalle.producto_id;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_devolver_stock_cancelacion
    AFTER UPDATE ON ordenes
    FOR EACH ROW
    WHEN (NEW.estado = 'CANCELADA' AND OLD.estado != 'CANCELADA')
    EXECUTE FUNCTION devolver_stock_cancelacion();

-- Trigger: Alertar stock crítico
CREATE OR REPLACE FUNCTION alertar_stock_critico()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.stock_actual <= NEW.stock_minimo AND OLD.stock_actual > OLD.stock_minimo THEN
        INSERT INTO logs_sistema (
            tipo, nivel, modulo, accion, descripcion,
            entidad_tipo, entidad_id
        ) VALUES (
            'SISTEMA', 'WARNING', 'INVENTARIO', 'STOCK_BAJO',
            'Producto "' || NEW.nombre || '" tiene stock bajo: ' || NEW.stock_actual,
            'PRODUCTO', NEW.id
        );
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_alertar_stock_critico
    AFTER UPDATE ON productos
    FOR EACH ROW
    WHEN (NEW.stock_actual IS DISTINCT FROM OLD.stock_actual)
    EXECUTE FUNCTION alertar_stock_critico();

-- Trigger: Validar orden antes de crear
CREATE OR REPLACE FUNCTION validar_orden_antes_crear()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar montos
    IF NEW.total <= 0 THEN
        RAISE EXCEPTION 'El total de la orden debe ser mayor a 0';
    END IF;

    IF NEW.subtotal <= 0 THEN
        RAISE EXCEPTION 'El subtotal debe ser mayor a 0';
    END IF;

    -- Validar usuario activo
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = NEW.usuario_id AND activo = TRUE) THEN
        RAISE EXCEPTION 'Usuario no activo';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_validar_orden_antes_crear
    BEFORE INSERT ON ordenes
    FOR EACH ROW
    EXECUTE FUNCTION validar_orden_antes_crear();

-- Trigger: Incrementar contador de reviews del producto
CREATE OR REPLACE FUNCTION actualizar_contador_reviews()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Este trigger podría actualizar un campo de conteo en la tabla productos
    -- Por ahora solo registra en logs
    INSERT INTO logs_sistema (
        tipo, nivel, usuario_id, modulo, accion,
        entidad_tipo, entidad_id
    ) VALUES (
        'USUARIO', 'INFO', NEW.usuario_id, 'REVIEWS', 'NUEVA_REVIEW',
        'PRODUCTO', NEW.producto_id
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_actualizar_contador_reviews
    AFTER INSERT ON reviews_productos
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_contador_reviews();

-- =============================================
-- SECCIÓN 6: FUNCIONES DE UTILIDAD
-- =============================================

-- Función: Limpiar carritos abandonados
CREATE OR REPLACE FUNCTION limpiar_carritos_abandonados(
    p_dias_inactividad INTEGER DEFAULT 30
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_fecha_limite TIMESTAMP;
    v_carritos_eliminados INTEGER;
BEGIN
    v_fecha_limite := CURRENT_TIMESTAMP - (p_dias_inactividad || ' days')::INTERVAL;

    -- Marcar carritos como expirados
    UPDATE carritos
    SET estado = 'EXPIRADO'
    WHERE estado = 'ACTIVO'
        AND fecha_actualizacion < v_fecha_limite;

    GET DIAGNOSTICS v_carritos_eliminados = ROW_COUNT;

    -- Log
    INSERT INTO logs_sistema (
        tipo, nivel, modulo, accion, descripcion
    ) VALUES (
        'SISTEMA', 'INFO', 'CARRITOS', 'LIMPIEZA',
        'Se marcaron ' || v_carritos_eliminados || ' carritos como expirados'
    );

    RETURN v_carritos_eliminados;
END;
$$;

-- Función: Generar reporte de ventas
CREATE OR REPLACE FUNCTION generar_reporte_ventas(
    p_fecha_inicio DATE,
    p_fecha_fin DATE
)
RETURNS TABLE(
    fecha DATE,
    total_ordenes BIGINT,
    total_vendido DECIMAL,
    ticket_promedio DECIMAL,
    productos_vendidos BIGINT
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.fecha_creacion::DATE as fecha,
        COUNT(DISTINCT o.id)::BIGINT as total_ordenes,
        SUM(o.total)::DECIMAL as total_vendido,
        AVG(o.total)::DECIMAL as ticket_promedio,
        SUM(d.cantidad)::BIGINT as productos_vendidos
    FROM ordenes o
    LEFT JOIN detalle_ordenes d ON o.id = d.orden_id
    WHERE o.fecha_creacion::DATE BETWEEN p_fecha_inicio AND p_fecha_fin
        AND o.estado != 'CANCELADA'
    GROUP BY o.fecha_creacion::DATE
    ORDER BY fecha DESC;
END;
$$;

-- =============================================
-- FIN DE FUNCIONES Y TRIGGERS
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE '✅ FUNCIONES Y TRIGGERS CREADOS';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'Funciones de cálculo: 4';
    RAISE NOTICE 'Funciones de validación: 3';
    RAISE NOTICE 'Funciones de consulta: 5';
    RAISE NOTICE 'Stored Procedures: 2';
    RAISE NOTICE 'Triggers avanzados: 6';
    RAISE NOTICE 'Funciones de utilidad: 2';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'Total funciones adicionales: 16+';
    RAISE NOTICE '═══════════════════════════════════════════════';
END $$;

