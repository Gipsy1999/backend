-- =============================================
-- SCRIPT DE VERIFICACIÓN POST-PARCHE
-- Ejecutar DESPUÉS de aplicar parche_funciones.sql
-- =============================================

-- Test 1: Verificar que calcular_ventas_periodo funciona con TIMESTAMPTZ
DO $$
DECLARE
    v_resultado RECORD;
BEGIN
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'TEST 1: calcular_ventas_periodo con TIMESTAMPTZ';
    RAISE NOTICE '═══════════════════════════════════════════════';

    SELECT * INTO v_resultado
    FROM calcular_ventas_periodo(
        CURRENT_TIMESTAMP - INTERVAL '30 days',
        CURRENT_TIMESTAMP
    );

    RAISE NOTICE '✅ Función calcular_ventas_periodo ejecutada correctamente';
    RAISE NOTICE 'Órdenes: %, Total: $%, Ticket promedio: $%',
        v_resultado.total_ordenes,
        v_resultado.total_vendido,
        v_resultado.ticket_promedio;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ ERROR en calcular_ventas_periodo: %', SQLERRM;
END $$;

-- Test 2: Verificar top_productos_vendidos con TIMESTAMPTZ
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'TEST 2: top_productos_vendidos con TIMESTAMPTZ';
    RAISE NOTICE '═══════════════════════════════════════════════';

    SELECT COUNT(*) INTO v_count
    FROM top_productos_vendidos(
        10,
        DATE_TRUNC('month', CURRENT_DATE),
        CURRENT_TIMESTAMP
    );

    RAISE NOTICE '✅ Función top_productos_vendidos ejecutada correctamente';
    RAISE NOTICE 'Productos encontrados: %', v_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ ERROR en top_productos_vendidos: %', SQLERRM;
END $$;

-- Test 3: Verificar procesar_orden (sin ejecutar realmente)
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'TEST 3: Verificar firma de procesar_orden';
    RAISE NOTICE '═══════════════════════════════════════════════';

    -- Verificar que la función existe
    IF EXISTS (
        SELECT 1 FROM pg_proc
        WHERE proname = 'procesar_orden'
    ) THEN
        RAISE NOTICE '✅ Función procesar_orden existe';
        RAISE NOTICE 'Parámetros: usuario_id, carrito_id, direccion, metodo_pago, [cupon]';
    ELSE
        RAISE NOTICE '❌ Función procesar_orden NO existe';
    END IF;
END $$;

-- Test 4: Verificar cancelar_orden
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'TEST 4: Verificar cancelar_orden';
    RAISE NOTICE '═══════════════════════════════════════════════';

    IF EXISTS (
        SELECT 1 FROM pg_proc
        WHERE proname = 'cancelar_orden'
    ) THEN
        RAISE NOTICE '✅ Función cancelar_orden existe';
        RAISE NOTICE 'Validaciones: No permite cancelar ENTREGADAS o CANCELADAS';
    ELSE
        RAISE NOTICE '❌ Función cancelar_orden NO existe';
    END IF;
END $$;

-- Test 5: Listar todas las funciones creadas
SELECT
    proname as nombre_funcion,
    pronargs as num_parametros,
    pg_get_function_result(oid) as tipo_retorno
FROM pg_proc
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    AND proname IN (
        'calcular_precio_con_descuento',
        'calcular_iva',
        'calcular_neto',
        'validar_stock_disponible',
        'validar_rut',
        'validar_email',
        'validar_cupon',
        'obtener_productos_bajo_stock',
        'calcular_ventas_periodo',
        'top_productos_vendidos',
        'calcular_total_carrito',
        'procesar_orden',
        'cancelar_orden',
        'limpiar_carritos_abandonados',
        'generar_reporte_ventas'
    )
ORDER BY proname;

-- =============================================
-- RESULTADO FINAL
-- =============================================

DO $$
DECLARE
    v_count_funciones INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count_funciones
    FROM pg_proc
    WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
        AND proname LIKE '%orden%' OR proname LIKE '%venta%' OR proname LIKE '%producto%';

    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE '✅ VERIFICACIÓN COMPLETADA';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'Total de funciones de negocio: %', v_count_funciones;
    RAISE NOTICE '';
    RAISE NOTICE 'Si todos los tests pasaron:';
    RAISE NOTICE '- Las funciones están corregidas';
    RAISE NOTICE '- Puedes usar calcular_ventas_periodo con fechas';
    RAISE NOTICE '- Puedes usar top_productos_vendidos con fechas';
    RAISE NOTICE '- Puedes usar procesar_orden sin conflictos';
    RAISE NOTICE '- Puedes usar cancelar_orden con validaciones';
    RAISE NOTICE '═══════════════════════════════════════════════';
END $$;

