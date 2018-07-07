CREATE SCHEMA "SISTEMA-1";

------------------------------------------ Creación Sistema-2 ------------------------------------------


CREATE SCHEMA "SISTEMA-2";


-- Clientes (cod_Cliente, Nombre, cod_tipo, dirección)
CREATE TABLE "SISTEMA-2".CLIENTES(
cod_cliente text NOT NULL, 
nombre varchar(30) NULL,
cod_tipo int NOT NULL,
dirección varchar(30) NULL,
CONSTRAINT PK_COD_CLIENTE PRIMARY KEY (cod_cliente)
);

-- Tipo_Cliente (cod_tipo, descripción)
CREATE TABLE "SISTEMA-2".TIPO_CLIENTE(
cod_tipo int NOT NULL, 
descripcion varchar(30) NULL,
CONSTRAINT PK_COD_TIPO PRIMARY KEY (cod_tipo)
);

ALTER TABLE "SISTEMA-2".CLIENTES
ADD CONSTRAINT FK_CLIENTES_TIPO_COD_TIPO FOREIGN KEY(cod_tipo)
REFERENCES "SISTEMA-2".TIPO_CLIENTE (cod_tipo)
on delete restrict on update restrict;

-- Producto (cod_Producto, Nombre, cod_categoria, cod_subcategoria, precio_actual)
CREATE TABLE "SISTEMA-2".PRODUCTO(
cod_producto text NOT NULL, 
nombre varchar(30) NULL,
cod_categoria text NOT NULL,
cod_subcategoria text NOT NULL,
precio_actual float NULL, 
CONSTRAINT PK_COD_PRODUCTO PRIMARY KEY (cod_producto)
);
							
-- Categoria (cod_categoria,  cod_subcategoría, descripción)
CREATE TABLE "SISTEMA-2".CATEGORIA(
cod_categoria text NOT NULL, 
cod_subcategoria text NOT NULL,
descripcion varchar(30) NULL, 
CONSTRAINT PK_COD_CATEGORIA PRIMARY KEY (cod_categoria, cod_subcategoria)
);

ALTER TABLE "SISTEMA-2".PRODUCTO
ADD CONSTRAINT FK_PRODUCTO_SUBCATEGORIA_COD_CATEGORIA_SUBCATEGORIA FOREIGN KEY(cod_categoria, cod_subcategoria)
REFERENCES "SISTEMA-2".CATEGORIA (cod_categoria, cod_subcategoria)
on delete restrict on update restrict;

-- Venta (Fecha_Vta, Id_Factura, cod_Cliente, Nombre, cod_medio_pago)
CREATE TABLE "SISTEMA-2".VENTA(
fecha_vta timestamp DEFAULT current_timestamp, 
id_factura int NOT NULL,
cod_cliente text NOT NULL, 
nombre varchar(30) NULL, 
cod_medio_pago int NOT NULL,
CONSTRAINT PK_ID_FACTURA PRIMARY KEY (id_factura)
);

-- Detalle_Venta(Id_factura, cod_producto, descripción, unidad, precio)
CREATE TABLE "SISTEMA-2".DETALLE_VENTA(
id_factura int NOT NULL,
cod_producto text NOT NULL,
descripción varchar(30) NULL, 
unidad int NULL,
precio int NULL
);

ALTER TABLE "SISTEMA-2".DETALLE_VENTA
ADD CONSTRAINT FK_DETALLE_VENTA_ID_FACTURA FOREIGN KEY(id_factura)
REFERENCES "SISTEMA-2".VENTA (id_factura)
on delete restrict on update restrict;

ALTER TABLE "SISTEMA-2".DETALLE_VENTA
ADD CONSTRAINT FK_DETALLE_PRODUCTO_COD_PRODUCTO FOREIGN KEY(cod_producto)
REFERENCES "SISTEMA-2".PRODUCTO (cod_producto)
on delete restrict on update restrict;

-- Medio_Pago( cod_Medio_Pago, descripción, valor, unidad, tipo_operación)
CREATE TABLE "SISTEMA-2".MEDIO_PAGO(
cod_medio_pago int NOT NULL, 
descripción varchar(30) NULL,
valor int NOT NULL,  
unidad int NULL,
tipo_operacion int NULL,
CONSTRAINT PK_COD_MEDIO_PAGO PRIMARY KEY (cod_medio_pago)
);

ALTER TABLE "SISTEMA-2".VENTA
ADD CONSTRAINT FK_VENTA_CLIENTE_NRO_CLIENTE FOREIGN KEY(cod_cliente)
REFERENCES "SISTEMA-2".CLIENTES (cod_cliente)
on delete restrict on update restrict;

ALTER TABLE "SISTEMA-2".VENTA
ADD CONSTRAINT FK_VENTA_MEDIO_COD_MEDIO_PAGO FOREIGN KEY(cod_medio_pago)
REFERENCES "SISTEMA-2".MEDIO_PAGO (cod_medio_pago)
on delete restrict on update restrict;