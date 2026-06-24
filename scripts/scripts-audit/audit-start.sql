-- ============================================================
-- REPORTE DE AUDITORÍA DETALLADO Y FÁCIL DE LEER
-- ============================================================

SELECT TOP 50
    -- 1. Formato de hora más limpio
    CONVERT(VARCHAR, event_time, 120) AS [Fecha y Hora (UTC)],
    
    -- 2. Quién lo hizo
    server_principal_name AS [Usuario],
    
    -- 3. Qué hizo (Traducción amigable del action_id)
    CASE 
        WHEN action_id = 'SL'   THEN 'Consultó datos (SELECT)'
        WHEN action_id = 'IN'   THEN 'Insertó datos (INSERT)'
        WHEN action_id = 'UP'   THEN 'Actualizó datos (UPDATE)'
        WHEN action_id = 'DL'   THEN 'Eliminó datos (DELETE)'
        WHEN action_id = 'AUSC' THEN 'Modificó la Auditoría (SYSTEM)'
        WHEN action_id = 'LGIS' THEN 'Inicio de sesión Exitoso (LOGIN)'
        WHEN action_id = 'LGIF' THEN 'Inicio de sesión Fallido (LOGIN)'
        WHEN action_id = 'LIFF' THEN 'Login BD Fallido'
        WHEN action_id = 'LFIL' THEN 'Login Windows/Server Fallido'
        ELSE 'Otra acción (' + action_id + ')'
    END AS [Acción Realizada],
    
    -- 4. Sobre qué objeto
    ISNULL(object_name, 'Todo el Servidor / BD') AS [Objeto / Tabla],
    
    -- 5. ¿Salió bien?
    CASE 
        WHEN succeeded = 1 THEN '✅ Éxito'
        ELSE '❌ Fallido'
    END AS [Resultado],

    -- 6. Detalle técnico de la consulta ejecutada
    ISNULL(statement, '-- No disponible / Acción interna --') AS [Código SQL Ejecutado]

FROM fn_get_audit_file('/var/opt/mssql/user_logs/audit/audit_accesos_servidor_*.sqlaudit', DEFAULT, DEFAULT)
ORDER BY event_time DESC;
GO
