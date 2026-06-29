USE master;
GO

-- 1. Asegurar que estamos usando la base de datos correcta
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'gestor_eventos')
BEGIN
    ALTER DATABASE gestor_eventos SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    USE gestor_eventos;
END
GO
USE gestor_eventos;
GO

-- ==========================================
-- 2. LIMPIEZA DE OBJETOS PREVIOS (Seguridad)
-- ==========================================
IF OBJECT_ID('dbo.sp_RegistrarPagoCliente', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RegistrarPagoCliente;
GO
IF OBJECT_ID('dbo.v_ReportePagosEventos', 'V') IS NOT NULL DROP VIEW dbo.v_ReportePagosEventos;
GO
IF OBJECT_ID('dbo.fn_ContarPagosPorEvento', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_ContarPagosPorEvento;
GO

-- ==========================================
-- 3. CREACIÓN DE LA VISTA (Views)
-- ==========================================
-- Combina tus tablas usando tus columnas reales: id_pago, nombre_evento, nombre, monto, fecha_pago
CREATE VIEW v_ReportePagosEventos AS
SELECT 
    p.id_pago AS PagoID,
    e.nombre_evento AS NombreEvento,
    c.nombre AS NombreCliente,
    p.monto AS MontoPagado,
    p.fecha_pago AS FechaPago
FROM Pagos p
INNER JOIN Eventos e ON p.id_evento = e.id_evento
INNER JOIN Clientes c ON e.id_cliente = c.id_cliente;
GO

-- ==========================================
-- 4. CREACIÓN DEL PROCEDIMIENTO ALMACENADO (Stored Procedures)
-- ==========================================
-- Inserta datos en tu tabla Pagos respetando tus columnas: id_evento, monto, fecha_pago, metodo_pago, estado_pago
CREATE PROCEDURE sp_RegistrarPagoCliente
    @id_evento INT,
    @monto DECIMAL(10,2),
    @metodo_pago VARCHAR(50),
    @estado_pago VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Pagos (id_evento, monto, fecha_pago, metodo_pago, estado_pago)
    VALUES (@id_evento, @monto, GETDATE(), @metodo_pago, @estado_pago);
    
    PRINT 'Procedimiento ejecutado: Pago registrado correctamente en la tabla Pagos.';
END;
GO

-- ==========================================
-- 5. CREACIÓN DE LA FUNCIÓN ESCALAR (Functions)
-- ==========================================
-- Cuenta los pagos asociados usando tu columna exacta: id_evento
CREATE FUNCTION fn_ContarPagosPorEvento (@id_evento INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalPagos INT;
    
    SELECT @TotalPagos = COUNT(*) 
    FROM Pagos 
    WHERE id_evento = @id_evento;
    
    RETURN @TotalPagos;
END;
GO

PRINT '¡Script ejecutado con éxito! Vista, Procedimiento y Función creados sin errores.';
GO
