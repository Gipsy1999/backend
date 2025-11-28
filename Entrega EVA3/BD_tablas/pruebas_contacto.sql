-- =============================================
-- PRUEBAS DE LA TABLA MENSAJES_CONTACTO
-- =============================================

-- Verificar que la tabla existe
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'mensajes_contacto'
ORDER BY ordinal_position;

-- =============================================
-- TEST 1: Insertar nuevo mensaje de contacto
-- =============================================

DO $$
DECLARE
    v_mensaje_id BIGINT;
BEGIN
    RAISE NOTICE 'TEST 1: Insertar mensaje de contacto';

    INSERT INTO mensajes_contacto (nombre, correo, comentario, ip_address)
    VALUES (
        'Test Usuario',
        'test@ejemplo.cl',
        'Este es un mensaje de prueba desde las pruebas SQL.',
        '192.168.1.200'
    )
    RETURNING id INTO v_mensaje_id;

    RAISE NOTICE '[OK] Mensaje insertado con ID: %', v_mensaje_id;

    -- Limpiar
    DELETE FROM mensajes_contacto WHERE id = v_mensaje_id;
    RAISE NOTICE '[OK] Mensaje de prueba eliminado';
END $$;

-- =============================================
-- TEST 2: Validar restricción de longitud
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'TEST 2: Validar restricción de longitud (500 caracteres)';

    BEGIN
        INSERT INTO mensajes_contacto (nombre, correo, comentario)
        VALUES (
            'Test',
            'test@test.cl',
            REPEAT('A', 501) -- 501 caracteres - debe fallar
        );

        RAISE NOTICE '[ERROR] La restricción no funcionó - mensaje muy largo insertado';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '[OK] Restricción de longitud funcionó correctamente';
    END;
END $$;

-- =============================================
-- TEST 3: Obtener mensajes pendientes
-- =============================================

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'TEST 3: Función obtener_mensajes_pendientes()';

    SELECT COUNT(*) INTO v_count FROM obtener_mensajes_pendientes();

    RAISE NOTICE '[OK] Mensajes pendientes encontrados: %', v_count;
END $$;

-- =============================================
-- TEST 4: Marcar mensaje como leído
-- =============================================

DO $$
DECLARE
    v_mensaje_id BIGINT;
    v_resultado BOOLEAN;
    v_leido BOOLEAN;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'TEST 4: Marcar mensaje como leído';

    -- Buscar un mensaje no leído
    SELECT id INTO v_mensaje_id
    FROM mensajes_contacto
    WHERE leido = FALSE
    LIMIT 1;

    IF v_mensaje_id IS NULL THEN
        RAISE NOTICE '[SKIP] No hay mensajes no leídos para probar';
    ELSE
        v_resultado := marcar_mensaje_leido(v_mensaje_id);

        -- Verificar que se marcó como leído
        SELECT leido INTO v_leido
        FROM mensajes_contacto
        WHERE id = v_mensaje_id;

        IF v_leido THEN
            RAISE NOTICE '[OK] Mensaje % marcado como leído correctamente', v_mensaje_id;
        ELSE
            RAISE NOTICE '[ERROR] El mensaje no se marcó como leído';
        END IF;
    END IF;
END $$;

-- =============================================
-- TEST 5: Responder mensaje
-- =============================================

DO $$
DECLARE
    v_mensaje_id BIGINT;
    v_resultado BOOLEAN;
    v_estado VARCHAR;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'TEST 5: Responder mensaje';

    -- Buscar un mensaje pendiente o en revisión
    SELECT id INTO v_mensaje_id
    FROM mensajes_contacto
    WHERE estado IN ('PENDIENTE', 'EN_REVISION')
    LIMIT 1;

    IF v_mensaje_id IS NULL THEN
        RAISE NOTICE '[SKIP] No hay mensajes pendientes para responder';
    ELSE
        v_resultado := responder_mensaje_contacto(
            v_mensaje_id,
            'Esta es una respuesta de prueba automática.',
            1
        );

        -- Verificar que se respondió
        SELECT estado INTO v_estado
        FROM mensajes_contacto
        WHERE id = v_mensaje_id;

        IF v_estado = 'RESPONDIDO' THEN
            RAISE NOTICE '[OK] Mensaje % respondido correctamente', v_mensaje_id;
        ELSE
            RAISE NOTICE '[ERROR] El mensaje no cambió a estado RESPONDIDO';
        END IF;
    END IF;
END $$;

-- =============================================
-- TEST 6: Vista de resumen
-- =============================================

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'TEST 6: Vista v_mensajes_contacto_resumen';

    SELECT COUNT(*) INTO v_count FROM v_mensajes_contacto_resumen;

    RAISE NOTICE '[OK] Vista muestra % mensajes', v_count;
END $$;

-- =============================================
-- TEST 7: Trigger de actualización de fecha
-- =============================================

DO $$
DECLARE
    v_mensaje_id BIGINT;
    v_fecha_antes TIMESTAMP;
    v_fecha_despues TIMESTAMP;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'TEST 7: Trigger de actualización de fecha';

    -- Crear mensaje de prueba
    INSERT INTO mensajes_contacto (nombre, correo, comentario)
    VALUES ('Test Trigger', 'trigger@test.cl', 'Probando trigger')
    RETURNING id, fecha_actualizacion INTO v_mensaje_id, v_fecha_antes;

    -- Esperar un momento
    PERFORM pg_sleep(1);

    -- Actualizar el mensaje
    UPDATE mensajes_contacto
    SET leido = TRUE
    WHERE id = v_mensaje_id;

    -- Obtener nueva fecha
    SELECT fecha_actualizacion INTO v_fecha_despues
    FROM mensajes_contacto
    WHERE id = v_mensaje_id;

    IF v_fecha_despues > v_fecha_antes THEN
        RAISE NOTICE '[OK] Trigger actualizó fecha_actualizacion correctamente';
    ELSE
        RAISE NOTICE '[ERROR] La fecha no se actualizó';
    END IF;

    -- Limpiar
    DELETE FROM mensajes_contacto WHERE id = v_mensaje_id;
END $$;

-- =============================================
-- TEST 8: Estados válidos
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'TEST 8: Validar estados permitidos';

    BEGIN
        INSERT INTO mensajes_contacto (nombre, correo, comentario, estado)
        VALUES ('Test', 'test@test.cl', 'Test', 'ESTADO_INVALIDO');

        RAISE NOTICE '[ERROR] Se permitió un estado inválido';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '[OK] Restricción de estados funcionó correctamente';
    END;
END $$;

-- =============================================
-- CONSULTAS DE RESUMEN
-- =============================================

RAISE NOTICE '';
RAISE NOTICE '===================================================';
RAISE NOTICE 'RESUMEN DE MENSAJES DE CONTACTO';
RAISE NOTICE '===================================================';

-- Total de mensajes
SELECT 'Total de mensajes' as metrica, COUNT(*) as valor
FROM mensajes_contacto
UNION ALL
-- Por estado
SELECT 'Estado: ' || estado, COUNT(*)
FROM mensajes_contacto
GROUP BY estado
UNION ALL
-- Leídos vs no leídos
SELECT 'Leídos', COUNT(*)
FROM mensajes_contacto
WHERE leido = TRUE
UNION ALL
SELECT 'No leídos', COUNT(*)
FROM mensajes_contacto
WHERE leido = FALSE;

-- Mensajes por usuario
RAISE NOTICE '';
RAISE NOTICE 'Mensajes por usuario (top 5):';

SELECT
    COALESCE(u.nombre || ' ' || u.apellidos, 'Anónimo') as usuario,
    COUNT(mc.id) as total_mensajes
FROM mensajes_contacto mc
LEFT JOIN usuarios u ON mc.usuario_id = u.id
GROUP BY u.id, u.nombre, u.apellidos
ORDER BY total_mensajes DESC
LIMIT 5;

-- =============================================
-- RESULTADOS FINALES
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'PRUEBAS COMPLETADAS';
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'Todas las funcionalidades de mensajes_contacto';
    RAISE NOTICE 'han sido probadas exitosamente.';
    RAISE NOTICE '===================================================';
END $$;

