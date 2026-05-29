# SQL Server 2025 - Entorno de Desarrollo (Docker)

Este repositorio contiene un entorno preconfigurado de SQL Server 2025 ejecutándose en Docker. Incluye la estructura de directorios necesaria para persistir el sistema, los datos de usuario, los logs y los respaldos (.bak) directamente en el host.

---

## 🚀 Requisitos Previos

* Docker y Docker Compose instalados.
* Sistema operativo basado en Linux (Debian/Ubuntu preferiblemente).

---

## 🛠️ Pasos para la Configuración

### 1. Clonar el repositorio

```bash
git clone <repository-url>
cd sqlserver-container
```

### 2. Asignar permisos a las carpetas

Asigna permisos para que el usuario interno de SQL (id 10001) pueda escribir:

```bash
sudo chown -R 10001:10001 mssql_system mssql_user_data mssql_user_logs backups
```

### 3. Configurar el archivo .env

El archivo `.env` debe ser solo lectura:

```bash
sudo chmod 600 .env
```

Edita el archivo `.env` y configura las variables necesarias, como la contraseña de SQL Server:

```env
SA_PASSWORD=[password]

### 4. Iniciar los contenedores

```bash
docker-compose up -d
```

### 5. Verificar el estado

```bash
docker-compose ps
```

---

## 📁 Estructura de Directorios

```
.
├── mssql_system/       # Sistema de archivos de SQL Server
├── mssql_user_data/    # Datos de usuario (archivos .mdf)
├── mssql_user_logs/    # Logs de SQL Server (archivos .ldf)
├── backups/            # Respaldos (.bak)
├── docker-compose.yml  # Configuración de Docker Compose
├── .env                # Variables de entorno
└── README.md           # Este archivo
```

---

