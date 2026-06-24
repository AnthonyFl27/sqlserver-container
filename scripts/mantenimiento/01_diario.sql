-- ============================================================
-- MANTENIMIENTO DIARIO - SQL Server 2025 (CORREGIDO)
-- ============================================================
USE master;
GO

PRINT '--- INICIANDO MANTENIMIENTO DIARIO ---';
GO

-- [DIARIO 1] BACKUP COMPLETO (¡Este ya funcionaba perfecto!)
BACKUP DATABASE gestor_eventos
TO DISK = '/var/opt/mssql/backups/gestor_eventos_FULL.bak'
WITH INIT, COMPRESSION, NAME = 'Backup Diario Completo Gestor Eventos';
GO

-- [DIARIO 2] VERIFICAR ESPACIO EN DISCO (Solucionado el desbordamiento matemático)
SELECT 
    name as Archivo,
    (CAST(size AS BIGINT) * 8) / 1024 as MB_Usado,
    CASE 
        WHEN max_size = -1 THEN 'Ilimitado'
        WHEN max_size = 0 THEN 'No permite crecimiento'
        ELSE CAST((CAST(max_size AS BIGINT) * 8) / 1024 AS VARCHAR) + ' MB'
    END as Tamano_Maximo
FROM sys.master_files
WHERE database_id = DB_ID('gestor_eventos')
ORDER BY name;
GO

-- [DIARIO 3] REVISAR ALERTAS O ERRORES CRÍTICOS (Solucionado error de columna interna)
-- Filtramos por el ID de idioma 1033 (que corresponde a English, por defecto en Docker)
SELECT TOP 20
    message_id AS Error_ID,
    severity AS Severidad,
    text AS Error_Mensaje
FROM sys.messages
WHERE severity >= 16 
  AND language_id = 1033 
ORDER BY message_id DESC;
GO

PRINT '--- MANTENIMIENTO DIARIO FINALIZADO ---';
GO