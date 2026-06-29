USE msdb;
GO

PRINT '=== 1. ESTADO ACTUAL DEL MOTOR DEL AGENTE ===';
EXEC xp_servicecontrol 'QueryState', 'SQLServerAGENT';
GO

PRINT '=== 2. ÚLTIMOS RESULTADOS (HISTORIAL DE ÉXITOS O FALLOS) ===';
SELECT 
    j.name AS [Nombre del Job],
    h.step_name AS [Paso Ejecutado],
    CASE h.run_status 
        WHEN 0 THEN 'FALLÓ'
        WHEN 1 THEN 'EXITO'
        WHEN 2 THEN 'REINTENTANDO'
        WHEN 3 THEN 'CANCELADO'
    END AS [Resultado],
    -- Formatea la fecha interna a algo legible
    CONVERT(VARCHAR, h.run_date) AS [Fecha (AAAAMMDD)],
    -- Formatea la hora interna para entenderla mejor
    STUFF(STUFF(RIGHT('000000' + CAST(h.run_time AS VARCHAR), 6), 5, 0, ':'), 3, 0, ':') AS [Hora Real Ejecución (UTC)],
    h.message AS [Mensaje del Servidor]
FROM sysjobhistory h
INNER JOIN sysjobs j ON h.job_id = j.job_id
WHERE j.name LIKE 'Job_%' AND h.step_id > 0
ORDER BY h.instance_id DESC;
GO

PRINT '=== 3. PRÓXIMAS EJECUCIONES PROGRAMADAS ===';
SELECT 
    j.name AS [Nombre del Job],
    s.name AS [Nombre del Horario],
    -- Estado actual del job
    CASE j.enabled WHEN 1 THEN 'Habilitado' ELSE 'Deshabilitado' END AS [Estado Job],
    js.next_run_date AS [Próxima Fecha (AAAAMMDD)],
    STUFF(STUFF(RIGHT('000000' + CAST(js.next_run_time AS VARCHAR), 6), 5, 0, ':'), 3, 0, ':') AS [Próxima Hora (UTC)]
FROM sysjobs j
INNER JOIN sysjobschedules js ON j.job_id = js.job_id
INNER JOIN sysschedules s ON js.schedule_id = s.schedule_id
WHERE j.name LIKE 'Job_%';
GO