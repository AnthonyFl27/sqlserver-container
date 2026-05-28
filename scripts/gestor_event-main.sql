---------------------------------------------------------------
-- 1. CREACIÓN DE LA BASE DE DATOS
---------------------------------------------------------------
USE master;
GO

IF DB_ID('gestor_eventos') IS NOT NULL
    DROP DATABASE gestor_eventos;
GO

CREATE DATABASE gestor_eventos;
GO

USE gestor_eventos;
GO


---------------------------------------------------------------
-- 2. CREACIÓN DE TABLAS (SOLO COLUMNAS)
---------------------------------------------------------------

/* =========================
   TABLA: CLIENTES
   ========================= */
CREATE TABLE Clientes (
    id_cliente INT IDENTITY(1,1),
    nombre     VARCHAR(100) NOT NULL,
    apellido   VARCHAR(100) NOT NULL,
    direccion  VARCHAR(150)
);

/* =========================
   TABLA: LUGARES
   ========================= */
CREATE TABLE Lugares (
    id_lugar      INT IDENTITY(1,1),
    nombre_lugar  VARCHAR(100) NOT NULL,
    direccion     VARCHAR(150),
    capacidad     INT,
    tipo_lugar    VARCHAR(50)
);

/* =========================
   TABLA: ORGANIZADORES
   ========================= */
CREATE TABLE Organizadores (
    id_organizador INT IDENTITY(1,1),
    nombre         VARCHAR(100) NOT NULL,
    apellido       VARCHAR(100) NOT NULL,
    rol            VARCHAR(50),
    telefono       VARCHAR(20)
);

/* =========================
   TABLA: PROVEEDORES
   ========================= */
CREATE TABLE Proveedores (
    id_proveedor   INT IDENTITY(1,1),
    nombre_empresa VARCHAR(120) NOT NULL,
    descripcion    VARCHAR(MAX)
);

/* =========================
   TABLA: SERVICIOS
   ========================= */
CREATE TABLE Servicios (
    id_servicio     INT IDENTITY(1,1),
    id_proveedor    INT NOT NULL,
    nombre_servicio VARCHAR(120) NOT NULL,
    descripcion     VARCHAR(MAX),
    costo           DECIMAL(12,2) NOT NULL,
    created_at      DATETIME DEFAULT GETDATE()
);

/* =========================
   TABLA: EVENTOS
   ========================= */
CREATE TABLE Eventos (
    id_evento     INT IDENTITY(1,1),
    id_cliente    INT NOT NULL,
    id_lugar      INT NOT NULL,
    nombre_evento VARCHAR(120) NOT NULL,
    fecha_evento  DATE NOT NULL,
    hora_inicio   TIME,
    hora_fin      TIME,
    descripcion   VARCHAR(MAX),
    estado        VARCHAR(30),
    created_at    DATETIME DEFAULT GETDATE()
);

/* =========================
   TABLA: PAGOS
   ========================= */
CREATE TABLE Pagos (
    id_pago     INT IDENTITY(1,1),
    id_evento   INT NOT NULL,
    fecha_pago  DATETIME DEFAULT GETDATE(),
    monto       DECIMAL(12,2) NOT NULL,
    metodo_pago VARCHAR(50),
    estado_pago VARCHAR(30)
);

/* =========================
   TABLA: EVENTOS_SERVICIOS (M:N)
   ========================= */
CREATE TABLE Eventos_Servicios (
    id_evento   INT NOT NULL,
    id_servicio INT NOT NULL,
    cantidad    INT NOT NULL,
    subtotal    DECIMAL(12,2) NOT NULL
);

/* =========================
   TABLA 4FN: EVENTOS_ORGANIZADORES
   ========================= */
CREATE TABLE Eventos_Organizadores (
    id_evento      INT NOT NULL,
    id_organizador INT NOT NULL,
    es_principal   BIT DEFAULT 0,
    created_at     DATETIME DEFAULT GETDATE()
);

/* =========================
   TABLA 4FN: CLIENTES_TELEFONOS
   ========================= */
CREATE TABLE Clientes_Telefonos (
    id_cliente INT NOT NULL,
    telefono   VARCHAR(20) NOT NULL,
    tipo       VARCHAR(20)
);

/* =========================
   TABLA 4FN: CLIENTES_CORREOS
   ========================= */
CREATE TABLE Clientes_Correos (
    id_cliente INT NOT NULL,
    correo     VARCHAR(120) NOT NULL,
    principal  BIT
);

/* =========================
   TABLA 4FN: PROVEEDORES_CONTACTOS
   ========================= */
CREATE TABLE Proveedores_Contactos (
    id_proveedor INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    telefono     VARCHAR(20),
    correo       VARCHAR(120) NOT NULL,
    cargo        VARCHAR(50)
);


---------------------------------------------------------------
-- 3. RESTRICCIONES (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK)
---------------------------------------------------------------

-------------------------
-- 3.1 PRIMARY KEYS
-------------------------
ALTER TABLE Clientes
ADD CONSTRAINT PK_Clientes
    PRIMARY KEY (id_cliente);

ALTER TABLE Lugares
ADD CONSTRAINT PK_Lugares
    PRIMARY KEY (id_lugar);

ALTER TABLE Organizadores
ADD CONSTRAINT PK_Organizadores
    PRIMARY KEY (id_organizador);

ALTER TABLE Proveedores
ADD CONSTRAINT PK_Proveedores
    PRIMARY KEY (id_proveedor);

ALTER TABLE Servicios
ADD CONSTRAINT PK_Servicios
    PRIMARY KEY (id_servicio);

ALTER TABLE Eventos
ADD CONSTRAINT PK_Eventos
    PRIMARY KEY (id_evento);

ALTER TABLE Pagos
ADD CONSTRAINT PK_Pagos
    PRIMARY KEY (id_pago);

ALTER TABLE Eventos_Servicios
ADD CONSTRAINT PK_Eventos_Servicios
    PRIMARY KEY (id_evento, id_servicio);

ALTER TABLE Eventos_Organizadores
ADD CONSTRAINT PK_Eventos_Organizadores
    PRIMARY KEY (id_evento, id_organizador);

ALTER TABLE Clientes_Telefonos
ADD CONSTRAINT PK_Clientes_Telefonos
    PRIMARY KEY (id_cliente, telefono);

ALTER TABLE Clientes_Correos
ADD CONSTRAINT PK_Clientes_Correos
    PRIMARY KEY (id_cliente, correo);

ALTER TABLE Proveedores_Contactos
ADD CONSTRAINT PK_Proveedores_Contactos
    PRIMARY KEY (id_proveedor, correo);


-------------------------
-- 3.2 FOREIGN KEYS
-------------------------

-- Servicios → Proveedores
ALTER TABLE Servicios
ADD CONSTRAINT FK_Servicio_Proveedor
    FOREIGN KEY (id_proveedor)
    REFERENCES Proveedores(id_proveedor);

-- Eventos → Clientes
ALTER TABLE Eventos
ADD CONSTRAINT FK_Evento_Cliente
    FOREIGN KEY (id_cliente)
    REFERENCES Clientes(id_cliente);

-- Eventos → Lugares
ALTER TABLE Eventos
ADD CONSTRAINT FK_Evento_Lugar
    FOREIGN KEY (id_lugar)
    REFERENCES Lugares(id_lugar);

-- Pagos → Eventos (ON DELETE CASCADE)
ALTER TABLE Pagos
ADD CONSTRAINT FK_Pago_Evento
    FOREIGN KEY (id_evento)
    REFERENCES Eventos(id_evento)
    ON DELETE CASCADE;

-- Eventos_Servicios → Eventos
ALTER TABLE Eventos_Servicios
ADD CONSTRAINT FK_ES_Evento
    FOREIGN KEY (id_evento)
    REFERENCES Eventos(id_evento)
    ON DELETE CASCADE;

-- Eventos_Servicios → Servicios
ALTER TABLE Eventos_Servicios
ADD CONSTRAINT FK_ES_Servicio
    FOREIGN KEY (id_servicio)
    REFERENCES Servicios(id_servicio);

-- Eventos_Organizadores → Eventos
ALTER TABLE Eventos_Organizadores
ADD CONSTRAINT FK_EO_Evento
    FOREIGN KEY (id_evento)
    REFERENCES Eventos(id_evento)
    ON DELETE CASCADE;

-- Eventos_Organizadores → Organizadores
ALTER TABLE Eventos_Organizadores
ADD CONSTRAINT FK_EO_Organizador
    FOREIGN KEY (id_organizador)
    REFERENCES Organizadores(id_organizador);

-- Clientes_Telefonos → Clientes
ALTER TABLE Clientes_Telefonos
ADD CONSTRAINT FK_CT_Cliente
    FOREIGN KEY (id_cliente)
    REFERENCES Clientes(id_cliente)
    ON DELETE CASCADE;

-- Clientes_Correos → Clientes
ALTER TABLE Clientes_Correos
ADD CONSTRAINT FK_CC_Cliente
    FOREIGN KEY (id_cliente)
    REFERENCES Clientes(id_cliente)
    ON DELETE CASCADE;

-- Proveedores_Contactos → Proveedores
ALTER TABLE Proveedores_Contactos
ADD CONSTRAINT FK_PC_Proveedor
    FOREIGN KEY (id_proveedor)
    REFERENCES Proveedores(id_proveedor)
    ON DELETE CASCADE;


-------------------------
-- 3.3 UNIQUE
-------------------------

-- Servicio único por proveedor
ALTER TABLE Servicios
ADD CONSTRAINT UQ_Servicio_Proveedor
    UNIQUE (id_proveedor, nombre_servicio);

-- Correo único en toda la base
ALTER TABLE Clientes_Correos
ADD CONSTRAINT UQ_Correo
    UNIQUE (correo);


-------------------------
-- 3.4 CHECK (REGLAS DE NEGOCIO Y FORMATO)
-------------------------

-- Nombres de clientes sin números
ALTER TABLE Clientes
ADD CONSTRAINT CK_Clientes_Nombre_Sin_Numeros
    CHECK (nombre   NOT LIKE '%[0-9]%' AND
           apellido NOT LIKE '%[0-9]%');

-- Nombres de organizadores sin números
ALTER TABLE Organizadores
ADD CONSTRAINT CK_Organizadores_Nombre_Sin_Numeros
    CHECK (nombre   NOT LIKE '%[0-9]%' AND
           apellido NOT LIKE '%[0-9]%');

-- Capacidad de lugar no negativa (o NULL)
ALTER TABLE Lugares
ADD CONSTRAINT CK_Lugares_Capacidad_NoNegativa
    CHECK (capacidad IS NULL OR capacidad >= 0);

-- Costo de servicio no negativo
ALTER TABLE Servicios
ADD CONSTRAINT CK_Servicios_Costo_Pos
    CHECK (costo >= 0);

-- Horas válidas en Eventos (fin >= inicio si ambas existen)
ALTER TABLE Eventos
ADD CONSTRAINT CK_Eventos_Horas
    CHECK (hora_fin IS NULL OR hora_inicio IS NULL OR hora_fin >= hora_inicio);

-- Estado de evento válido
ALTER TABLE Eventos
ADD CONSTRAINT CK_Eventos_Estado_Valido
    CHECK (estado IS NULL OR estado IN ('Programado','Confirmado','Pendiente','Cancelado'));

-- Monto de pago no negativo
ALTER TABLE Pagos
ADD CONSTRAINT CK_Pagos_Monto_Pos
    CHECK (monto >= 0);

-- Método de pago válido
ALTER TABLE Pagos
ADD CONSTRAINT CK_Pagos_Metodo_Valido
    CHECK (metodo_pago IS NULL OR metodo_pago IN ('Transferencia','Efectivo','Tarjeta'));

-- Estado de pago válido
ALTER TABLE Pagos
ADD CONSTRAINT CK_Pagos_Estado_Valido
    CHECK (estado_pago IS NULL OR estado_pago IN ('Pagado','Pendiente','Cancelado'));

-- Teléfono de organizadores: solo dígitos y largo razonable
ALTER TABLE Organizadores
ADD CONSTRAINT CK_Organizadores_Telefono_Formato
    CHECK (telefono IS NULL OR
           (LEN(telefono) BETWEEN 7 AND 15 AND telefono NOT LIKE '%[^0-9]%'));

-- Teléfono de clientes: solo dígitos y largo razonable
ALTER TABLE Clientes_Telefonos
ADD CONSTRAINT CK_Clientes_Telefonos_Formato
    CHECK (LEN(telefono) BETWEEN 7 AND 15 AND telefono NOT LIKE '%[^0-9]%');

-- Correo de clientes: formato simple con @ y punto
ALTER TABLE Clientes_Correos
ADD CONSTRAINT CK_Clientes_Correos_Formato
    CHECK (correo LIKE '%@%.%');

-- Correo de contactos de proveedor: formato simple
ALTER TABLE Proveedores_Contactos
ADD CONSTRAINT CK_Proveedores_Correo_Formato
    CHECK (correo LIKE '%@%.%');


---------------------------------------------------------------
-- 4. ÍNDICE FILTRADO (REGLA ADICIONAL 4FN)
---------------------------------------------------------------

-- Máximo 1 organizador principal por evento
CREATE UNIQUE INDEX UX_EO_Principal
ON Eventos_Organizadores (id_evento)
WHERE es_principal = 1;


---------------------------------------------------------------
-- 5. INSERCIÓN DE DATOS DE EJEMPLO
---------------------------------------------------------------

/* CLIENTES */
INSERT INTO Clientes (nombre, apellido, direccion) VALUES
(N'Carlos',  N'García',  N'Residencial Las Colinas, Managua'),
(N'María',   N'López',   N'Colonia Centro, Managua'),
(N'Ricardo', N'Prado',   N'Barrio San Juan, Managua');

/* LUGARES */
INSERT INTO Lugares (nombre_lugar, direccion, capacidad, tipo_lugar) VALUES
(N'Salón Verona',      N'Centro de Convenciones Managua', 200, N'Salón'),
(N'Terraza Aurora',    N'Carretera a Masaya km 7',         120, N'Terraza'),
(N'Jardines del Lago', N'Malecón de Granada',             300, N'Jardín');

/* ORGANIZADORES */
INSERT INTO Organizadores (nombre, apellido, rol, telefono) VALUES
(N'Ana',   N'Martínez', N'Coordinadora', N'88880001'),
(N'Luis',  N'Pérez',    N'Logística',    N'88880002'),
(N'Sofía', N'Ramos',    N'Protocolo',    N'88880003');

/* PROVEEDORES */
INSERT INTO Proveedores (nombre_empresa, descripcion) VALUES
(N'Florería Primavera', N'Arreglos florales y decoración general'),
(N'Catering Delicias',  N'Servicio de alimentación para eventos'),
(N'Sonido ProMix',      N'Sonido profesional, DJ e iluminación');

/* SERVICIOS */
INSERT INTO Servicios (id_proveedor, nombre_servicio, descripcion, costo) VALUES
(1, N'Arreglo floral premium',   N'Decoración floral completa para salón',            750.00),
(1, N'Centros de mesa',          N'Centro de mesa floral estándar',                   25.00),
(2, N'Catering buffet estándar', N'Buffet para eventos sociales',                     18.50),
(2, N'Coffee break ejecutivo',   N'Café, bocadillos y repostería',                    6.00),
(3, N'Sonido profesional',       N'Equipo de audio y DJ para evento',                300.00),
(3, N'Iluminación ambiental',    N'Luces decorativas y ambientación para el salón',  220.00);

/* EVENTOS */
INSERT INTO Eventos (id_cliente, id_lugar, nombre_evento, fecha_evento, hora_inicio, hora_fin, descripcion, estado) VALUES
(1, 1, N'Boda Carlos y María',             '2025-02-15', '17:00', '23:00',
 N'Boda civil y religiosa con recepción.',     N'Programado'),
(3, 2, N'Seminario de Tecnología',         '2025-03-10', '09:00', '13:00',
 N'Seminario sobre innovación tecnológica.',   N'Confirmado'),
(2, 3, N'Fiesta de Fin de Año Empresarial', '2025-12-20','19:00','23:30',
 N'Fiesta de fin de año para empleados.',      N'Pendiente');

/* PAGOS */
INSERT INTO Pagos (id_evento, fecha_pago, monto, metodo_pago, estado_pago) VALUES
(1, '2025-01-20 10:00', 1000.00, N'Transferencia', N'Pagado'),
(1, '2025-02-10 15:30',  800.00, N'Efectivo',      N'Pagado'),
(2, '2025-02-20 09:15',  500.00, N'Tarjeta',       N'Pendiente'),
(3, '2025-11-30 11:00',  300.00, N'Transferencia', N'Pendiente');

/* EVENTOS_SERVICIOS */
INSERT INTO Eventos_Servicios (id_evento, id_servicio, cantidad, subtotal) VALUES
-- Evento 1: boda
(1, 1,  1,   750.00),
(1, 2, 20,   500.00),
(1, 3, 80,  1480.00),
(1, 5,  1,   300.00),
(1, 6,  1,   220.00),

-- Evento 2: seminario
(2, 3, 40,   740.00),
(2, 4, 40,   240.00),
(2, 5,  1,   300.00),

-- Evento 3: fiesta de fin de año
(3, 3, 60,  1110.00),
(3, 5,  1,   300.00),
(3, 6,  1,   220.00);

/* EVENTOS_ORGANIZADORES */
INSERT INTO Eventos_Organizadores (id_evento, id_organizador, es_principal) VALUES
(1, 1, 1),  -- Ana principal en la boda
(1, 2, 0),  -- Luis apoyo
(2, 2, 1),  -- Luis principal en el seminario
(2, 3, 0),  -- Sofía apoyo
(3, 3, 1);  -- Sofía principal en la fiesta

/* CLIENTES_TELEFONOS */
INSERT INTO Clientes_Telefonos (id_cliente, telefono, tipo) VALUES
(1, N'88881001', N'Móvil'),
(1, N'22551001', N'Casa'),
(2, N'88882001', N'Móvil'),
(2, N'22552001', N'Casa'),
(3, N'88883001', N'Móvil');

/* CLIENTES_CORREOS */
INSERT INTO Clientes_Correos (id_cliente, correo, principal) VALUES
(1, N'carlos.garcia@example.com',   1),
(1, N'carlos.eventos@example.com',  0),
(2, N'maria.lopez@example.com',     1),
(3, N'ricardo.prado@example.com',   1);

/* PROVEEDORES_CONTACTOS */
INSERT INTO Proveedores_Contactos (id_proveedor, nombre, telefono, correo, cargo) VALUES
(1, N'Lucía Fernández',  N'88884001', N'ventas@floreriaprimavera.com',      N'Ventas'),
(2, N'Jorge Castillo',   N'88885001', N'coordinacion@cateringdelicias.com', N'Coordinador'),
(3, N'Pedro Gómez',      N'88886001', N'soporte@sonidopromix.com',          N'Soporte');


---------------------------------------------------------------
-- 6. CONSULTAS DE REPORTE (EJEMPLOS ÚTILES)
---------------------------------------------------------------

/* 6.1 Eventos con cliente, lugar y total de servicios */
SELECT  e.id_evento,
        e.nombre_evento,
        c.nombre + ' ' + c.apellido AS cliente,
        l.nombre_lugar,
        e.fecha_evento,
        e.estado,
        SUM(ISNULL(es.subtotal,0)) AS total_servicios
FROM Eventos e
JOIN Clientes c           ON e.id_cliente = c.id_cliente
JOIN Lugares  l           ON e.id_lugar   = l.id_lugar
LEFT JOIN Eventos_Servicios es ON e.id_evento = es.id_evento
GROUP BY e.id_evento, e.nombre_evento, c.nombre, c.apellido,
         l.nombre_lugar, e.fecha_evento, e.estado;

/* 6.2 Total contratado vs total pagado por evento (saldo pendiente) */
SELECT  e.id_evento,
        e.nombre_evento,
        SUM(ISNULL(es.subtotal,0))             AS total_contratado,
        ISNULL(SUM(p.monto), 0)                AS total_pagado,
        SUM(ISNULL(es.subtotal,0)) - ISNULL(SUM(p.monto), 0) AS saldo_pendiente
FROM Eventos e
LEFT JOIN Eventos_Servicios es ON e.id_evento = es.id_evento
LEFT JOIN Pagos p              ON e.id_evento = p.id_evento
GROUP BY e.id_evento, e.nombre_evento;

/* 6.3 Servicios más contratados (ranking) */
SELECT  s.id_servicio,
        s.nombre_servicio,
        SUM(es.cantidad) AS total_unidades,
        SUM(es.subtotal) AS ingreso_total_aprox
FROM Eventos_Servicios es
JOIN Servicios s ON es.id_servicio = s.id_servicio
GROUP BY s.id_servicio, s.nombre_servicio
ORDER BY total_unidades DESC;

/* 6.4 Eventos organizados por cada cliente (ranking de clientes) */
SELECT  c.id_cliente,
        c.nombre + ' ' + c.apellido AS cliente,
        COUNT(e.id_evento)          AS cantidad_eventos
FROM Clientes c
LEFT JOIN Eventos e ON c.id_cliente = e.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY cantidad_eventos DESC, cliente;

/* 6.5 Calendario de eventos por mes y año */
SELECT  YEAR(e.fecha_evento)  AS anio,
        MONTH(e.fecha_evento) AS mes,
        COUNT(*)              AS eventos_mes
FROM Eventos e
GROUP BY YEAR(e.fecha_evento), MONTH(e.fecha_evento)
ORDER BY anio, mes;

/* 6.6 Agenda de cada organizador (en qué eventos participa y con qué rol) */
SELECT  o.id_organizador,
        o.nombre + ' ' + o.apellido AS organizador,
        e.id_evento,
        e.nombre_evento,
        e.fecha_evento,
        CASE WHEN eo.es_principal = 1 THEN N'Principal' ELSE N'Apoyo' END AS tipo_participacion
FROM Eventos_Organizadores eo
JOIN Organizadores o ON eo.id_organizador = o.id_organizador
JOIN Eventos       e ON eo.id_evento      = e.id_evento
ORDER BY o.id_organizador, e.fecha_evento;

/* 6.7 Proveedores con sus servicios y contactos */
SELECT  p.id_proveedor,
        p.nombre_empresa,
        s.nombre_servicio,
        pc.nombre   AS contacto,
        pc.telefono AS tel_contacto,
        pc.correo   AS correo_contacto
FROM Proveedores p
LEFT JOIN Servicios            s  ON p.id_proveedor = s.id_proveedor
LEFT JOIN Proveedores_Contactos pc ON p.id_proveedor = pc.id_proveedor
ORDER BY p.nombre_empresa, s.nombre_servicio;

/* 6.8 Teléfonos y correos de cada cliente (ficha de cliente) */
SELECT  c.id_cliente,
        c.nombre + ' ' + c.apellido AS cliente,
        ct.telefono,
        ct.tipo      AS tipo_telefono,
        cc.correo,
        cc.principal AS correo_principal
FROM Clientes c
LEFT JOIN Clientes_Telefonos ct ON c.id_cliente = ct.id_cliente
LEFT JOIN Clientes_Correos  cc ON c.id_cliente = cc.id_cliente
ORDER BY c.id_cliente, ct.telefono, cc.correo;

/* 6.9 Próximos eventos (a partir de hoy) con cliente y lugar */
SELECT  e.id_evento,
        e.nombre_evento,
        e.fecha_evento,
        c.nombre + ' ' + c.apellido AS cliente,
        l.nombre_lugar,
        e.estado
FROM Eventos e
JOIN Clientes c ON e.id_cliente = c.id_cliente
JOIN Lugares  l ON e.id_lugar   = l.id_lugar
WHERE e.fecha_evento >= CAST(GETDATE() AS date)
ORDER BY e.fecha_evento;

/* 6.10 Total de ingresos estimados por proveedor (por servicios contratados) */
SELECT  p.id_proveedor,
        p.nombre_empresa,
        SUM(es.subtotal) AS ingreso_estimado
FROM Proveedores p
JOIN Servicios          s  ON p.id_proveedor = s.id_proveedor
JOIN Eventos_Servicios es ON s.id_servicio   = es.id_servicio
GROUP BY p.id_proveedor, p.nombre_empresa
ORDER BY ingreso_estimado DESC;

/* 6.11 Servicios contratados para la boda (evento 1) */
SELECT es.id_evento, s.nombre_servicio, es.cantidad, es.subtotal
FROM Eventos_Servicios es
JOIN Servicios s ON es.id_servicio = s.id_servicio
WHERE es.id_evento = 1;

