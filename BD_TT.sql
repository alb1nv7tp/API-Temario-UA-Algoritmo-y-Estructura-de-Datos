-- ============================================================
-- CREACIÓN DE LA BASE DE DATOS
-- ============================================================
DROP DATABASE IF EXISTS repositorio_academico;
CREATE DATABASE repositorio_academico
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE repositorio_academico;

-- ============================================================
-- TABLA: Alumnos
-- ============================================================
CREATE TABLE Alumnos (
    boleta              INT             NOT NULL,
    nombre              VARCHAR(100)    NOT NULL,
    correoRecuperacion  VARCHAR(100)    NOT NULL UNIQUE,
    contrasena          VARCHAR(255)    NOT NULL,
    fechaRegistro       DATETIME        NOT NULL,
    fechaBaja           DATETIME        DEFAULT NULL,
    estatus             TINYINT(1)      NOT NULL CHECK (estatus IN (0,1)),
    PRIMARY KEY (boleta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: Profesores
-- ============================================================
CREATE TABLE Profesores (
    numTrabajador       INT             NOT NULL,
    nombre              VARCHAR(100)    NOT NULL,
    correoRecuperacion  VARCHAR(100)    NOT NULL UNIQUE,
    contrasena          VARCHAR(255)    NOT NULL,
    fechaRegistro       DATETIME        NOT NULL,
    fechaBaja           DATETIME        DEFAULT NULL,
    estatus             TINYINT(1)      NOT NULL CHECK (estatus IN (0,1)),
    PRIMARY KEY (numTrabajador)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: Administradores
-- ============================================================
CREATE TABLE Administradores (
    idAdmin             INT             NOT NULL AUTO_INCREMENT,
    correoRecuperacion  VARCHAR(100)    NOT NULL UNIQUE,
    contrasena          VARCHAR(255)    NOT NULL,
    fechaRegistro       DATETIME        NOT NULL,
    fechaBaja           DATETIME        DEFAULT NULL,
    estatus             TINYINT(1)      NOT NULL CHECK (estatus IN (0,1)),
    PRIMARY KEY (idAdmin)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: Etiquetas
-- ============================================================
CREATE TABLE Etiquetas (
    idEtiqueta          INT             NOT NULL AUTO_INCREMENT,
    nombreEtiqueta      VARCHAR(100)    NOT NULL,
    fechaCreacion       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fechaModificacion   DATETIME        DEFAULT NULL,
    fechaEliminacion    DATETIME        DEFAULT NULL,
    estatus             VARCHAR(50)     NOT NULL,
    PRIMARY KEY (idEtiqueta)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: Documentos
-- ============================================================
CREATE TABLE Documentos (
    idDocumento         INT             NOT NULL AUTO_INCREMENT,
    nombreDocumento     VARCHAR(150)    NOT NULL,
    descripcion         TEXT            NULL,
    rutaDocumento       VARCHAR(255)    NOT NULL,
    numTrabajador       INT             NOT NULL,
    fechaSubida         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fechaActualizacion  DATETIME        DEFAULT NULL,
    fechaEliminacion    DATETIME        DEFAULT NULL,
    estatus             TINYINT(1)      NOT NULL CHECK (estatus IN (0,1)),
    PRIMARY KEY (idDocumento),
    FOREIGN KEY (numTrabajador) REFERENCES Profesores(numTrabajador)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: Documentos_Etiquetas
-- ============================================================
CREATE TABLE Documentos_Etiquetas (
    idDocumento         INT             NOT NULL,
    idEtiqueta          INT             NOT NULL,
    PRIMARY KEY (idDocumento, idEtiqueta),
    FOREIGN KEY (idDocumento) REFERENCES Documentos(idDocumento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (idEtiqueta) REFERENCES Etiquetas(idEtiqueta)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: Bitacora
-- ============================================================
CREATE TABLE Bitacora (
    idEvento            INT             NOT NULL AUTO_INCREMENT,
    tipoUsuario         ENUM('alumno','profesor','administrador') NOT NULL,
    identificadorUsuario VARCHAR(25)    NOT NULL,
    accion              VARCHAR(255)    NOT NULL,
    tablaAfectada       VARCHAR(50)     DEFAULT NULL,
    idRegistroAfectado  VARCHAR(25)     DEFAULT NULL,
    fechaEvento         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ipOrigen            VARCHAR(45)     DEFAULT NULL,
    PRIMARY KEY (idEvento)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: tokens_cambiar_contraseña
-- Almacena tokens de recuperación de contraseña con control de intentos
-- ============================================================
CREATE TABLE tokens_cambiar_contrasena (
    id          INT             NOT NULL AUTO_INCREMENT,
    user_type   ENUM('alumno', 'profesor', 'administrador') NOT NULL,
    user_id     VARCHAR(25)     NOT NULL,   -- boleta, numTrabajador o idAdmin (convertido a string)
    token_hash  VARCHAR(255)    NOT NULL,   -- hash del token (ej. SHA-256 o bcrypt)
    tries       TINYINT UNSIGNED NOT NULL DEFAULT 0,  -- intentos fallidos
    used        TINYINT(1)      NOT NULL DEFAULT 0,   -- 0 = no usado, 1 = usado
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_request  VARCHAR(45)     NOT NULL,   -- IPv4 o IPv6
    PRIMARY KEY (id),
    INDEX idx_user_lookup (user_type, user_id),       -- búsqueda rápida por usuario
    INDEX idx_token_hash (token_hash)                 -- búsqueda por token
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- POBLACIÓN DE DATOS DE EJEMPLO
-- ============================================================

-- ALUMNOS (5 registros)
INSERT INTO Alumnos (boleta, nombre, correoRecuperacion, contrasena, fechaRegistro, estatus) VALUES
(20240101, 'Ana Laura Gómez Pérez', 'ana.gomez@alumno.ipn.mx', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '2024-01-10 09:30:00', 1),
(20240102, 'Carlos Eduardo Ruiz López', 'carlos.ruiz@alumno.ipn.mx', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '2024-01-11 10:15:00', 1),
(20240103, 'María Fernanda Díaz Soto', 'maria.diaz@alumno.ipn.mx', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '2024-01-12 11:45:00', 1),
(20240104, 'Javier Alejandro Mora Ríos', 'javier.mora@alumno.ipn.mx', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '2024-01-13 08:20:00', 1),
(20240105, 'Lucía Fernanda Castro Vega', 'lucia.castro@alumno.ipn.mx', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '2024-01-14 14:00:00', 1);

-- PROFESORES (5 registros)
INSERT INTO Profesores (numTrabajador, nombre, correoRecuperacion, contrasena, fechaRegistro, estatus) VALUES
(1001, 'Dr. Ricardo Mendoza Ortega', 'rmendoza@ipn.mx', '$2y$10$h.KLp/9b9sX6Qx7yF3m2Ee5tR8uV1wZ0aBcDfGhIjKlMnOp', '2023-12-01 09:00:00', 1),
(1002, 'Mtra. Silvia Ramírez Nava', 'sramirez@ipn.mx', '$2y$10$h.KLp/9b9sX6Qx7yF3m2Ee5tR8uV1wZ0aBcDfGhIjKlMnOp', '2023-12-02 10:30:00', 1),
(1003, 'Dr. Arturo Hernández Salazar', 'ahernandez@ipn.mx', '$2y$10$h.KLp/9b9sX6Qx7yF3m2Ee5tR8uV1wZ0aBcDfGhIjKlMnOp', '2023-12-03 11:15:00', 1),
(1004, 'Mtro. Luis Ángel Fuentes García', 'lfuentes@ipn.mx', '$2y$10$h.KLp/9b9sX6Qx7yF3m2Ee5tR8uV1wZ0aBcDfGhIjKlMnOp', '2023-12-04 13:45:00', 1),
(1005, 'Dra. Patricia Elena Juárez López', 'pjuarez@ipn.mx', '$2y$10$h.KLp/9b9sX6Qx7yF3m2Ee5tR8uV1wZ0aBcDfGhIjKlMnOp', '2023-12-05 08:50:00', 1);

-- ADMINISTRADORES (5 registros)
INSERT INTO Administradores (correoRecuperacion, contrasena, fechaRegistro, estatus) VALUES
('admin.sistema@ipn.mx', '$2y$10$AdMiNhAsHpAsSwOrD1234567890abcdefghijklmnopqrstuv', '2023-11-01 12:00:00', 1),
('admin2@ipn.mx', '$2y$10$AdMiNhAsHpAsSwOrD1234567890abcdefghijklmnopqrstuv', '2023-11-15 09:20:00', 1),
('soporte.tecnico@ipn.mx', '$2y$10$AdMiNhAsHpAsSwOrD1234567890abcdefghijklmnopqrstuv', '2023-12-10 14:10:00', 1),
('auditoria@ipn.mx', '$2y$10$AdMiNhAsHpAsSwOrD1234567890abcdefghijklmnopqrstuv', '2024-01-05 11:30:00', 1),
('respaldo@ipn.mx', '$2y$10$AdMiNhAsHpAsSwOrD1234567890abcdefghijklmnopqrstuv', '2024-02-01 08:00:00', 1);

-- ETIQUETAS (Algoritmos y Estructuras de Datos)
INSERT INTO Etiquetas (nombreEtiqueta, fechaCreacion, estatus) VALUES
-- Etiquetas Generales / Extras (IDs 1 y 2)
('practica', NOW(), 'activo'),
('recurso didactico', NOW(), 'activo'),

-- Módulo 1: Algoritmia y Ordenamiento (IDs 3 a 21)
('Algoritmia', NOW(), 'activo'),
('Características de los algoritmos y tipos', NOW(), 'activo'),
('Representación de algoritmos en pseudocódigo', NOW(), 'activo'),
('Abstracción y tipo de dato abstracto', NOW(), 'activo'),
('Orden de complejidad 𝑶() de un algoritmo', NOW(), 'activo'),
('El problema del ordenamiento', NOW(), 'activo'),
('Ordenamiento por inserción', NOW(), 'activo'),
('Ordenamiento por selección', NOW(), 'activo'),
('Ordenamiento de burbuja', NOW(), 'activo'),
('Ordenamiento por mezcla', NOW(), 'activo'),
('(El problema del ordenamiento) Comparación de órdenes de complejidad', NOW(), 'activo'),
('El problema de la búsqueda', NOW(), 'activo'),
('Búsqueda secuencial', NOW(), 'activo'),
('Búsqueda binaria', NOW(), 'activo'),
('Búsqueda indexada', NOW(), 'activo'),
('(El problema de la búsqueda) Comparación de órdenes de complejidad', NOW(), 'activo'),
('Exploración exhaustiva y vuelta atrás', NOW(), 'activo'),
('Exploración exhaustiva', NOW(), 'activo'),
('Programación por vuelta atrás', NOW(), 'activo'),
('Nociones de complejidad de la exploración exhaustiva y vuelta atrás', NOW(), 'activo'),

-- Módulo 2: Estructuras de Datos Lineales y Hash (IDs 22 a 40)
('Pila', NOW(), 'activo'),
('(Pila) Especificación genérica', NOW(), 'activo'),
('(Pila) Implementación estática', NOW(), 'activo'),
('(Pila) Implementación dinámica', NOW(), 'activo'),
('(Pila) Nociones de complejidad de las operaciones', NOW(), 'activo'),
('(Pila) Aplicaciones', NOW(), 'activo'),
('Cola', NOW(), 'activo'),
('(Cola) Especificación genérica', NOW(), 'activo'),
('(Cola) Implementación estática', NOW(), 'activo'),
('(Cola) Implementación dinámica', NOW(), 'activo'),
('Colas de prioridad', NOW(), 'activo'),
('(Cola) Nociones de complejidad de las operaciones', NOW(), 'activo'),
('(Cola) Aplicaciones', NOW(), 'activo'),
('Listas', NOW(), 'activo'),
('(Listas) Especificación genérica', NOW(), 'activo'),
('Listas simplemente enlazadas', NOW(), 'activo'),
('Listas doblemente enlazadas', NOW(), 'activo'),
('Listas circulares', NOW(), 'activo'),
('Arreglos y vectores vs listas', NOW(), 'activo'),
('(Listas) Nociones de complejidad de las operaciones', NOW(), 'activo'),
('(Listas) Implementaciones y aplicaciones', NOW(), 'activo'),
('Tablas hash', NOW(), 'activo'),
('(Tabla hash) Especificación genérica', NOW(), 'activo'),
('Función hash', NOW(), 'activo'),
('Resolución de colisiones', NOW(), 'activo'),
('Tablas hash cerradas', NOW(), 'activo'),
('Tablas hash abiertas', NOW(), 'activo'),
('(Tabla hash) Nociones de complejidad de las operaciones', NOW(), 'activo'),
('(Tabla hash) Implementaciones y aplicaciones', NOW(), 'activo'),

-- Módulo 3: Estructuras No Lineales (Árboles y Grafos) (IDs 41 a 53)
('Árboles binarios', NOW(), 'activo'),
('Transformación de árboles generales a binarios', NOW(), 'activo'),
('Recorridos en un árbol binario', NOW(), 'activo'),
('Árbol binario de búsqueda', NOW(), 'activo'),
('Árbol balanceado rojo-negro', NOW(), 'activo'),
('Montículo', NOW(), 'activo'),
('(Árboles binarios) Implementaciones y aplicaciones', NOW(), 'activo'),
('(Árboles binarios) Nociones de complejidad de las implementaciones', NOW(), 'activo'),
('otros tipos de arboles', NOW(), 'activo'),
('Grafos', NOW(), 'activo'),
('Representaciones matriciales y basadas en listas', NOW(), 'activo'),
('Búsqueda en amplitud', NOW(), 'activo'),
('Búsqueda en profundidad', NOW(), 'activo'),
('Distancia más corta', NOW(), 'activo'),
('(Grafos) Implementaciones y aplicaciones', NOW(), 'activo'),
('Nociones de complejidad de los algoritmos sobre grafos', NOW(), 'activo');

-- DOCUMENTOS
INSERT INTO Documentos (nombreDocumento, descripcion, rutaDocumento, numTrabajador, estatus) VALUES
('Práctica 1: Introducción a Pseudocódigo', 'Ejercicios de representación de algoritmos básicos.', '/uploads/docs/p1_pseudo.pdf', 1001, 1),
('Comparativa de Ordenamiento', 'Análisis de burbuja y mezcla.', '/uploads/docs/ordenamiento.pdf', 1001, 1),
('Implementación de Pilas y Colas', 'Estructuras lineales estáticas y dinámicas.', '/uploads/docs/lineales.pdf', 1001, 1),
('Teoría de Árboles Binarios', 'Recorridos y árboles rojo-negro.', '/uploads/docs/arboles.pdf', 1001, 1),
('Búsqueda en Grafos: BFS y DFS', 'Exploración de grafos.', '/uploads/docs/grafos.pdf', 1001, 1);

-- RELACIÓN DOCUMENTOS_ETIQUETAS
-- Doc 1: 1 (practica), 3 (Algoritmia), 5 (Pseudocódigo)
INSERT INTO Documentos_Etiquetas (idDocumento, idEtiqueta) VALUES (1, 1), (1, 3), (1, 5);

-- Doc 2: 2 (recurso), 8 (Problema Ordenamiento), 11 (Burbuja), 12 (Mezcla)
INSERT INTO Documentos_Etiquetas (idDocumento, idEtiqueta) VALUES (2, 2), (2, 8), (2, 11), (2, 12);

-- Doc 3: 2 (recurso), 23 (Pila), 29 (Cola)
INSERT INTO Documentos_Etiquetas (idDocumento, idEtiqueta) VALUES (3, 2), (3, 23), (3, 29);

-- Doc 4: 2 (recurso), 52 (Árboles binarios), 56 (Rojo-negro)
INSERT INTO Documentos_Etiquetas (idDocumento, idEtiqueta) VALUES (4, 2), (4, 52), (4, 56);

-- Doc 5: 2 (recurso), 61 (Grafos), 63 (Amplitud), 64 (Profundidad)
INSERT INTO Documentos_Etiquetas (idDocumento, idEtiqueta) VALUES (5, 2), (5, 61), (5, 63), (5, 64);

-- BITACORA (Algunos eventos)
INSERT INTO Bitacora (tipoUsuario, identificadorUsuario, accion, tablaAfectada, idRegistroAfectado, fechaEvento, ipOrigen) VALUES
('profesor', '1001', 'Inicio de sesión exitoso', NULL, NULL, '2024-02-01 09:15:00', '192.168.1.101'),
('profesor', '1001', 'Subió un nuevo documento', 'Documentos', '1', '2024-02-01 09:30:00', '192.168.1.101');