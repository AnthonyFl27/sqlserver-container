-- ===== CREAR LOGINS (NIVEL SERVIDOR) =====
CREATE LOGIN eventos_editor WITH PASSWORD = 'Editor@Events2026';
CREATE LOGIN eventos_viewer WITH PASSWORD = 'Viewer@Events2026';

-- ===== CREAR USUARIOS EN GESTOR_EVENTOS (NIVEL BASE DE DATOS) =====
USE gestor_eventos;
CREATE USER eventos_editor FOR LOGIN eventos_editor;
CREATE USER eventos_viewer FOR LOGIN eventos_viewer;

-- ===== CREAR ROLES PERSONALIZADOS =====
CREATE ROLE app_role;
CREATE ROLE readonly_role;

-- ===== PERMISOS PARA APP_ROLE (lectura/escritura controlada) =====
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO app_role;
GRANT EXECUTE ON SCHEMA::dbo TO app_role;

-- ===== PERMISOS PARA READONLY_ROLE (solo lectura) =====
GRANT SELECT ON SCHEMA::dbo TO readonly_role;

-- ===== ASIGNAR USUARIOS A ROLES =====
ALTER ROLE app_role ADD MEMBER eventos_editor;
ALTER ROLE readonly_role ADD MEMBER eventos_viewer;

-- ===== VERIFICAR CONFIGURACIÓN =====
SELECT * FROM sys.database_role_members;
SELECT name, type_desc FROM sys.database_principals WHERE type IN ('S', 'R');