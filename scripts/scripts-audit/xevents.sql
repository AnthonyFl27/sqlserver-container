-- ============================================================
-- 04. CONFIGURACIÓN DE EXTENDED EVENTS - SQL Server 2025
-- ============================================================
USE master;
GO

-- 1. ELIMINAR LA SESIÓN SI YA EXISTE (Para evitar duplicados)
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'monitoreo_esencial')
BEGIN
    DROP SERVER EVENT SESSION monitoreo_esencial ON SERVER;
END
GO

-- 2. CREAR LA SESIÓN DE EXTENDED EVENTS
CREATE SERVER EVENT SESSION monitoreo_esencial ON SERVER 

-- Evento A: Captura consultas completadas que tarden más de 1 segundo (1,000,000 microsegundos)
ADD EVENT sqlserver.sql_statement_completed(    
    ACTION(sqlserver.sql_text, sqlserver.nt_username, sqlserver.client_app_name)    
    WHERE (database_name = N'gestor_eventos' AND duration >= 1000000)
), -- Coma permitida para listar el siguiente evento

-- Evento B: Captura errores del sistema reportados al usuario con severidad alta (>= 16)
ADD EVENT sqlserver.error_reported(    
    ACTION(sqlserver.sql_text, sqlserver.nt_username)    
    WHERE (database_name = N'gestor_eventos' AND severity >= 16)
), -- Coma permitida para listar el siguiente evento

-- Evento C: Captura Deadlocks (Bloqueos mutuos entre transacciones)
ADD EVENT sqlserver.xml_deadlock_report

-- Destino de los datos: Archivo físico binario (.xel) en tu volumen corregido
ADD TARGET package0.event_file(
    SET filename = N'/var/opt/mssql/user_logs/xevents/monitoreo_esencial.xel',
    max_file_size = 5 -- Límite máximo de 5MB por archivo para cuidar el almacenamiento
)
WITH (
    MAX_MEMORY = 4096 KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS, -- Vuelca los datos acumulados a disco cada 30 segundos
    STARTUP_STATE = ON -- Se enciende automáticamente si el contenedor se reinicia
);
GO

-- 3. INICIAR LA SESIÓN DE FORMA INMEDIATA
ALTER SERVER EVENT SESSION monitoreo_esencial ON SERVER STATE = START;
GO

PRINT '------------------------------------------------------------';
PRINT 'Sesión [monitoreo_esencial] iniciada limpiamente sin errores.';
PRINT '------------------------------------------------------------';
GO