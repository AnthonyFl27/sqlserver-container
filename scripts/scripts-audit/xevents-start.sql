-- ============================================================
-- 05. ANÁLISIS TÉCNICO DE EXTENDED EVENTS
-- ============================================================
USE master;
GO

PRINT '--- REPORTE DE RENDIMIENTO Y ERRORES (XEVENTS) ---';
GO

-- [REPORTE 1] CONSULTAS LENTAS DETECTADAS (> 1 SEGUNDO)
-- Muestra qué consultas están afectando el rendimiento de la aplicación
SELECT 
    CAST(event_data AS XML).value('(event/@timestamp)[1]', 'DATETIME2') AS [Hora (UTC)],
    CAST(event_data AS XML).value('(event/action[@name="nt_username"]/value)[1]', 'VARCHAR(100)') AS [Usuario],
    CAST(event_data AS XML).value('(event/data[@name="duration"]/value)[1]', 'BIGINT') / 1000000.0 AS [Duración (Segundos)],
    CAST(event_data AS XML).value('(event/data[@name="cpu_time"]/value)[1]', 'BIGINT') / 1000.0 AS [Tiempo CPU (ms)],
    CAST(event_data AS XML).value('(event/action[@name="sql_text"]/value)[1]', 'VARCHAR(MAX)') AS [Consulta Lenta Ejecutada]
FROM sys.fn_xe_file_target_read_file('/var/opt/mssql/user_logs/xevents/monitoreo_esencial*.xel', NULL, NULL, NULL)
WHERE CAST(event_data AS XML).value('(event/@name)[1]', 'VARCHAR(100)') = 'sql_statement_completed'
ORDER BY [Hora (UTC)] DESC;
GO

-- [REPORTE 2] ERRORES CRÍTICOS O EXCEPCIONES CAPTURADAS
-- Muestra fallos de sintaxis, divisiones por cero, o restricciones violadas
SELECT 
    CAST(event_data AS XML).value('(event/@timestamp)[1]', 'DATETIME2') AS [Hora (UTC)],
    CAST(event_data AS XML).value('(event/data[@name="error_number"]/value)[1]', 'INT') AS [Número Error],
    CAST(event_data AS XML).value('(event/data[@name="severity"]/value)[1]', 'INT') AS [Severidad],
    CAST(event_data AS XML).value('(event/data[@name="message"]/value)[1]', 'VARCHAR(MAX)') AS [Mensaje de Error],
    CAST(event_data AS XML).value('(event/action[@name="sql_text"]/value)[1]', 'VARCHAR(MAX)') AS [Consulta Causal]
FROM sys.fn_xe_file_target_read_file('/var/opt/mssql/user_logs/xevents/monitoreo_esencial*.xel', NULL, NULL, NULL)
WHERE CAST(event_data AS XML).value('(event/@name)[1]', 'VARCHAR(100)') = 'error_reported'
ORDER BY [Hora (UTC)] DESC;
GO

-- [REPORTE 3] DIAGRAMA GRÁFICO DE DEADLOCKS (BLOQUEOS MUTUOS)
-- Haz clic en el XML resultante para ver gráficamente qué procesos chocaron
SELECT 
    CAST(event_data AS XML).value('(event/@timestamp)[1]', 'DATETIME2') AS [Hora (UTC)],
    CAST(CAST(event_data AS XML).value('(event/data[@name="xml_report"]/value)[1]', 'VARCHAR(MAX)') AS XML) AS [Esquema_Deadlock_XML]
FROM sys.fn_xe_file_target_read_file('/var/opt/mssql/user_logs/xevents/monitoreo_esencial*.xel', NULL, NULL, NULL)
WHERE CAST(event_data AS XML).value('(event/@name)[1]', 'VARCHAR(100)') = 'xml_deadlock_report'
ORDER BY [Hora (UTC)] DESC;
GO