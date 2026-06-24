-- ============================================================
-- MANTENIMIENTO SEMANAL - SQL Server 2025
-- ============================================================
USE master;
GO

PRINT '--- INICIANDO MANTENIMIENTO SEMANAL ---';
GO

-- [SEMANAL 1] VERIFICAR INTEGRIDAD FÍSICA Y LÓGICA (Caja negra / corrupción)
DBCC CHECKDB (gestor_eventos) WITH NO_INFOMSGS;
GO

-- [SEMANAL 2] DETECTAR ÍNDICES FRAGMENTADOS
-- Ejecuta esto para saber si necesitas reconstruir (REBUILD) u reorganizar (REORGANIZE)
USE gestor_eventos;
GO

SELECT 
    OBJECT_NAME(ps.object_id) as Tabla,
    i.name as Indice,
    CAST(ps.avg_fragmentation_in_percent AS DECIMAL(5,2)) as Fragmentacion_Pct,
    CASE 
        WHEN ps.avg_fragmentation_in_percent > 30 THEN '🔴 REQUIERE: ALTER INDEX [' + i.name + '] ON [' + OBJECT_NAME(ps.object_id) + '] REBUILD;'
        WHEN ps.avg_fragmentation_in_percent BETWEEN 10 AND 30 THEN '🟡 REQUIERE: ALTER INDEX [' + i.name + '] ON [' + OBJECT_NAME(ps.object_id) + '] REORGANIZE;'
        ELSE '🟢 OK'
    END as Accion_Recomendada
FROM sys.dm_db_index_physical_stats(DB_ID('gestor_eventos'), NULL, NULL, NULL, 'LIMITED') ps
INNER JOIN sys.indexes i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
WHERE ps.avg_fragmentation_in_percent > 10
    AND ps.index_id > 0
ORDER BY ps.avg_fragmentation_in_percent DESC;
GO

-- [SEMANAL 3] ACTUALIZAR ESTADÍSTICAS (Optimiza las consultas de la aplicación)
EXEC sp_updatestats;
GO

PRINT '--- MANTENIMIENTO SEMANAL FINALIZADO ---';
GO
