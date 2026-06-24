-- ============================================================
-- CONFIGURACIÓN DE AUDITORÍA - SQL Server 2025
-- ============================================================

USE master;
GO

-- 1. CREAR LA AUDITORÍA A NIVEL SERVIDOR (Destino del archivo)
-- Apunta directamente a la subcarpeta dentro de tus logs montados
IF NOT EXISTS (SELECT * FROM sys.server_audits WHERE name = 'audit_accesos_servidor')
BEGIN
    CREATE SERVER AUDIT audit_accesos_servidor
    TO FILE ( FILEPATH = '/var/opt/mssql/user_logs/audit/' , MAXSIZE = 10 MB )
    WITH (ON_FAILURE = CONTINUE);
    
    PRINT 'Auditoría a nivel servidor creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La auditoría a nivel servidor ya existe.';
END
GO

-- Asegurar que la auditoría del servidor esté encendida
ALTER SERVER AUDIT audit_accesos_servidor WITH (STATE = ON);
GO

-- 2. HABILITAR AUDITORÍA A NIVEL BASE DE DATOS
USE gestor_eventos;
GO

IF NOT EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = 'audit_basico')
BEGIN
    -- SCHEMA_OBJECT_ACCESS_GROUP captura SELECT, INSERT, UPDATE y DELETE 
    -- en cualquier tabla de esta base de datos por cualquier usuario.
    CREATE DATABASE AUDIT SPECIFICATION audit_basico
    FOR SERVER AUDIT audit_accesos_servidor
    ADD (SCHEMA_OBJECT_ACCESS_GROUP)
    WITH (STATE = ON);
    
    PRINT 'Especificación de auditoría de BD creada y activada.';
END
ELSE
BEGIN
    PRINT 'La especificación de auditoría de BD ya existe.';
END
GO


-- ============================================================
-- VISTAS Y CONSULTAS DE CONTROL (Lectura de archivos .sqlaudit)
-- ============================================================

-- Consulta 1: Ver los últimos 50 eventos generales de acceso a datos
SELECT TOP 50
    event_time as Hora,
    server_principal_name as Usuario,
    action_id as Accion,
    object_name as Objeto_Tabla,
    succeeded as Exitoso
FROM fn_get_audit_file('/var/opt/mssql/user_logs/audit/audit_accesos_servidor_*.sqlaudit', DEFAULT, DEFAULT)
ORDER BY event_time DESC;
GO

-- Consulta 2: Resumen de actividad total por usuario en esta BD
SELECT 
    server_principal_name as Usuario,
    COUNT(*) as Total_Acciones,
    MAX(event_time) as Ultimo_Acceso
FROM fn_get_audit_file('/var/opt/mssql/user_logs/audit/audit_accesos_servidor_*.sqlaudit', DEFAULT, DEFAULT)
WHERE database_name = 'gestor_eventos'
GROUP BY server_principal_name
ORDER BY Total_Acciones DESC;
GO

-- Consulta 3: Filtrar solo operaciones DML (Modificaciones de datos)
SELECT TOP 50
    event_time as Hora,
    server_principal_name as Usuario,
    CASE 
        WHEN action_id = 'IN' THEN 'INSERT'
        WHEN action_id = 'UP' THEN 'UPDATE'
        WHEN action_id = 'DL' THEN 'DELETE'
        WHEN action_id = 'SL' THEN 'SELECT'
        ELSE action_id
    END as Operacion,
    object_name as Tabla
FROM fn_get_audit_file('/var/opt/mssql/user_logs/audit/audit_accesos_servidor_*.sqlaudit', DEFAULT, DEFAULT)
WHERE database_name = 'gestor_eventos'
  AND action_id IN ('IN', 'UP', 'DL')
ORDER BY event_time DESC;
GO

-- Consulta 4: Ver intentos de inicio de sesión fallidos en el Servidor
SELECT TOP 20
    event_time as Hora,
    server_principal_name as Usuario,
    CASE 
        WHEN action_id = 'LIFF' THEN 'Login de Base de Datos Fallido'
        WHEN action_id = 'LFIL' THEN 'Login de Windows/Server Fallido'
        ELSE action_id
    END as Tipo_Fallo
FROM fn_get_audit_file('/var/opt/mssql/user_logs/audit/audit_accesos_servidor_*.sqlaudit', DEFAULT, DEFAULT)
WHERE action_id IN ('LIFF', 'LFIL')
ORDER BY event_time DESC;
GO
