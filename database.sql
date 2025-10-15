-- ============================================
-- TABLA: Usuarios
-- ============================================
CREATE TABLE `Usuarios` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `Expediente` VARCHAR(20) NOT NULL UNIQUE,
  `Nombre` VARCHAR(100) NOT NULL,
  `ApellidoPaterno` VARCHAR(100) NOT NULL,
  `ApellidoMaterno` VARCHAR(100),
  `NIP` VARCHAR(255) NOT NULL, -- Hash del NIP, nunca en texto plano
  `Correo` VARCHAR(255) NOT NULL UNIQUE,
  `Telefono` VARCHAR(15),
  `Tipo` ENUM('Administrador','Usuario') NOT NULL DEFAULT 'Usuario',
  `FechaRegistro` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `Activo` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`ID`),
  INDEX `idx_expediente` (`Expediente`),
  INDEX `idx_tipo` (`Tipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Categorias de Productos
-- ============================================
CREATE TABLE `CategoriasProductos` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `Nombre` VARCHAR(50) NOT NULL,
  `Descripcion` TEXT,
  `Tipo` ENUM('Cafeteria','Cafecito') NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertar categorías iniciales
INSERT INTO `CategoriasProductos` (`Nombre`, `Descripcion`, `Tipo`) VALUES
('Desayuno', 'Platillos de desayuno', 'Cafeteria'),
('Comida', 'Platillos de comida', 'Cafeteria'),
('Bebida Fría', 'Bebidas frías', 'Cafecito'),
('Bebida Caliente', 'Bebidas calientes', 'Cafecito'),
('Snack', 'Snacks y botanas', 'Cafecito'),
('Postre', 'Postres', 'Cafeteria');
• 
-- ============================================
-- TABLA: Productos
-- ============================================
CREATE TABLE `Productos` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `Nombre` VARCHAR(255) NOT NULL,
  `Descripcion` TEXT,
  `PrecioBase` DECIMAL(10,2) NOT NULL,
  `IDCategoria` INT(11) NOT NULL,
  `Gramaje` DECIMAL(10,2), -- en gramos
  `Calorias` DECIMAL(10,2), -- kcal
  `URLFoto` TEXT,
  `Disponible` TINYINT(1) DEFAULT 1,
  `FechaCreacion` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDCategoria`) REFERENCES `CategoriasProductos`(`ID`) ON DELETE RESTRICT,
  INDEX `idx_categoria` (`IDCategoria`),
  INDEX `idx_disponible` (`Disponible`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Tamaños de Bebidas (para Cafecito)
-- ============================================
CREATE TABLE `TamanosBebidas` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `IDProducto` INT(11) NOT NULL,
  `Nombre` VARCHAR(50) NOT NULL, -- Chico, Mediano, Grande
  `Capacidad` INT(11), -- en ml
  `Precio` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDProducto`) REFERENCES `Productos`(`ID`) ON DELETE CASCADE,
  INDEX `idx_producto` (`IDProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Categorías de Ingredientes
-- ============================================
CREATE TABLE `CategoriasIngredientes` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `Nombre` VARCHAR(100) NOT NULL,
  `Descripcion` TEXT,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertar categorías de ingredientes
INSERT INTO `CategoriasIngredientes` (`Nombre`, `Descripcion`) VALUES
('Lácteos', 'Leches, quesos, cremas'),
('Proteínas', 'Carnes, pollo, pescado'),
('Vegetales', 'Verduras y hortalizas'),
('Panes', 'Tipos de pan'),
('Aderezos', 'Salsas y aderezos'),
('Endulzantes', 'Azúcares y sustitutos');

-- ============================================
-- TABLA: Ingredientes
-- ============================================
CREATE TABLE `Ingredientes` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `Nombre` VARCHAR(255) NOT NULL,
  `IDCategoria` INT(11),
  `Descripcion` TEXT,
  `Calorias` DECIMAL(10,2), -- por porción estándar
  `Alergeno` TINYINT(1) DEFAULT 0, -- Si es alérgeno común
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDCategoria`) REFERENCES `CategoriasIngredientes`(`ID`) ON DELETE SET NULL,
  INDEX `idx_categoria` (`IDCategoria`),
  INDEX `idx_nombre` (`Nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Productos-Ingredientes
-- ============================================
CREATE TABLE `ProductosIngredientes` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `IDProducto` INT(11) NOT NULL,
  `IDIngrediente` INT(11) NOT NULL,
  `Cantidad` DECIMAL(10,2), -- cantidad en gramos/ml
  `Eliminable` TINYINT(1) DEFAULT 0,
  `Sustituible` TINYINT(1) DEFAULT 0,
  `Orden` INT(3), -- Para ordenar la lista de ingredientes
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDProducto`) REFERENCES `Productos`(`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`IDIngrediente`) REFERENCES `Ingredientes`(`ID`) ON DELETE RESTRICT,
  INDEX `idx_producto` (`IDProducto`),
  INDEX `idx_ingrediente` (`IDIngrediente`),
  UNIQUE KEY `unique_producto_ingrediente` (`IDProducto`, `IDIngrediente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Sustituciones de Ingredientes
-- ============================================
CREATE TABLE `SustitucionesIngredientes` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `IDProductoIngrediente` INT(11) NOT NULL, -- Ingrediente original del producto
  `IDIngredienteSustituto` INT(11) NOT NULL, -- Ingrediente que puede sustituir
  `CostoExtra` DECIMAL(10,2) DEFAULT 0.00,
  `Disponible` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDProductoIngrediente`) REFERENCES `ProductosIngredientes`(`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`IDIngredienteSustituto`) REFERENCES `Ingredientes`(`ID`) ON DELETE RESTRICT,
  INDEX `idx_producto_ingrediente` (`IDProductoIngrediente`),
  UNIQUE KEY `unique_sustitucion` (`IDProductoIngrediente`, `IDIngredienteSustituto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Opciones de Leche (para Cafecito)
-- ============================================
CREATE TABLE `OpcionesLeche` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `IDIngrediente` INT(11) NOT NULL,
  `Nombre` VARCHAR(100) NOT NULL, -- Entera, Deslactosada, Almendra, etc.
  `CostoExtra` DECIMAL(10,2) DEFAULT 0.00,
  `Disponible` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDIngrediente`) REFERENCES `Ingredientes`(`ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Menú Semanal
-- ============================================
CREATE TABLE `MenuSemanal` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `Fecha` DATE NOT NULL,
  `DiaSemana` ENUM('Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo') NOT NULL,
  `Horario` ENUM('Desayuno','Comida') NOT NULL,
  `NumeroSemana` INT(2) NOT NULL, -- Semana del año (1-52)
  `Anio` INT(4) NOT NULL,
  `FechaCreacion` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `Activo` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `unique_fecha_horario` (`Fecha`, `Horario`),
  INDEX `idx_fecha` (`Fecha`),
  INDEX `idx_semana_anio` (`NumeroSemana`, `Anio`),
  INDEX `idx_activo` (`Activo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Productos del Menú
-- ============================================
CREATE TABLE `MenuSemanalProductos` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `IDMenuSemanal` INT(11) NOT NULL,
  `IDProducto` INT(11) NOT NULL,
  `Orden` INT(3), -- Para ordenar los productos en el menú
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDMenuSemanal`) REFERENCES `MenuSemanal`(`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`IDProducto`) REFERENCES `Productos`(`ID`) ON DELETE RESTRICT,
  INDEX `idx_menu` (`IDMenuSemanal`),
  INDEX `idx_producto` (`IDProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Bebida Especial de Viernes
-- ============================================
CREATE TABLE `BebidasEspeciales` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `IDProducto` INT(11) NOT NULL,
  `FechaInicio` DATE NOT NULL,
  `FechaFin` DATE NOT NULL,
  `Descripcion` TEXT,
  `PrecioEspecial` DECIMAL(10,2),
  `Activo` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDProducto`) REFERENCES `Productos`(`ID`) ON DELETE CASCADE,
  INDEX `idx_fechas` (`FechaInicio`, `FechaFin`),
  INDEX `idx_activo` (`Activo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Avisos
-- ============================================
CREATE TABLE `Avisos` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `Titulo` VARCHAR(255) NOT NULL,
  `Contenido` TEXT NOT NULL,
  `Establecimiento` ENUM('Cafeteria','Cafecito','Ambos') NOT NULL,
  `TipoAviso` ENUM('General','Horario','NoLaboral','Oferta','Evento') NOT NULL,
  `Prioridad` ENUM('Normal','Importante') DEFAULT 'Normal',
  `FechaPublicacion` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `FechaInicio` DATE NOT NULL,
  `FechaFin` DATE NOT NULL,
  `IDUsuarioCreador` INT(11),
  `Activo` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDUsuarioCreador`) REFERENCES `Usuarios`(`ID`) ON DELETE SET NULL,
  INDEX `idx_establecimiento` (`Establecimiento`),
  INDEX `idx_fechas` (`FechaInicio`, `FechaFin`),
  INDEX `idx_activo` (`Activo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Historial de Cambios (para auditoría)
-- ============================================
CREATE TABLE `HistorialCambios` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `Tabla` VARCHAR(100) NOT NULL,
  `IDRegistro` INT(11) NOT NULL,
  `Accion` ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  `DatosAnteriores` JSON,
  `DatosNuevos` JSON,
  `IDUsuario` INT(11),
  `Fecha` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDUsuario`) REFERENCES `Usuarios`(`ID`) ON DELETE SET NULL,
  INDEX `idx_tabla_registro` (`Tabla`, `IDRegistro`),
  INDEX `idx_fecha` (`Fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Sesiones (opcional, para seguridad)
-- ============================================
CREATE TABLE `Sesiones` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `IDUsuario` INT(11) NOT NULL,
  `Token` VARCHAR(255) NOT NULL,
  `FechaCreacion` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `FechaExpiracion` TIMESTAMP NOT NULL,
  `IPAddress` VARCHAR(45),
  `UserAgent` TEXT,
  `Activa` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDUsuario`) REFERENCES `Usuarios`(`ID`) ON DELETE CASCADE,
  INDEX `idx_token` (`Token`),
  INDEX `idx_usuario` (`IDUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;