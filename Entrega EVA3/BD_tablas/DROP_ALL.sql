-- =============================================
-- SCRIPT DE LIMPIEZA COMPLETA
-- Elimina todas las tablas, funciones, triggers y secuencias
-- USAR CON PRECAUCIÓN - ELIMINA TODOS LOS DATOS
-- =============================================

-- IMPORTANTE: Ejecutar este script ANTES de volver a ejecutar schema_completo.sql

-- =============================================
-- PASO 1: ELIMINAR VISTAS
-- =============================================

DROP VIEW IF EXISTS v_productos_completos CASCADE;
DROP VIEW IF EXISTS v_ordenes_resumen CASCADE;

-- =============================================
-- PASO 2: ELIMINAR TABLAS (en orden inverso de dependencias)
-- CASCADE elimina automáticamente todos los triggers, constraints e índices asociados
-- =============================================

-- Módulo 11: Auditoría
DROP TABLE IF EXISTS logs_sistema CASCADE;

-- Módulo 12: Mensajes de Contacto
DROP TABLE IF EXISTS mensajes_contacto CASCADE;

-- Módulo 10: Devoluciones
DROP TABLE IF EXISTS items_devolucion CASCADE;
DROP TABLE IF EXISTS devoluciones CASCADE;

-- Módulo 9: Reviews
DROP TABLE IF EXISTS reviews_productos CASCADE;

-- Módulo 8: Cupones
DROP TABLE IF EXISTS uso_cupones CASCADE;
DROP TABLE IF EXISTS cupones CASCADE;

-- Módulo 7: Envíos
DROP TABLE IF EXISTS seguimiento_envio CASCADE;
DROP TABLE IF EXISTS envios CASCADE;
DROP TABLE IF EXISTS tarifas_envio CASCADE;
DROP TABLE IF EXISTS transportistas CASCADE;

-- Módulo 6: Documentos Tributarios
DROP TABLE IF EXISTS detalle_documento CASCADE;
DROP TABLE IF EXISTS documentos_tributarios CASCADE;
DROP TABLE IF EXISTS tipo_documento CASCADE;

-- Módulo 5: Pagos
DROP TABLE IF EXISTS pagos CASCADE;
DROP TABLE IF EXISTS metodos_pago CASCADE;

-- Módulo 4: Órdenes
DROP TABLE IF EXISTS seguimiento_orden CASCADE;
DROP TABLE IF EXISTS detalle_ordenes CASCADE;
DROP TABLE IF EXISTS ordenes CASCADE;

-- Módulo 3: Carritos
DROP TABLE IF EXISTS items_carrito CASCADE;
DROP TABLE IF EXISTS carritos CASCADE;

-- Módulo 2: Catálogo e Inventario
DROP TABLE IF EXISTS movimientos_inventario CASCADE;
DROP TABLE IF EXISTS imagenes_producto CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS marcas CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;

-- Módulo 1: Usuarios
DROP TABLE IF EXISTS usuarios CASCADE;

-- =============================================
-- PASO 3: ELIMINAR FUNCIONES
-- =============================================

DROP FUNCTION IF EXISTS actualizar_fecha_modificacion CASCADE;
DROP FUNCTION IF EXISTS generar_numero_orden CASCADE;
DROP FUNCTION IF EXISTS registrar_cambio_estado_orden CASCADE;
DROP FUNCTION IF EXISTS actualizar_stock_venta CASCADE;

-- =============================================
-- PASO 4: ELIMINAR SECUENCIAS
-- =============================================

DROP SEQUENCE IF EXISTS seq_numero_orden CASCADE;

-- =============================================
-- PASO 5: ELIMINAR TIPOS PERSONALIZADOS (si existen)
-- =============================================

DROP TYPE IF EXISTS tipo_rol CASCADE;
DROP TYPE IF EXISTS tipo_estado_orden CASCADE;
DROP TYPE IF EXISTS tipo_estado_pago CASCADE;
DROP TYPE IF EXISTS tipo_movimiento CASCADE;
DROP TYPE IF EXISTS tipo_estado_carrito CASCADE;
DROP TYPE IF EXISTS tipo_descuento CASCADE;
DROP TYPE IF EXISTS tipo_log CASCADE;
DROP TYPE IF EXISTS tipo_nivel_log CASCADE;

-- =============================================
-- VERIFICACIÓN: Ver tablas restantes
-- =============================================

-- Descomentar para verificar que todo se eliminó
-- SELECT table_name
-- FROM information_schema.tables
-- WHERE table_schema = 'public'
-- AND table_type = 'BASE TABLE'
-- ORDER BY table_name;

-- =============================================
-- MENSAJE DE CONFIRMACIÓN
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '✅ Limpieza completa finalizada';
    RAISE NOTICE '📋 Todas las tablas, triggers, funciones y secuencias han sido eliminadas';
    RAISE NOTICE '🔄 Ahora puedes ejecutar schema_completo.sql para reinstalar';
END $$;

-- =============================================
-- FIN DEL SCRIPT DE LIMPIEZA
-- =============================================

