-- ===== LOGINS (NIVEL SERVIDOR) =====
SELECT 
    'LOGINS' AS tipo,
    name AS usuario,
    type_desc AS tipo_usuario,
    is_disabled AS deshabilitado,
    create_date AS fecha_creacion,
    modify_date AS fecha_modificacion,
    CASE 
        WHEN name = 'sa' THEN 'USUARIO SA'
        ELSE ''
    END AS notas
FROM sys.server_principals
WHERE type IN ('S', 'U') AND name NOT LIKE '##%'
ORDER BY name;

-- ===== PERMISOS A NIVEL SERVIDOR =====
SELECT 
    sp.name AS usuario,
    spr.permission_name AS permiso,
    spr.state_desc AS estado
FROM sys.server_principals sp
LEFT JOIN sys.server_permissions spr ON sp.principal_id = spr.grantee_principal_id
WHERE sp.type IN ('S', 'U') AND sp.name NOT LIKE '##%'
ORDER BY sp.name, spr.permission_name;

-- ===== USUARIOS EN BASE DE DATOS (ACTUAL) =====
SELECT 
    name AS usuario,
    type_desc AS tipo,
    create_date AS fecha_creacion
FROM sys.database_principals
WHERE type IN ('S', 'U', 'G') AND name NOT LIKE '##%'
ORDER BY name;

-- ===== PERMISOS EN BASE DE DATOS (ACTUAL) =====
SELECT 
    dp.name AS usuario,
    dpr.permission_name AS permiso,
    dpr.state_desc AS estado,
    OBJECT_NAME(dpr.major_id) AS objeto
FROM sys.database_principals dp
LEFT JOIN sys.database_permissions dpr ON dp.principal_id = dpr.grantee_principal_id
WHERE dp.type IN ('S', 'U') AND dp.name NOT LIKE '##%'
ORDER BY dp.name, dpr.permission_name;

-- ===== RESUMEN ESTADO SA =====
SELECT 
    name AS usuario,
    is_disabled AS deshabilitado,
    create_date AS fecha_creacion,
    CASE 
        WHEN is_disabled = 1 THEN 'DESHABILITADO'
        WHEN is_disabled = 0 THEN 'HABILITADO'
    END AS estado_actual
FROM sys.server_principals
WHERE name = 'sa';