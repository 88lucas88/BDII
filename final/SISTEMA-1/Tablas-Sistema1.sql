------------------------------------------ Creación Sistema-1 ------------------------------------------

CREATE SCHEMA "SISTEMA-1";

-- Clientes (nro_Cliente, Nombre, tipo, dirección)
CREATE TABLE "SISTEMA-1".CLIENTES(
nro_cliente int NOT NULL, 
nombre varchar(30) NULL,
tipo varchar(30) NULL, 
dirección varchar(30) NULL,
CONSTRAINT PK_NRO_CLIENTE PRIMARY KEY (nro_cliente)
);

-- Producto (nro_Producto, Nombre, nro_categ, precio_actual)
CREATE TABLE "SISTEMA-1".PRODUCTO(
nro_producto int NOT NULL, 
nombre varchar(30) NULL,
nro_categ int NOT NULL,
precio_actual float NULL, 
CONSTRAINT PK_NRO_PRODUCTO PRIMARY KEY (nro_producto)
);

-- Categoria (nro_categ, descripción)
CREATE TABLE "SISTEMA-1".CATEGORIA(
nro_categ int NOT NULL, 
descripcion varchar(30) NULL, 
CONSTRAINT PK_NRO_CATEGORIA PRIMARY KEY (nro_categ)
);

-- Venta (Fecha_Vta, nro_Factura, nro_Cliente, Nombre, forma_pago)
CREATE TABLE "SISTEMA-1".VENTA(
fecha_vta timestamp DEFAULT current_timestamp, 
nro_factura int NOT NULL,
nro_cliente int NOT NULL,
nombre varchar(30) NULL, 
forma_pago char(30) NULL,
CONSTRAINT PK_NRO_FACTURA PRIMARY KEY (nro_factura)
);

-- Detalle_Venta(nro_factura, nro_producto, descripción, unidad, precio)
CREATE TABLE "SISTEMA-1".DETALLE_VENTA(
nro_factura int NOT NULL,
nro_producto int NOT NULL,
descripción varchar(30) NULL, 
unidad int NULL,
precio int NULL
);

ALTER TABLE "SISTEMA-1".PRODUCTO
ADD CONSTRAINT FK_PRODUCTO_CATEGORIA_NRO_CATEG FOREIGN KEY(nro_categ)
REFERENCES "SISTEMA-1".CATEGORIA (nro_categ)
on delete restrict on update restrict;

ALTER TABLE "SISTEMA-1".VENTA
ADD CONSTRAINT FK_VENTA_CLIENTE_NRO_CLIENTE FOREIGN KEY(nro_cliente)
REFERENCES "SISTEMA-1".CLIENTES (nro_cliente)
on delete restrict on update restrict;

ALTER TABLE "SISTEMA-1".DETALLE_VENTA
ADD CONSTRAINT FK_DETALLE_VENTA_NRO_FACTURA FOREIGN KEY(nro_factura)
REFERENCES "SISTEMA-1".VENTA (nro_factura)
on delete restrict on update restrict;

ALTER TABLE "SISTEMA-1".DETALLE_VENTA
ADD CONSTRAINT FK_DETALLE_PRODUCTO_NRO_PRODUCTO FOREIGN KEY(nro_producto)
REFERENCES "SISTEMA-1".PRODUCTO (nro_producto)
on delete restrict on update restrict;