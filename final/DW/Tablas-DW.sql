------------------------------------------- Implementación DW ------------------------------------------
CREATE EXTENSION dblink;


-- TABLA TIEMPO
CREATE TABLE TIEMPO (
	Id_Tiempo serial,
	mes int NOT NULL,
	año int NOT NULL,
	trimetres int NOT NULL,
	CONSTRAINT PK_TIEMPO PRIMARY KEY (Id_Tiempo)
);

-- Medio_pago (Id_MedioPago, descripción)
CREATE TABLE MEDIO_PAGO(
	Id_MedioPago int NOT NULL, 
	descripción varchar(30) NULL,
	CONSTRAINT PK_COD_MEDIO_PAGO PRIMARY KEY (Id_MedioPago)
);

-- Categoria (cod_categoria,  cod_subcategoría, descripción)
CREATE TABLE CATEGORIA(
	Id_Categoria text NOT NULL, 
	Id_subcategoria text NOT NULL,
	descripcion varchar(30) NULL, 
	CONSTRAINT PK_ID_CATEGORIA PRIMARY KEY (Id_Categoria, Id_subcategoria)
);--DROP TABLE CATEGORIA

-- Tipo_Cliente (Id_Tipo, descripción)
CREATE TABLE TIPO_CLIENTE(
	Id_Tipo int NOT NULL, 
	descripcion varchar(30) NULL,
	CONSTRAINT PK_ID_TIPO PRIMARY KEY (Id_Tipo)
);

 SELECT dblink_connect('conect_suc1', 'hostaddr=192.168.43.243 port=5432 dbname=PatSur-Suc-1 user=postgres password=postgres'); --lucas
 SELECT dblink_connect('conect_suc2', 'hostaddr=192.168.43.243 port=5432 dbname=PatSur-Suc-2 user=postgres password=postgres'); --lucas
 SELECT dblink_connect('conect_suc3', 'hostaddr=192.168.43.243 port=5432 dbname=PatSur-Suc-3 user=postgres password=postgres'); --lucas

INSERT INTO MEDIO_PAGO (Id_MedioPago,descripción)
	SELECT cod_medio_pago,descripción 
	FROM dblink('conect_suc1','SELECT cod_medio_pago, descripción FROM "SISTEMA-2".MEDIO_PAGO') AS medio(cod_medio_pago int, descripción varchar(30));

INSERT INTO CATEGORIA (Id_Categoria, Id_subcategoria, descripcion)
	SELECT DISTINCT cod_categoria, cod_subcategoria, descripcion FROM
	((SELECT cod_categoria, cod_subcategoria, descripcion 
	FROM dblink('conect_suc1','SELECT cod_categoria, cod_subcategoria, descripcion FROM "SISTEMA-2".CATEGORIA') AS categoria(cod_categoria text, cod_subcategoria text, descripcion varchar(30)))
	UNION ALL
	(SELECT cod_categoria, cod_subcategoria, descripcion 
	FROM dblink('conect_suc2','SELECT cod_categoria, cod_subcategoria, descripcion FROM "SISTEMA-2".CATEGORIA') AS categoria(cod_categoria text, cod_subcategoria text, descripcion varchar(30))) 
	UNION ALL
	(SELECT cod_categoria, cod_subcategoria, descripcion 
	FROM dblink('conect_suc3','SELECT cod_categoria, cod_subcategoria, descripcion FROM "SISTEMA-2".CATEGORIA') AS categoria(cod_categoria text, cod_subcategoria text, descripcion varchar(30)))
	) AS f;

INSERT INTO TIPO_CLIENTE (Id_Tipo, descripcion)
	SELECT cod_tipo, descripcion 
	FROM dblink('conect_suc1','SELECT cod_tipo, descripcion FROM "SISTEMA-2".TIPO_CLIENTE') AS tipo_cliente(cod_tipo int, descripcion varchar(30));


SELECT dblink_disconnect('conect_suc1');
SELECT dblink_disconnect('conect_suc2');
SELECT dblink_disconnect('conect_suc3');

-- TABLA PRODUCTOS
CREATE TABLE PRODUCTOS (
	Id_Producto int NOT NULL,
	Id_Categoria text NOT NULL,
	Id_subcategoria text NOT NULL,
	nombre varchar(30) NOT NULL,
	CONSTRAINT PK_PRODUCTOS PRIMARY KEY (Id_Producto)
);--DROP TABLE PRODUCTOS

ALTER TABLE PRODUCTOS
ADD CONSTRAINT FK_CATEGORIA FOREIGN KEY (Id_Categoria,Id_subcategoria)
REFERENCES CATEGORIA(Id_Categoria,Id_subcategoria);

-- TABLA CLIENTES
CREATE TABLE CLIENTES (
	Id_Cliente int NOT NULL,
	nombre text NOT NULL,
	Id_Tipo int NOT NULL,
	CONSTRAINT PK_CLIENTES PRIMARY KEY (Id_Cliente)
);
--DROP TABLE CLIENTES
ALTER TABLE CLIENTES
ADD CONSTRAINT FK_TIPO_CLIENTE FOREIGN KEY (Id_Tipo) REFERENCES TIPO_CLIENTE (Id_Tipo);

-- TABLA VENTAS
CREATE TABLE VENTAS (
	Id_Tiempo int,
	fecha timestamp,
	Id_Factura int,
	Id_Cliente int,
	Id_Producto int,
	Id_Sucursal int,
	Id_MedioPago int,
	monto_vendido real,
	cantidad_vendida int
);
--DROP TABLE VENTAS

-- TABLA DE EQUIVLENCIA DE CLIENTES
CREATE TABLE TECliente (
	cdw serial,
	cvs integer DEFAULT NULL,
	cns text DEFAULT NULL,
	CONSTRAINT pk_tecliente PRIMARY KEY (cdw)
);
--DROP TABLE TECliente;
-- TABLA DE EQUIVALENCIA DE PRODUCTOS
CREATE TABLE TEProductos (
	pdw serial,
	pvs integer DEFAULT NULL,
	pns text DEFAULT NULL,
	CONSTRAINT pk_teproductos PRIMARY KEY (pdw)
);
--DROP TABLE TEProductos

-- TABLA TEMPORAL TMPVENTAS
CREATE TABLE tmpVentas (
	Id_Tiempo int,
	fecha_vta timestamp,
	Id_Factura int,
	Id_Cliente text,			
	Id_Producto text,			
	Id_Sucursal int,
	Id_medio_pago int, 
	monto_vendido real,
	cantidad_vendida real,
	nombre_producto varchar(30),		
	Id_categoria text, 			
	Id_subcategoria text , 			
	nombre_cliente varchar(30),		
	tipo_cliente int 			
);
--DROP TABLE tmpVentas