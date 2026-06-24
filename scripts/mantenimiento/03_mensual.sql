-- ============================================================
-- MANTENIMIENTO MENSUAL - SQL Server 2025
-- ============================================================
USE master;
GO

PRINT '--- INICIANDO MANTENIMIENTO MENSUAL ---';
GO

-- [MENSUAL 1 Y 2] VER TAMAÑO DEL LOG Y CAPACIDAD TOTAL ocupada por la BD
SELECT 
    name as Archivo_Logico,
    type_desc as Tipo_Archivo,
    CAST(size * 8 / 1024 AS DECIMAL(10,2)) as Tamano_MB,
    physical_name as Ruta_Fisica_Contenedor
FROM sys.master_files
WHERE database_id = DB_ID('gestor_eventos');
GO

-- [MENSUAL 3] ESPACIO INTERNO RESERVADO VS UTILIZADO REAL
USE gestor_eventos;
GO
EXEC sp_spaceused;
GO

PRINT '--- MANTENIMIENTO MENSUAL FINALIZADO ---';
GO
