-- CERRAR TODAS LAS CONEXIONES DE SUPABASE (excepto la tuya actual)

-- Ver conexiones activas
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    state_change
FROM pg_stat_activity
WHERE datname = 'postgres'
ORDER BY query_start DESC;

-- Cerrar TODAS las conexiones (excepto la consulta actual)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'postgres'
  AND pid <> pg_backend_pid();

-- Verificar que se cerraron
SELECT COUNT(*) as conexiones_activas
FROM pg_stat_activity
WHERE datname = 'postgres';
