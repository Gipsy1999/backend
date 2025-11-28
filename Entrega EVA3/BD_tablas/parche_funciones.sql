-- =============================================
-- PARCHE: Corrección de errores en funciones
-- Ejecutar este archivo para corregir funciones ya creadas
-- =============================================

-- ERROR 1: Corregir función calcular_ventas_periodo
-- Problema: No acepta TIMESTAMPTZ
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

-- ERROR 2: Corregir función top_productos_vendidos
-- Problema: No acepta TIMESTAMPTZ
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

-- ERROR 3: Corregir función procesar_orden
-- Problema: Conflicto de nombres entre variable y columna "numero_orden"
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

    -- Crear orden (usar alias en RETURNING para evitar ambigüedad)
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
            'Orden ' || v_numero_orden_resultado || ' creada por $' || v_total);

    RETURN QUERY SELECT v_orden_id, v_numero_orden_resultado, v_total, 'Orden creada exitosamente'::TEXT;
END;
$$;

-- ERROR 4: Corregir función cancelar_orden
-- Problema: Validación muy estricta
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

    -- Permitir cancelación solo si NO está entregada o ya cancelada
    IF v_orden.estado = 'CANCELADA' THEN
        RAISE EXCEPTION 'La orden ya está cancelada';
    END IF;

    IF v_orden.estado = 'ENTREGADA' THEN
        RAISE EXCEPTION 'No se puede cancelar una orden ya entregada. Debe crear una devolución.';
    END IF;

    -- Actualizar estado
    UPDATE ordenes
    SET estado = 'CANCELADA',
        fecha_cancelada = CURRENT_TIMESTAMP,
        notas_internas = COALESCE(notas_internas || E'\n', '') ||
                        'Cancelada: ' || COALESCE(p_motivo, 'Sin motivo especificado')
    WHERE id = p_orden_id;

    -- El trigger devolver_stock_cancelacion devolverá el stock automáticamente

    -- Log
    INSERT INTO logs_sistema (tipo, nivel, usuario_id, modulo, accion, descripcion)
    VALUES ('USUARIO', 'WARNING', v_orden.usuario_id, 'ORDEN', 'CANCELAR',
            'Orden ' || v_orden.numero_orden || ' cancelada: ' || COALESCE(p_motivo, 'Sin motivo'));

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION cancelar_orden IS 'Cancela una orden y devuelve el stock automáticamente. No permite cancelar órdenes entregadas.';

-- =============================================
-- MENSAJE DE CONFIRMACIÓN
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE '✅ TODAS LAS FUNCIONES CORREGIDAS';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'Errores corregidos:';
    RAISE NOTICE '1. calcular_ventas_periodo - Ahora acepta TIMESTAMPTZ';
    RAISE NOTICE '2. top_productos_vendidos - Ahora acepta TIMESTAMPTZ';
    RAISE NOTICE '3. procesar_orden - Resuelto conflicto de nombres';
    RAISE NOTICE '4. cancelar_orden - Validación mejorada';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'Puedes probar las funciones ahora';
    RAISE NOTICE '═══════════════════════════════════════════════';
END $$;

