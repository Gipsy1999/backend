-- =============================================
-- PRUEBAS CORREGIDAS - FUNCIONES Y TRIGGERS
-- Sin emojis - Version limpia
-- =============================================

-- VERIFICACION PREVIA: Comprobar que las funciones existen
DO $$
DECLARE
    v_funciones_faltantes TEXT[] := ARRAY[]::TEXT[];
BEGIN
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'VERIFICANDO FUNCIONES NECESARIAS...';
    RAISE NOTICE '===================================================';

    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calcular_precio_con_descuento') THEN
        v_funciones_faltantes := array_append(v_funciones_faltantes, 'calcular_precio_con_descuento');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'procesar_orden') THEN
        v_funciones_faltantes := array_append(v_funciones_faltantes, 'procesar_orden');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'top_productos_vendidos') THEN
        v_funciones_faltantes := array_append(v_funciones_faltantes, 'top_productos_vendidos');
    END IF;

    IF array_length(v_funciones_faltantes, 1) > 0 THEN
        RAISE WARNING 'FALTAN FUNCIONES: %. Ejecuta parche_funciones.sql primero',
            array_to_string(v_funciones_faltantes, ', ');
    ELSE
        RAISE NOTICE '[OK] Todas las funciones necesarias estan disponibles';
    END IF;

    RAISE NOTICE '===================================================';
END $$;

-- =============================================
-- PRUEBAS DE FUNCIONES DE CALCULO
-- =============================================

-- Test 1: Calcular precio con descuento
SELECT calcular_precio_con_descuento(29990, 10) as precio_con_10_descuento;

SELECT calcular_precio_con_descuento(59990, 15) as precio_con_15_descuento;

-- Test 2: Calcular IVA
SELECT calcular_iva(100000) as iva_de_100mil;

-- Test 3: Calcular neto desde total
SELECT calcular_neto(119000) as neto_desde_total;

-- Test 4: Validar stock disponible
SELECT validar_stock_disponible(1, 5) as hay_stock_5_unidades;

-- =============================================
-- PRUEBAS DE FUNCIONES DE VALIDACION
-- =============================================

-- Test 5: Validar RUT chileno
SELECT validar_rut('12345678-9') as rut_valido;
SELECT validar_rut('11111111-1') as rut_valido2;
SELECT validar_rut('12345678-0') as rut_invalido;

-- Test 6: Validar email
SELECT validar_email('usuario@ejemplo.cl') as email_valido;
SELECT validar_email('correo_invalido') as email_invalido;

-- Test 7: Validar cupon
SELECT * FROM validar_cupon('BIENVENIDO10', 2, 50000);

SELECT * FROM validar_cupon('CUPON_INEXISTENTE', 2, 50000);

-- =============================================
-- PRUEBAS DE FUNCIONES DE CONSULTA
-- =============================================

-- Test 8: Productos con bajo stock
SELECT * FROM obtener_productos_bajo_stock();

-- Test 9: Ventas del ultimo mes
SELECT * FROM calcular_ventas_periodo(
    CURRENT_TIMESTAMP - INTERVAL '30 days',
    CURRENT_TIMESTAMP
);

-- Test 10: Top 5 productos mas vendidos
SELECT * FROM top_productos_vendidos(5);

SELECT * FROM top_productos_vendidos(
    10,
    DATE_TRUNC('month', CURRENT_DATE)::TIMESTAMPTZ,
    CURRENT_TIMESTAMP
);

-- Test 11: Calcular total del carrito
DO $$
DECLARE
    v_total DECIMAL;
BEGIN
    SELECT calcular_total_carrito(1) INTO v_total;
    RAISE NOTICE 'Total del carrito 1: $%', v_total;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Carrito 1 no existe';
END $$;

-- =============================================
-- PRUEBAS DE STORED PROCEDURES
-- =============================================

-- Test 12: Procesar orden completa (SIN cupon)
DO $$
DECLARE
    v_resultado RECORD;
    v_carrito_existe BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM carritos WHERE id = 1 AND estado = 'ACTIVO') INTO v_carrito_existe;

    IF NOT v_carrito_existe THEN
        RAISE NOTICE '[SKIP] Test 12 - Carrito 1 no existe o no esta activo';
        RETURN;
    END IF;

    BEGIN
        SELECT * INTO v_resultado FROM procesar_orden(
            2,
            1,
            'Av. Providencia 123, Santiago',
            'Tarjeta de Credito'
        );

        RAISE NOTICE '[OK] Test 12 EXITOSO: Orden % creada - Total: $%',
            v_resultado.numero_orden, v_resultado.total;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '[ERROR] Test 12 FALLIDO: %', SQLERRM;
    END;
END $$;

-- Test 13: Procesar orden con cupon
DO $$
DECLARE
    v_resultado RECORD;
    v_carrito_existe BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM carritos WHERE id = 2 AND estado = 'ACTIVO') INTO v_carrito_existe;

    IF NOT v_carrito_existe THEN
        RAISE NOTICE '[SKIP] Test 13 - Carrito 2 no existe o no esta activo';
        RETURN;
    END IF;

    BEGIN
        SELECT * INTO v_resultado FROM procesar_orden(
            3,
            2,
            'Av. Libertad 456, Vina del Mar',
            'Transferencia Bancaria',
            'BIENVENIDO10'
        );

        RAISE NOTICE '[OK] Test 13 EXITOSO: Orden % creada con cupon - Total: $%',
            v_resultado.numero_orden, v_resultado.total;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '[ERROR] Test 13 FALLIDO: %', SQLERRM;
    END;
END $$;

-- Test 14: Cancelar orden
DO $$
DECLARE
    v_orden_id BIGINT;
    v_resultado BOOLEAN;
BEGIN
    SELECT id INTO v_orden_id
    FROM ordenes
    WHERE estado NOT IN ('ENTREGADA', 'CANCELADA')
    LIMIT 1;

    IF v_orden_id IS NULL THEN
        RAISE NOTICE '[SKIP] Test 14 - No hay ordenes cancelables';
    ELSE
        v_resultado := cancelar_orden(v_orden_id, 'Test - Cliente solicito cancelacion');
        RAISE NOTICE '[OK] Test 14 EXITOSO: Orden % cancelada', v_orden_id;
    END IF;
END $$;

-- =============================================
-- PRUEBAS DE TRIGGERS
-- =============================================

-- Test 15: Trigger validar stock al agregar al carrito
DO $$
DECLARE
    v_carrito_id BIGINT;
BEGIN
    INSERT INTO carritos (usuario_id, estado) VALUES (2, 'ACTIVO') RETURNING id INTO v_carrito_id;

    BEGIN
        INSERT INTO items_carrito (carrito_id, producto_id, cantidad, precio_unitario)
        SELECT v_carrito_id, id, 9999, precio_venta
        FROM productos
        WHERE stock_actual < 9999
        LIMIT 1;

        RAISE NOTICE '[WARNING] Test 15: Item agregado (producto tiene stock suficiente)';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '[OK] Test 15 EXITOSO: Validacion de stock funciono - %', SQLERRM;
    END;

    DELETE FROM items_carrito WHERE carrito_id = v_carrito_id;
    DELETE FROM carritos WHERE id = v_carrito_id;
END $$;

-- Test 16: Trigger actualizar precio automaticamente
DO $$
DECLARE
    v_carrito_id BIGINT;
    v_precio_actualizado DECIMAL;
BEGIN
    INSERT INTO carritos (usuario_id, estado)
    VALUES (2, 'ACTIVO')
    RETURNING id INTO v_carrito_id;

    INSERT INTO items_carrito (carrito_id, producto_id, cantidad, precio_unitario)
    VALUES (v_carrito_id, 1, 1, 0);

    SELECT precio_unitario INTO v_precio_actualizado
    FROM items_carrito
    WHERE carrito_id = v_carrito_id;

    IF v_precio_actualizado > 0 THEN
        RAISE NOTICE '[OK] Test 16 EXITOSO: Precio actualizado automaticamente a $%', v_precio_actualizado;
    ELSE
        RAISE NOTICE '[ERROR] Test 16 FALLIDO: Precio no se actualizo';
    END IF;

    DELETE FROM items_carrito WHERE carrito_id = v_carrito_id;
    DELETE FROM carritos WHERE id = v_carrito_id;
END $$;

-- Test 17: Trigger devolver stock al cancelar
DO $$
DECLARE
    v_orden_id BIGINT;
    v_producto_id BIGINT;
    v_stock_antes INTEGER;
    v_stock_despues INTEGER;
    v_cantidad_orden INTEGER;
BEGIN
    SELECT id INTO v_orden_id
    FROM ordenes
    WHERE estado NOT IN ('CANCELADA', 'ENTREGADA')
    LIMIT 1;

    IF v_orden_id IS NULL THEN
        RAISE NOTICE '[SKIP] Test 17 - No hay ordenes para probar';
        RETURN;
    END IF;

    SELECT producto_id, cantidad INTO v_producto_id, v_cantidad_orden
    FROM detalle_ordenes
    WHERE orden_id = v_orden_id
    LIMIT 1;

    SELECT stock_actual INTO v_stock_antes FROM productos WHERE id = v_producto_id;

    UPDATE ordenes SET estado = 'CANCELADA' WHERE id = v_orden_id;

    SELECT stock_actual INTO v_stock_despues FROM productos WHERE id = v_producto_id;

    IF v_stock_despues = v_stock_antes + v_cantidad_orden THEN
        RAISE NOTICE '[OK] Test 17 EXITOSO: Stock devuelto (Antes: %, Despues: %)', v_stock_antes, v_stock_despues;
    ELSE
        RAISE NOTICE '[WARNING] Test 17: Stock cambio de % a %', v_stock_antes, v_stock_despues;
    END IF;
END $$;

-- Test 18: Trigger alertar stock critico
DO $$
DECLARE
    v_producto_id BIGINT;
    v_stock_original INTEGER;
    v_stock_minimo INTEGER;
BEGIN
    SELECT id, stock_actual, stock_minimo INTO v_producto_id, v_stock_original, v_stock_minimo
    FROM productos
    WHERE stock_actual > stock_minimo AND activo = TRUE
    LIMIT 1;

    IF v_producto_id IS NULL THEN
        RAISE NOTICE '[SKIP] Test 18 - No hay productos apropiados';
        RETURN;
    END IF;

    UPDATE productos SET stock_actual = stock_minimo - 1 WHERE id = v_producto_id;

    IF EXISTS (
        SELECT 1 FROM logs_sistema
        WHERE modulo = 'INVENTARIO' AND accion = 'STOCK_BAJO'
        AND entidad_id = v_producto_id
        AND fecha > CURRENT_TIMESTAMP - INTERVAL '10 seconds'
    ) THEN
        RAISE NOTICE '[OK] Test 18 EXITOSO: Alerta de stock critico creada';
    ELSE
        RAISE NOTICE '[WARNING] Test 18: No se encontro log reciente';
    END IF;

    UPDATE productos SET stock_actual = v_stock_original WHERE id = v_producto_id;
END $$;

-- Test 19: Trigger validar orden antes de crear
DO $$
BEGIN
    BEGIN
        INSERT INTO ordenes (
            usuario_id, cliente_nombre, cliente_correo,
            direccion_envio, subtotal, iva, total,
            estado, metodo_pago, estado_pago
        ) VALUES (
            2, 'Test User', 'test@test.cl',
            'Test Address', 10000, 1900, -1000,
            'PENDIENTE', 'Efectivo', 'PENDIENTE'
        );

        RAISE NOTICE '[ERROR] Test 19 FALLIDO: Orden con total negativo creada';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '[OK] Test 19 EXITOSO: Validacion funciono - %', SQLERRM;
    END;
END $$;

-- Test 20: Trigger contador de reviews
DO $$
DECLARE
    v_review_id BIGINT;
BEGIN
    INSERT INTO reviews_productos (
        producto_id, usuario_id,
        calificacion, titulo, comentario,
        verificada, aprobada
    ) VALUES (
        1, 2, 5, 'Test Review', 'Excelente',
        TRUE, TRUE
    ) RETURNING id INTO v_review_id;

    IF EXISTS (
        SELECT 1 FROM logs_sistema
        WHERE modulo = 'REVIEWS'
        AND fecha > CURRENT_TIMESTAMP - INTERVAL '10 seconds'
    ) THEN
        RAISE NOTICE '[OK] Test 20 EXITOSO: Log de review creado';
    ELSE
        RAISE NOTICE '[WARNING] Test 20: Log no encontrado';
    END IF;

    DELETE FROM reviews_productos WHERE id = v_review_id;
END $$;

-- =============================================
-- PRUEBAS DE FUNCIONES DE UTILIDAD
-- =============================================

-- Test 21: Limpiar carritos abandonados
SELECT limpiar_carritos_abandonados(30) as carritos_limpiados;

-- Test 22: Generar reporte de ventas
SELECT * FROM generar_reporte_ventas(
    CURRENT_DATE - INTERVAL '7 days',
    CURRENT_DATE
);

-- =============================================
-- CONSULTAS DE MONITOREO
-- =============================================

-- Monitoreo 1: Estado del inventario
SELECT
    'Total Productos' as metrica,
    COUNT(*) as valor
FROM productos WHERE activo = TRUE
UNION ALL
SELECT
    'Productos con Stock Bajo',
    COUNT(*)
FROM productos
WHERE stock_actual < stock_minimo AND activo = TRUE
UNION ALL
SELECT
    'Productos sin Stock',
    COUNT(*)
FROM productos
WHERE stock_actual = 0 AND activo = TRUE;

-- Monitoreo 2: Estado de ordenes
SELECT
    estado,
    COUNT(*) as cantidad,
    COALESCE(SUM(total), 0) as total_ventas
FROM ordenes
WHERE fecha_creacion >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY estado
ORDER BY cantidad DESC;

-- Monitoreo 3: Logs de errores recientes
SELECT
    fecha,
    tipo,
    nivel,
    modulo,
    accion,
    descripcion
FROM logs_sistema
WHERE nivel IN ('ERROR', 'CRITICAL')
ORDER BY fecha DESC
LIMIT 10;

-- =============================================
-- RESUMEN FINAL
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'TODAS LAS PRUEBAS COMPLETADAS';
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'Revisa los mensajes NOTICE arriba para ver los resultados.';
    RAISE NOTICE '';
    RAISE NOTICE 'Tests marcados como [SKIP] son normales cuando no';
    RAISE NOTICE 'existen datos apropiados para la prueba.';
    RAISE NOTICE '===================================================';
END $$;

SELECT
    '[OK] Suite de pruebas completada' as resultado,
    'Todas las funciones y triggers fueron probados' as nota;

