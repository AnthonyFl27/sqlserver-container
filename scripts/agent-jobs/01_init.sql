USE msdb ;
GO

-- ============================================================================
-- TRABAJO 1: MANTENIMIENTO DIARIO + BACKUP COMPLETO (02:00 AM)
-- ============================================================================

-- 1. Crear el contenedor del Job 1
EXEC dbo.sp_add_job  
    @job_name = N'Job_1_Mantenimiento_y_Backup',
    @enabled = 1,
    @description = N'Ejecuta el backup diario completo, revisa espacio en disco y alertas críticas.' ;  
GO  

-- 2. Asignar tu script de mantenimiento como el Paso 1
EXEC sp_add_jobstep  
    @job_name = N'Job_1_Mantenimiento_y_Backup',  
    @step_name = N'Ejecutar Script de Mantenimiento',  
    @subsystem = N'TSQL',  
    @database_name = N'master',  
    @command = N'
    PRINT ''--- INICIANDO MANTENIMIENTO DIARIO ---'';

    -- [TAREA 2 SOLICITADA] BACKUP COMPLETO
    BACKUP DATABASE gestor_eventos
    TO DISK = ''/var/opt/mssql/backups/gestor_eventos_FULL.bak''
    WITH INIT, COMPRESSION, NAME = ''Backup Diario Completo Gestor Eventos'';

    -- [DIARIO 2] VERIFICAR ESPACIO EN DISCO
    SELECT
        name as Archivo,
        (CAST(size AS BIGINT) * 8) / 1024 as MB_Usado,
        CASE
            WHEN max_size = -1 THEN ''Ilimitado''
            WHEN max_size = 0 THEN ''No permite crecimiento''
            ELSE CAST((CAST(max_size AS BIGINT) * 8) / 1024 AS VARCHAR) + '' MB''
        END as Tamano_Maximo
    FROM sys.master_files
    WHERE database_id = DB_ID(''gestor_eventos'')
    ORDER BY name;

    -- [DIARIO 3] REVISAR ALERTAS O ERRORES CRÍTICOS
    SELECT TOP 20
        message_id AS Error_ID,
        severity AS Severidad,
        text AS Error_Mensaje
    FROM sys.messages
    WHERE severity >= 16
      AND language_id = 1033
    ORDER BY message_id DESC;

    PRINT ''--- MANTENIMIENTO DIARIO FINALIZADO ---'';
    ',   
    @retry_attempts = 2,      
    @retry_interval = 10 ;    
GO  

-- 3. Crear el horario diario a las 02:00 AM
EXEC dbo.sp_add_schedule  
    @schedule_name = N'Horario_Diario_2AM',  
    @freq_type = 4,            -- 4 = Diario
    @freq_interval = 1,        -- Cada 1 día
    @active_start_time = 020000 ; -- 02:00:00 AM
GO  

-- 4. Asociar el horario al Job 1
EXEC sp_attach_schedule  
   @job_name = N'Job_1_Mantenimiento_y_Backup',  
   @schedule_name = N'Horario_Diario_2AM';  
GO  

-- 5. Activar el Job 1 en el servidor local
EXEC dbo.sp_add_jobserver  
    @job_name = N'Job_1_Mantenimiento_y_Backup';  
GO

PRINT '>>> ¡Job 1 (Mantenimiento y Backup) creado exitosamente! <<<';
GO


-- ============================================================================
-- TRABAJO 2: [TAREA 3 SOLICITADA] ACTUALIZACIÓN DE ESTADÍSTICAS (04:00 AM)
-- ============================================================================

-- 1. Crear el contenedor del Job 2
EXEC dbo.sp_add_job  
    @job_name = N'Job_2_Actualizacion_Estadisticas',
    @enabled = 1,
    @description = N'Actualiza las estadísticas de la base de datos gestor_eventos para optimizar el rendimiento.' ;  
GO  

-- 2. Asignar el comando de estadísticas como el Paso 1
EXEC sp_add_jobstep  
    @job_name = N'Job_2_Actualizacion_Estadisticas',  
    @step_name = N'Ejecutar sp_updatestats',  
    @subsystem = N'TSQL',  
    @database_name = N'gestor_eventos', -- Se ejecuta directo en tu BD
    @command = N'
    PRINT ''--- INICIANDO ACTUALIZACIÓN DE ESTADÍSTICAS ---'';
    EXEC sp_updatestats;
    PRINT ''--- ACTUALIZACIÓN DE ESTADÍSTICAS FINALIZADA ---'';
    ',   
    @retry_attempts = 1,      
    @retry_interval = 5 ;    
GO  

-- 3. Crear el horario diario a las 04:00 AM
EXEC dbo.sp_add_schedule  
    @schedule_name = N'Horario_Diario_4AM',  
    @freq_type = 4,            -- 4 = Diario
    @freq_interval = 1,        -- Cada 1 día
    @active_start_time = 040000 ; -- 04:00:00 AM
GO  

-- 4. Asociar el horario al Job 2
EXEC sp_attach_schedule  
   @job_name = N'Job_2_Actualizacion_Estadisticas',  
   @schedule_name = N'Horario_Diario_4AM';  
GO  

-- 5. Activar el Job 2 en el servidor local
EXEC dbo.sp_add_jobserver  
    @job_name = N'Job_2_Actualizacion_Estadisticas';  
GO

PRINT '>>> ¡Job 2 (Actualización de Estadísticas) creado exitosamente! <<<';
GO