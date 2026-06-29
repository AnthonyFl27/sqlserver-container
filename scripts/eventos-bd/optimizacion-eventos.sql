USE gestor_eventos;
GO

---========================================
--- 1. CATALOG TABLES - NORMALIZATION
---========================================

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'StatusCatalog')
CREATE TABLE dbo.StatusCatalog (
    id_status INT PRIMARY KEY IDENTITY(1,1),
    codigo VARCHAR(20) UNIQUE NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    activo BIT DEFAULT 1
);

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PaymentMethodsCatalog')
CREATE TABLE dbo.PaymentMethodsCatalog (
    id_metodo INT PRIMARY KEY IDENTITY(1,1),
    codigo VARCHAR(20) UNIQUE NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    activo BIT DEFAULT 1
);

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'EventStatusCatalog')
CREATE TABLE dbo.EventStatusCatalog (
    id_estado INT PRIMARY KEY IDENTITY(1,1),
    codigo VARCHAR(20) UNIQUE NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    activo BIT DEFAULT 1
);

INSERT INTO dbo.StatusCatalog (codigo, descripcion) 
SELECT 'PAGADO', 'Pago Recibido' WHERE NOT EXISTS (SELECT 1 FROM dbo.StatusCatalog WHERE codigo = 'PAGADO')
UNION ALL SELECT 'PENDIENTE', 'Pago Pendiente' WHERE NOT EXISTS (SELECT 1 FROM dbo.StatusCatalog WHERE codigo = 'PENDIENTE')
UNION ALL SELECT 'CANCELADO', 'Pago Cancelado' WHERE NOT EXISTS (SELECT 1 FROM dbo.StatusCatalog WHERE codigo = 'CANCELADO');

INSERT INTO dbo.PaymentMethodsCatalog (codigo, descripcion)
SELECT 'EFECTIVO', 'Efectivo' WHERE NOT EXISTS (SELECT 1 FROM dbo.PaymentMethodsCatalog WHERE codigo = 'EFECTIVO')
UNION ALL SELECT 'TARJETA', 'Tarjeta de Crédito' WHERE NOT EXISTS (SELECT 1 FROM dbo.PaymentMethodsCatalog WHERE codigo = 'TARJETA')
UNION ALL SELECT 'TRANSFERENCIA', 'Transferencia Bancaria' WHERE NOT EXISTS (SELECT 1 FROM dbo.PaymentMethodsCatalog WHERE codigo = 'TRANSFERENCIA')
UNION ALL SELECT 'CHEQUE', 'Cheque' WHERE NOT EXISTS (SELECT 1 FROM dbo.PaymentMethodsCatalog WHERE codigo = 'CHEQUE');

INSERT INTO dbo.EventStatusCatalog (codigo, descripcion)
SELECT 'PROGRAMADO', 'Evento Programado' WHERE NOT EXISTS (SELECT 1 FROM dbo.EventStatusCatalog WHERE codigo = 'PROGRAMADO')
UNION ALL SELECT 'EN_CURSO', 'Evento en Curso' WHERE NOT EXISTS (SELECT 1 FROM dbo.EventStatusCatalog WHERE codigo = 'EN_CURSO')
UNION ALL SELECT 'FINALIZADO', 'Evento Finalizado' WHERE NOT EXISTS (SELECT 1 FROM dbo.EventStatusCatalog WHERE codigo = 'FINALIZADO')
UNION ALL SELECT 'CANCELADO', 'Evento Cancelado' WHERE NOT EXISTS (SELECT 1 FROM dbo.EventStatusCatalog WHERE codigo = 'CANCELADO');

---========================================
--- 2. AUDIT TABLE - TRACEABILITY
---========================================

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AuditLog')
CREATE TABLE dbo.AuditLog (
    id_audit INT PRIMARY KEY IDENTITY(1,1),
    tabla_nombre VARCHAR(128) NOT NULL,
    operacion VARCHAR(10) NOT NULL CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE')),
    id_registro INT,
    datos_anteriores NVARCHAR(MAX),
    datos_nuevos NVARCHAR(MAX),
    usuario_sistema VARCHAR(128),
    fecha_hora DATETIME2(3) DEFAULT SYSDATETIME(),
    ip_origen VARCHAR(50),
    INDEX IX_AuditLog_Tabla_Fecha (tabla_nombre, fecha_hora DESC)
);

---========================================
--- 3. DATA TYPE OPTIMIZATION
---========================================

-- Reduce VARCHAR(MAX) columns
ALTER TABLE dbo.Eventos ALTER COLUMN descripcion VARCHAR(500);
ALTER TABLE dbo.Proveedores ALTER COLUMN descripcion VARCHAR(500);
ALTER TABLE dbo.Servicios ALTER COLUMN descripcion VARCHAR(500);

---========================================
--- 4. ADD MISSING FK CONSTRAINT & COLUMNS
---========================================

-- Add id_status to Pagos for PaymentMethodsCatalog
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Pagos' AND COLUMN_NAME = 'id_metodo_pago')
ALTER TABLE dbo.Pagos ADD id_metodo_pago INT NULL;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Pagos' AND COLUMN_NAME = 'id_estado_pago')
ALTER TABLE dbo.Pagos ADD id_estado_pago INT NULL;

-- Add id_status to Eventos for EventStatusCatalog
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Eventos' AND COLUMN_NAME = 'id_estado')
ALTER TABLE dbo.Eventos ADD id_estado INT NULL;

-- Add FK constraints for catalog tables
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Pagos_MetodoPago')
ALTER TABLE dbo.Pagos ADD CONSTRAINT FK_Pagos_MetodoPago FOREIGN KEY (id_metodo_pago) REFERENCES dbo.PaymentMethodsCatalog(id_metodo);

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Pagos_EstadoPago')
ALTER TABLE dbo.Pagos ADD CONSTRAINT FK_Pagos_EstadoPago FOREIGN KEY (id_estado_pago) REFERENCES dbo.StatusCatalog(id_status);

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Eventos_Estado')
ALTER TABLE dbo.Eventos ADD CONSTRAINT FK_Eventos_Estado FOREIGN KEY (id_estado) REFERENCES dbo.EventStatusCatalog(id_estado);

---========================================
--- 5. STRATEGIC INDEXES ON FK COLUMNS
---========================================

-- Eventos table
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Eventos_id_cliente')
CREATE NONCLUSTERED INDEX IX_Eventos_id_cliente ON dbo.Eventos(id_cliente);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Eventos_id_lugar')
CREATE NONCLUSTERED INDEX IX_Eventos_id_lugar ON dbo.Eventos(id_lugar);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Eventos_id_estado')
CREATE NONCLUSTERED INDEX IX_Eventos_id_estado ON dbo.Eventos(id_estado);

-- Pagos table
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pagos_id_evento')
CREATE NONCLUSTERED INDEX IX_Pagos_id_evento ON dbo.Pagos(id_evento);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pagos_id_metodo_pago')
CREATE NONCLUSTERED INDEX IX_Pagos_id_metodo_pago ON dbo.Pagos(id_metodo_pago);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pagos_id_estado_pago')
CREATE NONCLUSTERED INDEX IX_Pagos_id_estado_pago ON dbo.Pagos(id_estado_pago);

-- Eventos_Organizadores table
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_EventosOrganizadores_id_organizador')
CREATE NONCLUSTERED INDEX IX_EventosOrganizadores_id_organizador ON dbo.Eventos_Organizadores(id_organizador);

-- Eventos_Servicios table
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_EventosServicios_id_servicio')
CREATE NONCLUSTERED INDEX IX_EventosServicios_id_servicio ON dbo.Eventos_Servicios(id_servicio);

-- Composite index for schedule lookup
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Eventos_Lugar_Fecha_Hora')
CREATE NONCLUSTERED INDEX IX_Eventos_Lugar_Fecha_Hora ON dbo.Eventos(id_lugar, fecha_evento, hora_inicio, hora_fin);

---========================================
--- 6. OVERLAPPING SCHEDULE VALIDATION TRIGGER
---========================================

IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_ValidateEventSchedule')
DROP TRIGGER dbo.trg_ValidateEventSchedule;
GO

CREATE TRIGGER dbo.trg_ValidateEventSchedule ON dbo.Eventos
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN dbo.Eventos e ON i.id_lugar = e.id_lugar 
            AND i.id_evento <> e.id_evento
            AND i.fecha_evento = e.fecha_evento
            AND i.id_estado NOT IN (SELECT id_estado FROM dbo.EventStatusCatalog WHERE codigo = 'CANCELADO')
            AND e.id_estado NOT IN (SELECT id_estado FROM dbo.EventStatusCatalog WHERE codigo = 'CANCELADO')
            AND (
                (i.hora_inicio < e.hora_fin OR i.hora_inicio IS NULL)
                AND (i.hora_fin > e.hora_inicio OR i.hora_fin IS NULL)
                OR (e.hora_inicio IS NULL AND e.hora_fin IS NULL)
                OR (i.hora_inicio IS NULL AND i.hora_fin IS NULL)
            )
    )
    BEGIN
        THROW 50001, 'Error: Existe un evento en conflicto de horario en el mismo lugar.', 1;
    END
END;
GO

---========================================
--- 7. AUDIT TRIGGER FOR DATA CHANGES
---========================================

IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_AuditPagos')
DROP TRIGGER dbo.trg_AuditPagos;
GO

CREATE TRIGGER dbo.trg_AuditPagos ON dbo.Pagos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @operacion VARCHAR(10);
    
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        SET @operacion = 'INSERT';
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        SET @operacion = 'UPDATE';
    ELSE
        SET @operacion = 'DELETE';

    INSERT INTO dbo.AuditLog (tabla_nombre, operacion, id_registro, datos_nuevos, datos_anteriores, usuario_sistema, fecha_hora)
    SELECT 
        'Pagos',
        @operacion,
        ISNULL(i.id_pago, d.id_pago),
        (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        SYSTEM_USER,
        SYSDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_pago = d.id_pago;
END;
GO

IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_AuditEventos')
DROP TRIGGER dbo.trg_AuditEventos;
GO

CREATE TRIGGER dbo.trg_AuditEventos ON dbo.Eventos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @operacion VARCHAR(10);
    
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        SET @operacion = 'INSERT';
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        SET @operacion = 'UPDATE';
    ELSE
        SET @operacion = 'DELETE';

    INSERT INTO dbo.AuditLog (tabla_nombre, operacion, id_registro, datos_nuevos, datos_anteriores, usuario_sistema, fecha_hora)
    SELECT 
        'Eventos',
        @operacion,
        ISNULL(i.id_evento, d.id_evento),
        (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        SYSTEM_USER,
        SYSDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_evento = d.id_evento;
END;
GO

---========================================
--- 8. CORE BUSINESS LOGIC STORED PROCEDURES
---========================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_CheckScheduleConflict')
DROP PROCEDURE dbo.sp_CheckScheduleConflict;
GO

CREATE PROCEDURE dbo.sp_CheckScheduleConflict
    @id_lugar INT,
    @fecha_evento DATE,
    @hora_inicio TIME = NULL,
    @hora_fin TIME = NULL,
    @id_evento_excluir INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT COUNT(*) as conflictos
    FROM dbo.Eventos e
    WHERE e.id_lugar = @id_lugar
    AND e.fecha_evento = @fecha_evento
    AND e.id_evento <> ISNULL(@id_evento_excluir, 0)
    AND e.id_estado NOT IN (SELECT id_estado FROM dbo.EventStatusCatalog WHERE codigo = 'CANCELADO')
    AND (
        (@hora_inicio < e.hora_fin OR @hora_inicio IS NULL)
        AND (@hora_fin > e.hora_inicio OR @hora_fin IS NULL)
        OR (e.hora_inicio IS NULL AND e.hora_fin IS NULL)
        OR (@hora_inicio IS NULL AND @hora_fin IS NULL)
    );
END;
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_CreateEvent')
DROP PROCEDURE dbo.sp_CreateEvent;
GO

CREATE PROCEDURE dbo.sp_CreateEvent
    @id_cliente INT,
    @id_lugar INT,
    @nombre_evento VARCHAR(120),
    @fecha_evento DATE,
    @hora_inicio TIME = NULL,
    @hora_fin TIME = NULL,
    @descripcion VARCHAR(500) = NULL,
    @id_estado INT = NULL,
    @id_evento_new INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check for schedule conflicts
        DECLARE @conflictos INT;
        EXEC sp_CheckScheduleConflict @id_lugar, @fecha_evento, @hora_inicio, @hora_fin, NULL;
        
        INSERT INTO dbo.Eventos (id_cliente, id_lugar, nombre_evento, fecha_evento, hora_inicio, hora_fin, descripcion, id_estado, created_at)
        VALUES (@id_cliente, @id_lugar, @nombre_evento, @fecha_evento, @hora_inicio, @hora_fin, @descripcion, 
                ISNULL(@id_estado, (SELECT id_estado FROM dbo.EventStatusCatalog WHERE codigo = 'PROGRAMADO')), GETDATE());
        
        SET @id_evento_new = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_RecordPayment')
DROP PROCEDURE dbo.sp_RecordPayment;
GO

CREATE PROCEDURE dbo.sp_RecordPayment
    @id_evento INT,
    @monto DECIMAL(12,2),
    @id_metodo_pago INT,
    @id_estado_pago INT = NULL,
    @id_pago_new INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM dbo.Eventos WHERE id_evento = @id_evento)
            THROW 50002, 'El evento especificado no existe.', 1;
        
        IF NOT EXISTS (SELECT 1 FROM dbo.PaymentMethodsCatalog WHERE id_metodo = @id_metodo_pago AND activo = 1)
            THROW 50003, 'Método de pago inválido.', 1;
        
        INSERT INTO dbo.Pagos (id_evento, fecha_pago, monto, id_metodo_pago, id_estado_pago)
        VALUES (@id_evento, GETDATE(), @monto, @id_metodo_pago, 
                ISNULL(@id_estado_pago, (SELECT id_status FROM dbo.StatusCatalog WHERE codigo = 'PAGADO')));
        
        SET @id_pago_new = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_UpdateEventStatus')
DROP PROCEDURE dbo.sp_UpdateEventStatus;
GO

CREATE PROCEDURE dbo.sp_UpdateEventStatus
    @id_evento INT,
    @codigo_estado VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @id_estado INT;
        SELECT @id_estado = id_estado FROM dbo.EventStatusCatalog WHERE codigo = @codigo_estado AND activo = 1;
        
        IF @id_estado IS NULL
            THROW 50004, 'Estado inválido.', 1;
        
        UPDATE dbo.Eventos
        SET id_estado = @id_estado
        WHERE id_evento = @id_evento;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_GetEventsByLocation')
DROP PROCEDURE dbo.sp_GetEventsByLocation;
GO

CREATE PROCEDURE dbo.sp_GetEventsByLocation
    @id_lugar INT,
    @fecha_inicio DATE = NULL,
    @fecha_fin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.id_evento,
        e.nombre_evento,
        e.fecha_evento,
        e.hora_inicio,
        e.hora_fin,
        c.nombre + ' ' + c.apellido as cliente,
        l.nombre_lugar,
        es.descripcion as estado,
        e.created_at
    FROM dbo.Eventos e
    JOIN dbo.Clientes c ON e.id_cliente = c.id_cliente
    JOIN dbo.Lugares l ON e.id_lugar = l.id_lugar
    LEFT JOIN dbo.EventStatusCatalog es ON e.id_estado = es.id_estado
    WHERE e.id_lugar = @id_lugar
    AND e.fecha_evento >= ISNULL(@fecha_inicio, e.fecha_evento)
    AND e.fecha_evento <= ISNULL(@fecha_fin, e.fecha_evento)
    ORDER BY e.fecha_evento, e.hora_inicio;
END;
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_GetAuditTrail')
DROP PROCEDURE dbo.sp_GetAuditTrail;
GO

CREATE PROCEDURE dbo.sp_GetAuditTrail
    @tabla_nombre VARCHAR(128) = NULL,
    @fecha_desde DATETIME2 = NULL,
    @fecha_hasta DATETIME2 = NULL,
    @limit INT = 1000
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@limit)
        id_audit,
        tabla_nombre,
        operacion,
        id_registro,
        usuario_sistema,
        fecha_hora,
        datos_anteriores,
        datos_nuevos
    FROM dbo.AuditLog
    WHERE (@tabla_nombre IS NULL OR tabla_nombre = @tabla_nombre)
    AND (fecha_hora >= ISNULL(@fecha_desde, fecha_hora))
    AND (fecha_hora <= ISNULL(@fecha_hasta, fecha_hora))
    ORDER BY fecha_hora DESC;
END;
GO

---========================================
--- 9. UPDATE STATISTICS
---========================================

UPDATE STATISTICS dbo.Eventos;
UPDATE STATISTICS dbo.Pagos;
UPDATE STATISTICS dbo.Eventos_Servicios;
UPDATE STATISTICS dbo.AuditLog;

PRINT 'Optimización completada exitosamente.';

