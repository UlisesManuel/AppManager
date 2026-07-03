# App Manager - Gestor de Contraseñas Local

**App Manager** es una aplicación móvil desarrollada en Flutter orientada a la seguridad informática y gestión de identidades. Resuelve el problema de la fatiga de contraseñas y la reutilización de credenciales, permitiendo almacenar y administrar accesos de manera centralizada en un entorno local seguro utilizando SQLite.


# Descripción del Proyecto

La aplicación permite a los usuarios registrar cuentas, iniciar sesión y gestionar credenciales de diferentes servicios.

Incluye un sistema de contraseña maestra para proteger el acceso a la información sensible, así como un generador de contraseñas seguras.

Toda la información se almacena de forma local en el dispositivo mediante SQLite, garantizando disponibilidad offline y control total de los datos.


# Objetivos

## Objetivo General
Desarrollar una aplicación móvil para la gestión segura de contraseñas utilizando Flutter y SQLite.

## Objetivos Específicos
- Implementar registro e inicio de sesión.
- Gestionar credenciales de servicios.
- Generar contraseñas seguras automáticamente.
- Proteger información mediante contraseña maestra.
- Utilizar almacenamiento local con SQLite.


# 🛠️ Arquitectura del Sistema

La aplicación sigue una arquitectura en capas:

## 1. Capa de Presentación (UI)
Interfaces desarrolladas en Flutter:
- Login
- Registro
- Home
- Gestión de contraseñas

## 2. Capa de Lógica de Negocio
Responsable del flujo de datos:
- Validaciones
- Autenticación
- Generación de contraseñas
- Control de estados

## 3. Capa de Persistencia (Data Layer)
Implementada con SQLite usando `sqflite`:
- Usuarios
- Credenciales
- CRUD local


# Diagrama de Arquitectura


Usuario
   ↓
Flutter UI
   ↓
Lógica de Negocio
   ↓
DatabaseHelper (SQLite)
   ↓
Base de Datos Local
   ├── usuarios
   └── credenciales


# Seguridad del Sistema

- Autenticación con correo y contraseña.
- Uso de contraseña maestra para acceso a datos sensibles.
- Aislamiento de datos por usuario mediante `usuario_id`.
- Validación antes de mostrar contraseñas almacenadas.


# Tecnologías Utilizadas

- Flutter
- Dart
- SQLite (sqflite)
- Material Design

# Estructura del Proyecto

lib/
│
├── database/
│   └── database_helper.dart
│
├── models/
│   ├── user.dart
│   └── credential.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── add_password_screen.dart
│   └── password_detail_screen.dart
│
└── main.dart


# Base de Datos

```sql
CREATE TABLE usuarios(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL
);

CREATE TABLE credenciales(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario_id INTEGER,
  nombre_servicio TEXT NOT NULL,
  usuario_servicio TEXT NOT NULL,
  password_servicio TEXT NOT NULL,
  FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
);
```

# 👨‍💻 Autor

**Ulises Manuel García Ramos**
**Kevin Emanuel Pérez Espina**


# 🧾 Nota Académica

Proyecto desarrollado con fines educativos como parte de la evaluación de desarrollo de aplicaciones móviles, cumpliendo con los requerimientos de persistencia local, arquitectura en capas e interfaz de usuario en Flutter.