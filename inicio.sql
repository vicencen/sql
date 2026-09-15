-- 1. CREACIÓN DE LA BASE DE DATOS
CREATE DATABASE SQL_Warriors;
GO

USE SQL_Warriors;
GO

-- ==========================================
-- 2. TABLAS INDEPENDIENTES (Nivel 1)
-- ==========================================

CREATE TABLE CategoriaProducto (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    descripcion VARCHAR(MAX)
);

CREATE TABLE Proveedor (
    id_proveedor INT IDENTITY(1,1) PRIMARY KEY,
    razon_social VARCHAR(150) NOT NULL,
    cuit VARCHAR(20) UNIQUE NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(255)
);

CREATE TABLE MateriaPrima (
    id_materia_prima INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(200) NOT NULL,
    tipo VARCHAR(50) NOT NULL, -- Ej: metal, gema, insumo
    unidad_medida VARCHAR(20) NOT NULL,
    stock_actual DECIMAL(10,2) DEFAULT 0,
    costo_unitario DECIMAL(12,2) NOT NULL
);

CREATE TABLE Puesto (
    id_puesto INT IDENTITY(1,1) PRIMARY KEY,
    nombre_puesto VARCHAR(100) NOT NULL,
    descripcion VARCHAR(MAX),
    salario_basico DECIMAL(12,2) NOT NULL
);

CREATE TABLE Cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    tipo_doc VARCHAR(20),
    nro_doc VARCHAR(20) UNIQUE,
    email VARCHAR(100),
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    fecha_alta DATE NOT NULL
);

-- ==========================================
-- 3. TABLAS CON DEPENDENCIAS SIMPLES (Nivel 2)
-- ==========================================

CREATE TABLE Empleado (
    id_empleado INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    nro_doc VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(20),
    fecha_ingreso DATE NOT NULL,
    id_puesto INT NOT NULL,
    FOREIGN KEY (id_puesto) REFERENCES Puesto(id_puesto)
);

CREATE TABLE Producto (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(MAX),
    peso_gramos DECIMAL(10,2),
    precio_venta DECIMAL(12,2) NOT NULL,
    es_fabricacion_propia BIT NOT NULL, -- Reemplazo de BOOLEAN para SQL Server (0 = falso, 1 = verdadero)
    stock_actual INT DEFAULT 0,
    id_categoria INT NOT NULL,
    id_proveedor INT NULL, -- Es opcional
    FOREIGN KEY (id_categoria) REFERENCES CategoriaProducto(id_categoria),
    FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor)
);

-- ==========================================
-- 4. TABLAS CON MÚLTIPLES DEPENDENCIAS (Nivel 3)
-- ==========================================

CREATE TABLE ProductoMateriaPrima (
    id_producto INT NOT NULL,
    id_materia_prima INT NOT NULL,
    cantidad_utilizada DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_producto, id_materia_prima),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    FOREIGN KEY (id_materia_prima) REFERENCES MateriaPrima(id_materia_prima)
);

CREATE TABLE CompraMateriaPrima (
    id_compra INT IDENTITY(1,1) PRIMARY KEY,
    fecha_compra DATE NOT NULL,
    nro_comprobante VARCHAR(50) NOT NULL,
    monto_total DECIMAL(12,2) NOT NULL,
    id_proveedor INT NOT NULL,
    id_empleado INT NOT NULL,
    FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);

CREATE TABLE Venta (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    fecha_venta DATETIME NOT NULL,
    canal VARCHAR(50) NOT NULL, -- local / online
    monto_total DECIMAL(12,2) NOT NULL,
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);

CREATE TABLE Encargo (
    id_encargo INT IDENTITY(1,1) PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL, -- nuevo / reparacion
    fecha_solicitud DATE NOT NULL,
    fecha_estimada_entrega DATE,
    descripcion VARCHAR(MAX) NOT NULL,
    precio_acordado DECIMAL(12,2) NOT NULL,
    id_cliente INT NOT NULL,
    id_empleado INT NULL, -- Es opcional
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);

-- ==========================================
-- 5. TABLAS DE DETALLES Y FLUJOS DEPENDIENTES (Nivel 4)
-- ==========================================

CREATE TABLE DetalleCompraMateriaPrima (
    id_compra INT NOT NULL,
    id_materia_prima INT NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_compra, id_materia_prima),
    FOREIGN KEY (id_compra) REFERENCES CompraMateriaPrima(id_compra),
    FOREIGN KEY (id_materia_prima) REFERENCES MateriaPrima(id_materia_prima)
);

CREATE TABLE DetalleVenta (
    id_venta INT NOT NULL,
    nro_item INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_venta, nro_item),
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

CREATE TABLE Pago (
    id_venta INT NOT NULL,
    nro_pago INT NOT NULL,
    fecha_pago DATETIME NOT NULL,
    medio_pago VARCHAR(50) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_venta, nro_pago),
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta)
);

CREATE TABLE CertificadoAutenticidad (
    nro_certificado VARCHAR(100) PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    fecha_emision DATE NOT NULL,
    sello VARCHAR(255),
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

CREATE TABLE Envio (
    id_venta INT NOT NULL PRIMARY KEY,
    direccion_envio VARCHAR(255) NOT NULL,
    transportista VARCHAR(100),
    fecha_envio DATE,
    estado_envio VARCHAR(50) NOT NULL,
    nro_seguimiento VARCHAR(100),
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta)
);

CREATE TABLE HistorialEstadoEncargo (
    id_encargo INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    estado VARCHAR(50) NOT NULL,
    observaciones VARCHAR(MAX),
    id_empleado INT NOT NULL,
    PRIMARY KEY (id_encargo, fecha_hora),
    FOREIGN KEY (id_encargo) REFERENCES Encargo(id_encargo),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);
GO
