-- ============================================
-- SISTEMA DE CAFETERÍA - BASE DE DATOS
-- ============================================
-- SISTEMA DE SECCIONES DEL MENÚ
-- Las secciones permiten agrupar platillos (ej: "Hamburguesas", "Tacos", "Ensaladas")
-- y asignarlas de forma flexible a cualquier día/horario de cualquier semana
-- ============================================

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

-- ============================================
-- TABLA: Productos
-- ============================================
-- NOTA sobre PrecioBase:
-- - Si el producto NO tiene tamaños adicionales (nada en TamanosProductos):
--   El PrecioBase es el precio del producto
-- - Si el producto SÍ tiene tamaños (registros en TamanosProductos):
--   El PrecioBase puede ser el precio del tamaño más pequeño o un precio de referencia
--   Los precios reales vienen de TamanosProductos
-- ============================================
CREATE TABLE `Productos` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `Nombre` VARCHAR(255) NOT NULL,
  `Descripcion` TEXT,
  `PrecioBase` DECIMAL(10,2) NOT NULL,
  `IDCategoria` INT(11) NOT NULL,
  `Gramaje` DECIMAL(10,2), -- en gramos (para productos sin tamaños específicos)
  `Calorias` DECIMAL(10,2), -- kcal (para productos sin tamaños específicos)
  `URLFoto` TEXT,
  `Disponible` TINYINT(1) DEFAULT 1,
  `FechaCreacion` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDCategoria`) REFERENCES `CategoriasProductos`(`ID`) ON DELETE RESTRICT,
  INDEX `idx_categoria` (`IDCategoria`),
  INDEX `idx_disponible` (`Disponible`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Tamaños de Productos (NUEVA - Reemplaza TamanosBebidas)
-- ============================================
-- Sistema flexible de tamaños para CUALQUIER producto (bebidas Y comidas)
-- 
-- CARACTERÍSTICAS:
-- - Cada producto define sus propios tamaños (o ninguno)
-- - Los nombres son totalmente personalizables
-- - Los tamaños pueden tener diferentes capacidades/gramajes
-- - Si un producto no tiene registros aquí, significa que solo tiene un tamaño (el precio base)
--
-- EJEMPLOS:
-- - Café Latte: Chico (250ml, $40), Mediano (350ml, $50), Grande (450ml, $60)
-- - Smoothie Verde: Solo Mediano (400ml, $65) y Grande (600ml, $80)
-- - Tacos: Orden Completa (4 pzas, $85), Media Orden (2 pzas, $45)
-- - Chilaquiles: Pequeño (200g, $60), Grande (350g, $90)
-- - Hamburguesa Clásica: Sin tamaños adicionales (solo precio base del producto)
-- ============================================
CREATE TABLE `TamanosProductos` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `IDProducto` INT(11) NOT NULL,
  `Nombre` VARCHAR(50) NOT NULL, -- Chico, Mediano, Grande, Orden Completa, Media Orden, Individual, Para Compartir, etc.
  `Descripcion` VARCHAR(255), -- Descripción adicional del tamaño (ej: "4 piezas", "Porción individual")
  `Capacidad` DECIMAL(10,2), -- en ml (para bebidas) o NULL si no aplica
  `Gramaje` DECIMAL(10,2), -- en gramos (para comida) o NULL si no aplica
  `Piezas` INT(3), -- número de piezas (para tacos, nuggets, etc.) o NULL si no aplica
  `Precio` DECIMAL(10,2) NOT NULL,
  `Orden` INT(3) DEFAULT 1, -- Para ordenar los tamaños (1=más pequeño, 2=mediano, 3=más grande)
  `Disponible` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDProducto`) REFERENCES `Productos`(`ID`) ON DELETE CASCADE,
  INDEX `idx_producto` (`IDProducto`),
  INDEX `idx_disponible` (`Disponible`),
  INDEX `idx_orden` (`Orden`)
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
('Endulzantes', 'Azúcares y sustitutos'),
('Lácteos Vegetales', 'Leches vegetales y alternativas sin lactosa');

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
  INDEX `idx_ingrediente_sustituto` (`IDIngredienteSustituto`),
  UNIQUE KEY `unique_sustitucion` (`IDProductoIngrediente`, `IDIngredienteSustituto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Secciones del Menú
-- ============================================
-- Esta tabla define las secciones que agrupan platillos
-- Ejemplos: "Hamburguesas", "Tacos", "Ensaladas", "Desayunos Rápidos", etc.
-- 
-- NOTA: Si se desea auditoría más detallada, se podría agregar:
-- - IDUsuarioCreador, FechaCreacion, IDUsuarioModificador, FechaModificacion
-- ============================================
CREATE TABLE `SeccionesMenu` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `Nombre` VARCHAR(100) NOT NULL,
  `Descripcion` TEXT,
  `URLFoto` TEXT, -- Imagen representativa de la sección
  `Color` VARCHAR(7), -- Color hex para identificación visual (ej: #FF5733)
  `Activo` TINYINT(1) DEFAULT 1,
  `FechaCreacion` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  INDEX `idx_nombre` (`Nombre`),
  INDEX `idx_activo` (`Activo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ejemplos de secciones
-- INSERT INTO `SeccionesMenu` (`Nombre`, `Descripcion`, `Color`) VALUES
-- ('Hamburguesas', 'Variedad de hamburguesas artesanales', '#FF6B35'),
-- ('Tacos', 'Tacos tradicionales mexicanos', '#F7931E'),
-- ('Ensaladas', 'Ensaladas frescas y saludables', '#4CAF50'),
-- ('Desayunos Rápidos', 'Opciones rápidas para el desayuno', '#FFC107'),
-- ('Comida del Día', 'Platillos especiales del día', '#2196F3');

-- ============================================
-- NUEVA TABLA: Productos de las Secciones
-- ============================================
-- Define qué productos pertenecen a cada sección
-- Un mismo producto puede estar en múltiples secciones si es necesario
-- ============================================
CREATE TABLE `SeccionesMenuProductos` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `IDSeccion` INT(11) NOT NULL,
  `IDProducto` INT(11) NOT NULL,
  `Orden` INT(3), -- Para ordenar los productos dentro de la sección
  `Destacado` TINYINT(1) DEFAULT 0, -- Para resaltar productos especiales
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDSeccion`) REFERENCES `SeccionesMenu`(`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`IDProducto`) REFERENCES `Productos`(`ID`) ON DELETE CASCADE,
  INDEX `idx_seccion` (`IDSeccion`),
  INDEX `idx_producto` (`IDProducto`),
  UNIQUE KEY `unique_seccion_producto` (`IDSeccion`, `IDProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Menú Semanal (MODIFICADA)
-- ============================================
-- Representa un día/horario específico del menú
-- Cada registro es un "slot" donde se pueden asignar secciones
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
  INDEX `idx_activo` (`Activo`),
  INDEX `idx_dia_horario` (`DiaSemana`, `Horario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Secciones del Menú Semanal (CON REGISTRO DE AUDITORÍA)
-- ============================================
-- Asigna secciones completas a días/horarios específicos
-- Esta es la tabla CLAVE para la flexibilidad que necesitas
-- 
-- REGISTRO DE AUDITORÍA:
-- - IDUsuarioAsigno: Quién asignó esta sección al menú
-- - FechaAsignacion: Cuándo se asignó la sección
-- 
-- EJEMPLOS DE USO:
-- - Lunes semana 1, Comida: Sección "Hamburguesas"
-- - Miércoles semana 2, Desayuno: Sección "Hamburguesas"
-- - Toda semana 3, Lunes/Miércoles/Viernes Comida: Sección "Hamburguesas"
-- - Toda semana 3, Martes/Jueves Desayuno: Sección "Hamburguesas"
-- ============================================
CREATE TABLE `MenuSemanalSecciones` (
  `ID` INT(11) NOT NULL AUTO_INCREMENT,
  `IDMenuSemanal` INT(11) NOT NULL, -- El día/horario específico
  `IDSeccion` INT(11) NOT NULL, -- La sección que se muestra ese día/horario
  `Orden` INT(3), -- Orden si hay múltiples secciones en el mismo día/horario
  `IDUsuarioAsigno` INT(11), -- Administrador que asignó esta sección
  `FechaAsignacion` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  FOREIGN KEY (`IDMenuSemanal`) REFERENCES `MenuSemanal`(`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`IDSeccion`) REFERENCES `SeccionesMenu`(`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`IDUsuarioAsigno`) REFERENCES `Usuarios`(`ID`) ON DELETE SET NULL,
  INDEX `idx_menu` (`IDMenuSemanal`),
  INDEX `idx_seccion` (`IDSeccion`),
  INDEX `idx_usuario` (`IDUsuarioAsigno`),
  UNIQUE KEY `unique_menu_seccion` (`IDMenuSemanal`, `IDSeccion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLA: Producto Especial
-- ============================================
CREATE TABLE `ProductosEspeciales` (
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

-- ============================================
-- NOTAS IMPORTANTES SOBRE AUDITORÍA
-- ============================================
-- 
-- MANEJO DE IDUsuarioModificador:
-- El campo IDUsuarioModificador en MenuSemanal debe actualizarse manualmente en tu código
-- cuando un administrador modifica el menú. Ejemplo en PHP/Python/etc:
-- 
-- UPDATE MenuSemanal 
-- SET IDUsuarioModificador = [ID_del_administrador_actual]
-- WHERE ID = [ID_del_menu];
-- 
-- El campo FechaModificacion se actualiza automáticamente gracias a:
-- ON UPDATE CURRENT_TIMESTAMP
-- 
-- TRIGGER OPCIONAL (para actualización automática del modificador):
-- Si deseas que IDUsuarioModificador se actualice automáticamente,
-- deberías crear un trigger, pero esto requiere guardar el ID del usuario
-- en una variable de sesión de MySQL. Esto es más complejo y generalmente
-- se maneja mejor desde la aplicación.
-- 
-- EJEMPLO DE TRIGGER (si lo deseas implementar):
-- DELIMITER $
-- CREATE TRIGGER before_menu_update
-- BEFORE UPDATE ON MenuSemanal
-- FOR EACH ROW
-- BEGIN
--   -- Obtener el ID de usuario de la sesión
--   SET NEW.IDUsuarioModificador = @current_user_id;
-- END$
-- DELIMITER ;
-- 
-- Luego en tu código antes de hacer UPDATE:
-- SET @current_user_id = [ID_del_administrador];
-- 
-- HISTORIAL COMPLETO:
-- Para un historial más detallado de TODOS los cambios, usa la tabla
-- HistorialCambios que registra los datos antes y después de cada modificación.
-- 
-- ============================================

-- ============================================
-- EJEMPLOS DE USO: SISTEMA DE TAMAÑOS
-- ============================================

-- ===== EJEMPLO 1: Café Latte con 3 tamaños =====
-- Producto base (precio base puede ser el más económico o un promedio)
-- INSERT INTO Productos (Nombre, Descripcion, PrecioBase, IDCategoria) 
-- VALUES ('Café Latte', 'Espresso con leche vaporizada', 40.00, 4);

-- Definir los 3 tamaños con diferentes capacidades y precios
-- INSERT INTO TamanosProductos (IDProducto, Nombre, Capacidad, Precio, Orden) VALUES
-- (1, 'Chico', 250.00, 40.00, 1),
-- (1, 'Mediano', 350.00, 50.00, 2),
-- (1, 'Grande', 450.00, 60.00, 3);

-- ===== EJEMPLO 2: Smoothie con solo 2 tamaños =====
-- INSERT INTO Productos (Nombre, Descripcion, PrecioBase, IDCategoria) 
-- VALUES ('Smoothie de Fresa', 'Smoothie natural de fresa', 65.00, 3);

-- Solo Mediano y Grande (no tiene Chico)
-- INSERT INTO TamanosProductos (IDProducto, Nombre, Capacidad, Precio, Orden) VALUES
-- (2, 'Mediano', 400.00, 65.00, 1),
-- (2, 'Grande', 600.00, 80.00, 2);

-- ===== EJEMPLO 3: Café Americano con diferentes ml que el Latte =====
-- INSERT INTO Productos (Nombre, Descripcion, PrecioBase, IDCategoria) 
-- VALUES ('Café Americano', 'Espresso con agua caliente', 35.00, 4);

-- El "Grande" aquí es de 500ml, diferente al Latte (450ml)
-- INSERT INTO TamanosProductos (IDProducto, Nombre, Capacidad, Precio, Orden) VALUES
-- (3, 'Chico', 300.00, 35.00, 1),
-- (3, 'Mediano', 400.00, 42.00, 2),
-- (3, 'Grande', 500.00, 50.00, 3);

-- ===== EJEMPLO 4: Tacos con órdenes =====
-- INSERT INTO Productos (Nombre, Descripcion, PrecioBase, IDCategoria) 
-- VALUES ('Tacos de Asada', 'Tacos de carne asada', 85.00, 2);

-- Órdenes con número de piezas
-- INSERT INTO TamanosProductos (IDProducto, Nombre, Descripcion, Piezas, Precio, Orden) VALUES
-- (4, 'Media Orden', '2 tacos', 2, 45.00, 1),
-- (4, 'Orden Completa', '4 tacos', 4, 85.00, 2);

-- ===== EJEMPLO 5: Chilaquiles con tamaños de peso =====
-- INSERT INTO Productos (Nombre, Descripcion, PrecioBase, IDCategoria) 
-- VALUES ('Chilaquiles Verdes', 'Chilaquiles con salsa verde', 60.00, 1);

-- Tamaños por gramaje
-- INSERT INTO TamanosProductos (IDProducto, Nombre, Gramaje, Precio, Orden) VALUES
-- (5, 'Pequeño', 200.00, 60.00, 1),
-- (5, 'Grande', 350.00, 90.00, 2);

-- ===== EJEMPLO 6: Hamburguesa SIN tamaños adicionales =====
-- INSERT INTO Productos (Nombre, Descripcion, PrecioBase, IDCategoria) 
-- VALUES ('Hamburguesa Clásica', 'Hamburguesa con queso', 75.00, 2);

-- NO se inserta nada en TamanosProductos
-- Esto significa que solo hay un tamaño al precio base

-- ===== EJEMPLO 7: Nuggets con paquetes =====
-- INSERT INTO Productos (Nombre, Descripcion, PrecioBase, IDCategoria) 
-- VALUES ('Nuggets de Pollo', 'Nuggets crujientes', 50.00, 2);

-- Diferentes paquetes
-- INSERT INTO TamanosProductos (IDProducto, Nombre, Descripcion, Piezas, Precio, Orden) VALUES
-- (7, '6 Piezas', 'Paquete individual', 6, 50.00, 1),
-- (7, '10 Piezas', 'Paquete mediano', 10, 75.00, 2),
-- (7, '20 Piezas', 'Paquete familiar', 20, 130.00, 3);

-- ===== EJEMPLO 8: Ensalada con porciones personalizadas =====
-- INSERT INTO Productos (Nombre, Descripcion, PrecioBase, IDCategoria) 
-- VALUES ('Ensalada Caesar', 'Ensalada con aderezo caesar', 70.00, 2);

-- INSERT INTO TamanosProductos (IDProducto, Nombre, Descripcion, Gramaje, Precio, Orden) VALUES
-- (8, 'Individual', 'Porción personal', 250.00, 70.00, 1),
-- (8, 'Para Compartir', 'Porción para 2-3 personas', 500.00, 120.00, 2);

-- ===== EJEMPLO 9: Refresco solo en Grande =====
-- INSERT INTO Productos (Nombre, Descripcion, PrecioBase, IDCategoria) 
-- VALUES ('Agua Mineral', 'Agua mineral con gas', 35.00, 3);

-- Solo tiene un tamaño disponible
-- INSERT INTO TamanosProductos (IDProducto, Nombre, Capacidad, Precio, Orden) VALUES
-- (9, 'Grande', 600.00, 35.00, 1);

-- ===== EJEMPLO 10: Papas con diferentes presentaciones =====
-- INSERT INTO Productos (Nombre, Descripcion, PrecioBase, IDCategoria) 
-- VALUES ('Papas a la Francesa', 'Papas fritas crujientes', 45.00, 2);

-- Combinación de porciones y gramaje
-- INSERT INTO TamanosProductos (IDProducto, Nombre, Descripcion, Gramaje, Precio, Orden) VALUES
-- (10, 'Chica', 'Porción individual', 150.00, 45.00, 1),
-- (10, 'Mediana', 'Porción regular', 250.00, 65.00, 2),
-- (10, 'Grande', 'Porción familiar', 400.00, 95.00, 3),
-- (10, 'Jumbo', 'Porción para compartir', 600.00, 130.00, 4);

-- ===== EJEMPLO 11: Quesadilla - solo Chica y Grande (sin Mediana) =====
-- INSERT INTO Productos (Nombre, Descripcion, PrecioBase, IDCategoria) 
-- VALUES ('Quesadilla de Queso', 'Quesadilla tradicional', 35.00, 1);

-- Solo dos tamaños disponibles (saltando el mediano)
-- INSERT INTO TamanosProductos (IDProducto, Nombre, Descripcion, Precio, Orden) VALUES
-- (11, 'Chica', '1 quesadilla', 35.00, 1),
-- (11, 'Grande', '2 quesadillas', 60.00, 2);

-- ============================================
-- CONSULTAS ÚTILES PARA TAMAÑOS
-- ============================================

-- Ver todos los tamaños disponibles de un producto:
-- SELECT tp.Nombre, tp.Descripcion, tp.Capacidad, tp.Gramaje, tp.Piezas, tp.Precio
-- FROM TamanosProductos tp
-- WHERE tp.IDProducto = 1 AND tp.Disponible = 1
-- ORDER BY tp.Orden;

-- Ver productos SIN tamaños adicionales (solo precio base):
-- SELECT p.Nombre, p.PrecioBase
-- FROM Productos p
-- LEFT JOIN TamanosProductos tp ON p.ID = tp.IDProducto
-- WHERE tp.ID IS NULL;

-- Ver todos los productos con sus tamaños (si tienen):
-- SELECT p.Nombre as Producto, 
--        COALESCE(tp.Nombre, 'Tamaño Único') as Tamaño,
--        COALESCE(tp.Precio, p.PrecioBase) as Precio,
--        tp.Capacidad, tp.Gramaje, tp.Piezas
-- FROM Productos p
-- LEFT JOIN TamanosProductos tp ON p.ID = tp.IDProducto
-- ORDER BY p.Nombre, tp.Orden;

-- ============================================
-- EJEMPLOS DE USO DEL SISTEMA DE SECCIONES
-- ============================================

-- ===== PASO 1: Crear la sección "Hamburguesas" =====
-- INSERT INTO SeccionesMenu (Nombre, Descripcion, Color) 
-- VALUES ('Hamburguesas', 'Nuestras deliciosas hamburguesas artesanales', '#FF6B35');

-- ===== PASO 2: Agregar productos a la sección =====
-- INSERT INTO SeccionesMenuProductos (IDSeccion, IDProducto, Orden) VALUES
-- (1, 10, 1),  -- Hamburguesa Clásica
-- (1, 11, 2),  -- Hamburguesa BBQ
-- (1, 12, 3),  -- Hamburguesa Mexicana
-- (1, 13, 4);  -- Hamburguesa Vegetariana

-- ===== PASO 3: Crear entradas en MenuSemanal para días específicos =====
-- NOTA: Ahora se requiere el IDUsuarioCreador (el administrador que crea el menú)

-- --- SEMANA 1 (Lunes 14 Oct 2024 - Viernes 18 Oct 2024) ---
-- Lunes 14 Oct, Comida - Creado por el usuario con ID 1
-- INSERT INTO MenuSemanal (Fecha, DiaSemana, Horario, NumeroSemana, Anio, IDUsuarioCreador) 
-- VALUES ('2024-10-14', 'Lunes', 'Comida', 42, 2024, 1);

-- Asignar sección "Hamburguesas" al Lunes 14 Oct en Comida
-- El administrador con ID 1 asigna esta sección
-- INSERT INTO MenuSemanalSecciones (IDMenuSemanal, IDSeccion, Orden, IDUsuarioAsigno) 
-- VALUES (1, 1, 1, 1);

-- Martes 15 Oct - NO hay hamburguesas, puedes asignar otra sección o dejar vacío

-- --- SEMANA 2 (Lunes 21 Oct 2024 - Viernes 25 Oct 2024) ---
-- Miércoles 23 Oct, Desayuno - Creado por el usuario con ID 2
-- INSERT INTO MenuSemanal (Fecha, DiaSemana, Horario, NumeroSemana, Anio, IDUsuarioCreador) 
-- VALUES ('2024-10-23', 'Miércoles', 'Desayuno', 43, 2024, 2);

-- Asignar sección "Hamburguesas" al Miércoles 23 Oct en Desayuno
-- INSERT INTO MenuSemanalSecciones (IDMenuSemanal, IDSeccion, Orden, IDUsuarioAsigno) 
-- VALUES (5, 1, 1, 2);

-- --- SEMANA 3 (Lunes 28 Oct 2024 - Viernes 1 Nov 2024) ---
-- Hamburguesas en COMIDA: Lunes, Miércoles, Viernes
-- Creados por el administrador con ID 1
-- INSERT INTO MenuSemanal (Fecha, DiaSemana, Horario, NumeroSemana, Anio, IDUsuarioCreador) VALUES
-- ('2024-10-28', 'Lunes', 'Comida', 44, 2024, 1),
-- ('2024-10-30', 'Miércoles', 'Comida', 44, 2024, 1),
-- ('2024-11-01', 'Viernes', 'Comida', 44, 2024, 1);

-- INSERT INTO MenuSemanalSecciones (IDMenuSemanal, IDSeccion, Orden, IDUsuarioAsigno) VALUES
-- (10, 1, 1, 1),  -- Lunes 28 Comida
-- (11, 1, 1, 1),  -- Miércoles 30 Comida
-- (12, 1, 1, 1);  -- Viernes 1 Comida

-- Hamburguesas en DESAYUNO: Martes, Jueves
-- INSERT INTO MenuSemanal (Fecha, DiaSemana, Horario, NumeroSemana, Anio, IDUsuarioCreador) VALUES
-- ('2024-10-29', 'Martes', 'Desayuno', 44, 2024, 1),
-- ('2024-10-31', 'Jueves', 'Desayuno', 44, 2024, 1);

-- INSERT INTO MenuSemanalSecciones (IDMenuSemanal, IDSeccion, Orden, IDUsuarioAsigno) VALUES
-- (13, 1, 1, 1),  -- Martes 29 Desayuno
-- (14, 1, 1, 1);  -- Jueves 31 Desayuno

-- ============================================
-- CONSULTAS ÚTILES
-- ============================================

-- === CONSULTAS PARA TAMAÑOS ===

-- Ver todos los tamaños disponibles de un producto específico:
-- SELECT tp.Nombre, tp.Descripcion, tp.Capacidad, tp.Gramaje, tp.Piezas, tp.Precio
-- FROM TamanosProductos tp
-- WHERE tp.IDProducto = 1 AND tp.Disponible = 1
-- ORDER BY tp.Orden;

-- Ver productos SIN tamaños adicionales (solo precio base):
-- SELECT p.Nombre, p.PrecioBase
-- FROM Productos p
-- LEFT JOIN TamanosProductos tp ON p.ID = tp.IDProducto
-- WHERE tp.ID IS NULL;

-- Ver todos los productos con sus tamaños (si tienen):
-- SELECT p.Nombre as Producto, 
--        COALESCE(tp.Nombre, 'Tamaño Único') as Tamaño,
--        COALESCE(tp.Precio, p.PrecioBase) as Precio,
--        tp.Capacidad, tp.Gramaje, tp.Piezas
-- FROM Productos p
-- LEFT JOIN TamanosProductos tp ON p.ID = tp.IDProducto
-- ORDER BY p.Nombre, tp.Orden;

-- Determinar si un producto tiene tamaños o no:
-- SELECT p.ID, p.Nombre,
--        CASE 
--          WHEN COUNT(tp.ID) > 0 THEN 'Tiene tamaños'
--          ELSE 'Tamaño único'
--        END as TipoProducto,
--        COUNT(tp.ID) as NumeroTamanos
-- FROM Productos p
-- LEFT JOIN TamanosProductos tp ON p.ID = tp.IDProducto
-- GROUP BY p.ID, p.Nombre;

-- === CONSULTAS PARA SECCIONES DEL MENÚ ===

-- Ver todas las secciones disponibles en un día/horario específico:
-- SELECT s.Nombre, s.Descripcion 
-- FROM MenuSemanal m
-- JOIN MenuSemanalSecciones ms ON m.ID = ms.IDMenuSemanal
-- JOIN SeccionesMenu s ON ms.IDSeccion = s.ID
-- WHERE m.Fecha = '2024-10-28' AND m.Horario = 'Comida'
-- ORDER BY ms.Orden;

-- Ver todos los productos disponibles en un día/horario específico:
-- SELECT p.Nombre, p.Descripcion, p.PrecioBase, s.Nombre as Seccion
-- FROM MenuSemanal m
-- JOIN MenuSemanalSecciones ms ON m.ID = ms.IDMenuSemanal
-- JOIN SeccionesMenu s ON ms.IDSeccion = s.ID
-- JOIN SeccionesMenuProductos sp ON s.ID = sp.IDSeccion
-- JOIN Productos p ON sp.IDProducto = p.ID
-- WHERE m.Fecha = '2024-10-28' AND m.Horario = 'Comida'
-- ORDER BY s.Nombre, sp.Orden;

-- Ver el menú completo de una semana:
-- SELECT m.Fecha, m.DiaSemana, m.Horario, s.Nombre as Seccion
-- FROM MenuSemanal m
-- JOIN MenuSemanalSecciones ms ON m.ID = ms.IDMenuSemanal
-- JOIN SeccionesMenu s ON ms.IDSeccion = s.ID
-- WHERE m.NumeroSemana = 44 AND m.Anio = 2024
-- ORDER BY m.Fecha, m.Horario, ms.Orden;

-- === CONSULTAS DE AUDITORÍA ===

-- Ver quién creó cada menú de una semana específica:
-- SELECT m.Fecha, m.DiaSemana, m.Horario,
--        u.Nombre as CreadorNombre, u.ApellidoPaterno as CreadorApellido,
--        m.FechaCreacion
-- FROM MenuSemanal m
-- JOIN Usuarios u ON m.IDUsuarioCreador = u.ID
-- WHERE m.NumeroSemana = 44 AND m.Anio = 2024
-- ORDER BY m.Fecha, m.Horario;

-- Ver menús creados por un administrador específico:
-- SELECT m.Fecha, m.DiaSemana, m.Horario, m.NumeroSemana, m.Anio,
--        m.FechaCreacion
-- FROM MenuSemanal m
-- WHERE m.IDUsuarioCreador = 1
-- ORDER BY m.Fecha DESC;

-- Ver historial completo de un menú (creación y modificaciones):
-- SELECT m.Fecha, m.Horario,
--        uc.Nombre as CreadorNombre, uc.ApellidoPaterno as CreadorApellido,
--        m.FechaCreacion,
--        um.Nombre as ModificadorNombre, um.ApellidoPaterno as ModificadorApellido,
--        m.FechaModificacion
-- FROM MenuSemanal m
-- JOIN Usuarios uc ON m.IDUsuarioCreador = uc.ID
-- LEFT JOIN Usuarios um ON m.IDUsuarioModificador = um.ID
-- WHERE m.Fecha = '2024-10-28' AND m.Horario = 'Comida';

-- Ver quién asignó cada sección a los menús:
-- SELECT m.Fecha, m.DiaSemana, m.Horario,
--        s.Nombre as Seccion,
--        u.Nombre as AsignadoPor, u.ApellidoPaterno,
--        ms.FechaAsignacion
-- FROM MenuSemanal m
-- JOIN MenuSemanalSecciones ms ON m.ID = ms.IDMenuSemanal
-- JOIN SeccionesMenu s ON ms.IDSeccion = s.ID
-- LEFT JOIN Usuarios u ON ms.IDUsuarioAsigno = u.ID
-- WHERE m.NumeroSemana = 44 AND m.Anio = 2024
-- ORDER BY m.Fecha, m.Horario, ms.Orden;

-- Ver estadísticas de menús creados por administrador:
-- SELECT u.Nombre, u.ApellidoPaterno,
--        COUNT(m.ID) as MenusCreados,
--        MIN(m.FechaCreacion) as PrimerMenu,
--        MAX(m.FechaCreacion) as UltimoMenu
-- FROM Usuarios u
-- LEFT JOIN MenuSemanal m ON u.ID = m.IDUsuarioCreador
-- WHERE u.Tipo = 'Administrador'
-- GROUP BY u.ID, u.Nombre, u.ApellidoPaterno
-- ORDER BY MenusCreados DESC;

-- Ver menús modificados recientemente:
-- SELECT m.Fecha, m.DiaSemana, m.Horario,
--        uc.Nombre as Creador,
--        um.Nombre as UltimoModificador,
--        m.FechaModificacion
-- FROM MenuSemanal m
-- JOIN Usuarios uc ON m.IDUsuarioCreador = uc.ID
-- LEFT JOIN Usuarios um ON m.IDUsuarioModificador = um.ID
-- WHERE m.FechaModificacion IS NOT NULL
-- ORDER BY m.FechaModificacion DESC
-- LIMIT 20;

-- ============================================
-- VENTAJAS DEL SISTEMA
-- ============================================

-- === SISTEMA DE SECCIONES DEL MENÚ ===
-- ✅ Máxima flexibilidad: Asigna cualquier sección a cualquier día/horario
-- ✅ Modular: Las secciones son reutilizables en diferentes días/semanas
-- ✅ Fácil gestión: Cambias los productos de una sección y se reflejan en todos los menús
-- ✅ Múltiples secciones: Puedes tener varias secciones en el mismo día/horario
-- ✅ Historial completo: Se mantiene registro de todos los menús anteriores
-- ✅ Escalable: Fácil de expandir para nuevas funcionalidades

-- === SISTEMA DE TAMAÑOS FLEXIBLE ===
-- ✅ Universal: Funciona para bebidas, comidas, snacks, cualquier producto
-- ✅ Personalizable: Cada producto define sus propios tamaños con nombres únicos
-- ✅ Sin restricciones: Un producto puede tener 1, 2, 3, o más tamaños
-- ✅ Diferentes medidas: Capacidad (ml), Gramaje (g), Piezas, o combinaciones
-- ✅ Opcional: Si un producto no tiene tamaños, usa solo el precio base
-- ✅ Variabilidad: El "Grande" de un producto puede ser diferente al de otro
-- ✅ Flexibilidad en nombres: "Media Orden", "Para Compartir", "Familiar", etc.

-- === SISTEMA DE SUSTITUCIÓN DE INGREDIENTES ===
-- ✅ Control total sobre sustitutos por producto
-- ✅ Manejo de opciones de leche sin tabla separada
-- ✅ Costos adicionales personalizables
-- ✅ Compatibilidad: No aparecen opciones incompatibles (ej: leche de vaca en bebidas veganas)

-- === SISTEMA DE AUDITORÍA Y RASTREABILIDAD ===
-- ✅ Registro de creación: Quién creó cada menú y cuándo
-- ✅ Registro de modificación: Quién modificó cada menú y cuándo
-- ✅ Registro de asignación: Quién asignó cada sección a cada menú
-- ✅ Trazabilidad completa: Seguimiento de todos los cambios en el sistema
-- ✅ Responsabilidad: Cada administrador es responsable de sus acciones
-- ✅ Histórico detallado: Para análisis y reportes de gestión
-- ✅ Consultas de auditoría: Fácil acceso a información de quién hizo qué
-- ✅ Prevención de conflictos: Identificar rápidamente quién hizo cambios
-- ✅ Integración con HistorialCambios: Sistema completo de auditoría