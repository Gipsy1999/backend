git -- =============================================
-- VERIFICAR Y CORREGIR USUARIO ADMIN
-- =============================================

-- Paso 1: Verificar si el usuario admin existe
SELECT id, correo, rol, activo, verificado, password
FROM usuarios
WHERE correo = 'admin@levelup.cl';

-- Paso 2: Si existe, actualizar con el hash correcto de BCrypt para "admin123"
-- Hash BCrypt de "admin123": $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

UPDATE usuarios
SET
    password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    activo = TRUE,
    verificado = TRUE,
    intentos_fallidos = 0,
    bloqueado_hasta = NULL
WHERE correo = 'admin@levelup.cl';

-- Paso 3: Verificar la actualización
SELECT id, correo, rol, activo, verificado,
       LEFT(password, 20) as password_inicio,
       intentos_fallidos, bloqueado_hasta
FROM usuarios
WHERE correo = 'admin@levelup.cl';

-- Paso 4: Si NO existe, crear el usuario admin
INSERT INTO usuarios (
    run, nombre, apellidos, correo, password, telefono,
    direccion, comuna, ciudad, region, fecha_nacimiento,
    rol, activo, verificado
)
SELECT
    '12345678-9', 'Admin', 'Level Up', 'admin@levelup.cl',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    '912345678', 'Av. Providencia 123', 'Providencia',
    'Santiago', 'Región Metropolitana', '1990-01-01',
    'ADMIN', TRUE, TRUE
WHERE NOT EXISTS (
    SELECT 1 FROM usuarios WHERE correo = 'admin@levelup.cl'
);

-- Paso 5: Verificación final
SELECT
    id,
    correo,
    rol,
    activo,
    verificado,
    LEFT(password, 30) as password_hash,
    fecha_registro
FROM usuarios
WHERE correo = 'admin@levelup.cl';

-- =============================================
-- INFORMACIÓN IMPORTANTE
-- =============================================
-- Usuario: admin@levelup.cl
-- Password: admin123
-- Rol: ADMIN
-- Hash BCrypt: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
-- =============================================

