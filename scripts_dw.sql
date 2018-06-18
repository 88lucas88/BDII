CREATE EXTENSION dblink;

CREATE TABLE TECliente (
	cdw serial,
	cvs integer DEFAULT NULL,
	cns text DEFAULT NULL,
	CONSTRAINT pk_tecliente PRIMARY KEY (cdw)
);

CREATE TABLE TEProductos (
	pdw serial,
	pvs integer DEFAULT NULL,
	pns text DEFAULT NULL,
	CONSTRAINT pk_teproductos PRIMARY KEY (pdw)
);

SELECT dblink_connect('conect_suc1', 'port=5434 dbname=PatSur-Suc1 user=postgres password=david'); -- le deje solo el puerto y la contraseña del servidor
SELECT dblink_disconnect('conect_suc1');

INSERT INTO TECliente (cns)
	SELECT cod_cliente FROM dblink('conect_suc1','SELECT cod_cliente FROM "SISTEMA-2".CLIENTES') AS cliente(cod_cliente text);

INSERT INTO TECliente (cvs)
	SELECT nro_cliente FROM dblink('conect_suc1','SELECT nro_cliente FROM "SISTEMA-1".CLIENTES') AS cliente(nro_cliente integer);

--Aplicación de UPDATE y DELETE manuales a la tabla TEClientes casos que corresponden al mismo cliente
UPDATE TECliente SET cvs = 23 WHERE cns = 1; --EJEMPLO
DELETE FROM TEClientes WHERE cvs = 55;

--Insercion de productos de ambos sistemas en Tabla de equivalencia de productos
INSERT INTO TEProductos (pns)
	SELECT cod_producto FROM dblink('conect_suc1','SELECT cod_producto FROM "SISTEMA-2".PRODUCTO') AS productos(cod_producto text);

INSERT INTO TEProductos (pvs)
	SELECT nro_producto FROM dblink('conect_suc1','SELECT nro_producto FROM "SISTEMA-1".PRODUCTO') AS productos(nro_producto integer);


--Aplicación de UPDATE y DELETE manuales a la tabla TEProductos casos que corresponden al mismo producto
UPDATE TEProductos SET pvs = 23 WHERE pns = 1; --EJEMPLO
DELETE FROM TEProductos WHERE pvs = 55;

----------------------------------------------------------------
CREATE TABLE MEDIO_PAGO(
	Id_MedioPago int NOT NULL, 
	descripción varchar(30) NULL,
	CONSTRAINT PK_COD_MEDIO_PAGO PRIMARY KEY (Id_MedioPago)
);

INSERT INTO MEDIO_PAGO (Id_MedioPago,descripción)
	SELECT cod_medio_pago,descripción FROM dblink('conect_suc1','SELECT cod_medio_pago, descripción FROM "SISTEMA-2".MEDIO_PAGO') AS medio(cod_medio_pago int, descripción varchar(30));

-- Categoria (cod_categoria,  cod_subcategoría, descripción)
CREATE TABLE CATEGORIA(
	Id_Categoria text NOT NULL, 
	Id_subcategoria int NOT NULL,
	descripcion varchar(30) NULL, 
	CONSTRAINT PK_ID_CATEGORIA PRIMARY KEY (Id_Categoria, Id_subcategoria)
);

INSERT INTO CATEGORIA (Id_Categoria, Id_subcategoria, descripcion)
	SELECT cod_categoria, cod_subcategoria, descripcion FROM dblink('conect_suc1','SELECT cod_categoria, cod_subcategoria, descripcion FROM "SISTEMA-2".CATEGORIA') AS categoria(cod_categoria text, cod_subcategoria int, descripcion varchar(30));

-- Tipo_Cliente (Id_Tipo, descripción)
CREATE TABLE TIPO_CLIENTE(
	Id_Tipo int NOT NULL, 
	descripcion varchar(30) NULL,
	CONSTRAINT PK_ID_TIPO PRIMARY KEY (Id_Tipo)
);

INSERT INTO TIPO_CLIENTE (Id_Tipo, descripcion)
	SELECT cod_tipo, descripcion FROM dblink('conect_suc1','SELECT cod_tipo, descripcion FROM "SISTEMA-2".TIPO_CLIENTE') AS tipo_cliente(cod_tipo int, descripcion varchar(30));

--TABLA SUCURSAL
CREATE TABLE SUCURSAL (
	Id_Sucursal int NOT NULL,
	descripcion varchar(30) NULL,
	Id_Ciudad int NOT NULL,
	CONSTRAINT PK_SUCURSAL PRIMARY KEY (Id_Sucursal)
);

CREATE TABLE CIUDAD (
	Id_Ciudad int NOT NULL,
	descripcion varchar(30) NULL,
	Id_Provincia int NOT NULL,
	CONSTRAINT PK_CIUDAD PRIMARY KEY (Id_Ciudad)	
);

ALTER TABLE SUCURSAL
ADD CONSTRAINT FK_CIUDAD FOREIGN KEY(Id_Ciudad)
REFERENCES CIUDAD (Id_Ciudad)
on delete restrict on update restrict;

CREATE TABLE PROVINCIA (
	Id_Provincia int NOT NULL,
	descripcion varchar(30) NULL,
	Id_Region int NOT NULL,
	CONSTRAINT PK_PROVINCIA PRIMARY KEY (Id_Provincia)	
);

ALTER TABLE CIUDAD
ADD CONSTRAINT FK_PROVINCIA FOREIGN KEY(Id_Provincia)
REFERENCES PROVINCIA (Id_Provincia)
on delete restrict on update restrict;

CREATE TABLE REGION (
	Id_Region int NOT NULL,
	descripcion varchar(30) NULL,
	CONSTRAINT PK_REGION PRIMARY KEY (Id_Region)	
);

ALTER TABLE PROVINCIA
ADD CONSTRAINT FK_REGION FOREIGN KEY(Id_Region)
REFERENCES REGION (Id_Region)
on delete restrict on update restrict;

/*************************HACER INSERTS
Region (1 o 2 tuplas), Provincia (1 provincia), Ciudad (3 tuplas), Sucursal (3 tuplas)*/

CREATE TABLE TIEMPO (
	Id_Tiempo serial,
	mes int NOT NULL,
	año int NOT NULL,
	trimetres int NOT NULL,
	CONSTRAINT PK_TIEMPO PRIMARY KEY (Id_Tiempo)
);

DROP TABLE TIEMPO;

CREATE TABLE PRODUCTOS (
	Id_Producto int NOT NULL,
	Id_Categoria text NOT NULL,
	Id_subcategoria int NOT NULL,
	nombre varchar(30) NOT NULL,
	CONSTRAINT PK_PRODUCTOS PRIMARY KEY (Id_Producto)
);

ALTER TABLE PRODUCTOS
ADD CONSTRAINT FK_CATEGORIA FOREIGN KEY (Id_Categoria,Id_subcategoria)
REFERENCES CATEGORIA(Id_Categoria,Id_subcategoria);

CREATE TABLE CLIENTES (
	Id_Cliente int NOT NULL,
	nombre varchar(30) NOT NULL,
	Id_Tipo int NOT NULL,
	CONSTRAINT PK_CLIENTES PRIMARY KEY (Id_Cliente)
);

ALTER TABLE CLIENTES
ADD CONSTRAINT FK_TIPO_CLIENTE FOREIGN KEY (Id_Tipo) REFERENCES TIPO_CLIENTE (Id_Tipo);

CREATE TABLE VENTAS (
	Id_Tiempo int,
	fecha timestamp,
	Id_Factura int,
	Id_Cliente int,
	Id_Producto int,
	Id_Sucursal int,
	Id_MedioPago int,
	monto_vendido real,
	cantidad_vendida int,
	CONSTRAINT PK_FACTURA PRIMARY KEY (Id_Factura)
);

CREATE OR REPLACE FUNCTION CargaTiempo() RETURNS VOID AS
$$
DECLARE
	año_min integer := 2011; año_max integer := 2018;
	i integer; j integer;
	Id_Tiempo_Max integer;

BEGIN
	FOR i IN año_min..año_max LOOP
		FOR j IN 1..12 LOOP
			CASE 
				WHEN (j>=1 AND j<=3) THEN
					INSERT INTO TIEMPO (mes,año,trimetres) VALUES (j,i,1);
				WHEN (j>=4 AND j<=6) THEN
					INSERT INTO TIEMPO (mes,año,trimetres) VALUES (j,i,2);
				WHEN (j>=7 AND j<=9) THEN
					INSERT INTO TIEMPO (mes,año,trimetres) VALUES (j,i,3);
				ELSE
					INSERT INTO TIEMPO (mes,año,trimetres) VALUES (j,i,4);
			END CASE;
		END LOOP;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT CargaTiempo();

--Creacion de tabla temporal de ventas

--CREATE TABLE tmpVentas (
--	fecha_vta timestamp,
--	Id_Factura int,
--	Id_Cliente int,
--	Id_Producto int,
--	Id_Sucursal int,
--	forma_pago varchar(30),
--	monto_vendido real,
--	cantidad_vendida real,
--	nombre_producto varchar(30),
--	categ_prod int,
--	subcat_prod int DEFAULT NULL,
--	precio real,
--	nombre_cliente varchar(30),
--	tipo_cliente varchar(30)
--)

CREATE TABLE tmpVentas (
	fecha_vta timestamp,
	Id_Factura int,
	Id_Cliente text,--modificado
	Id_Producto text,--modificado
	Id_Sucursal int,
	forma_pago text, --modificado
	monto_vendido real,
	cantidad_vendida real,
	nombre_producto varchar(30),
	categ_prod text, --modificado
	subcat_prod int , --modidificado
	precio real, 
	nombre_cliente varchar(30),
	tipo_cliente int --modificado
);

DROP TABLE tmpVentas;

--Script ETL - extraccion de datos de ventas desde el sistema de facturacion viejo

CREATE OR REPLACE FUNCTION CargaTmpVentas(pSuc integer, pMes integer, pAño integer) RETURNS VOID AS
$$
DECLARE
	-- falta el idtiempo
BEGIN
	INSERT INTO tmpVentas(fecha_vta, Id_Factura, Id_Cliente, Id_Producto, Id_Sucursal, forma_pago, monto_vendido, cantidad_vendida, nombre_producto,
	categ_prod, precio, nombre_cliente, tipo_cliente)	
	SELECT fecha_vta, Id_Factura, Id_Cliente, Id_Producto, Id_Sucursal, forma_pago, monto_vendido, cantidad_vendida, nombre_producto,
	categ_prod, precio, nombre_cliente, tipo_cliente
	FROM (SELECT fecha_vta, Id_Factura, Id_Cliente, Id_Producto, Id_Sucursal, forma_pago, monto_vendido, cantidad_vendida, nombre_producto, 
	categ_prod, precio, nombre_cliente, TC.id_tipo AS tipo_cliente
	FROM (SELECT * FROM dblink ('conect_suc1', 'SELECT fecha_vta, v.nro_factura, CAST(c.nro_cliente AS text), CAST(p.nro_producto AS text), ' || CAST(pSuc AS text) || 'as Id_Sucursal, 
	forma_pago, unidad * precio as monto_vendido, unidad as cantidad_vendida, p.nombre, CAST(p.nro_categ AS text), precio, c.nombre, c.tipo
	FROM "SISTEMA-1".venta v, "SISTEMA-1".detalle_venta dv, "SISTEMA-1".clientes c, "SISTEMA-1".producto p
	WHERE v.nro_Factura = dv.nro_Factura and v.nro_cliente = c.nro_cliente and dv.nro_producto = p.nro_producto and date_part (''month'', fecha_vta) =  ' || CAST(pMes AS text) || '
	and date_part (''year'', fecha_vta) = ' || CAST(pAño AS text))
	AS tmpvent (fecha_vta timestamp, Id_Factura int, Id_Cliente text, Id_Producto text, Id_Sucursal int, forma_pago varchar(30), monto_vendido real, cantidad_vendida real, nombre_producto varchar(30), 
	categ_prod text, precio real, nombre_cliente varchar(30), tipo_cliente varchar(30))) 
	AS I JOIN tipo_cliente AS TC ON I.tipo_cliente = TC.descripcion) AS TCI;
	
	-- falta la parte que cambia la descripcion de forma_pago al id_mediopago 
	
END;
$$ LANGUAGE plpgsql;

SELECT CargaTmpVentas (1,9,2018);

--Script ETL - extraccion de datos de ventas desde el sistema de facturacion nuevo

CREATE OR REPLACE FUNCTION CargaTmpVentasSN(pSuc integer, pMes integer, pAño integer) RETURNS VOID AS
$$
DECLARE
-- falta el idtiempo
BEGIN
	INSERT INTO public.tmpventas(fecha_vta, id_factura, id_cliente, id_producto, id_sucursal, forma_pago, monto_vendido, cantidad_vendida, 
		nombre_producto, categ_prod, subcat_prod, precio, nombre_cliente, tipo_cliente)
	SELECT * FROM dblink ('conect_suc1', 'SELECT fecha_vta, v.id_factura, c.cod_cliente, p.cod_producto, ' || CAST(pSuc AS text) || 'as Id_Sucursal, 
		CAST(v.cod_medio_pago as Text), unidad * precio as monto_vendido, unidad as cantidad_vendida,p.nombre, p.cod_categoria, p.cod_subcategoria, precio, c.nombre, c.cod_tipo 
		FROM "SISTEMA-2".venta v, "SISTEMA-2".detalle_venta dv, "SISTEMA-2".clientes c, "SISTEMA-2".producto p
		WHERE v.id_factura = dv.id_factura and v.cod_cliente = c.cod_cliente and dv.cod_producto = p.cod_producto and  
		date_part (''month'', fecha_vta) =  ' || CAST(pMes AS text) || 'and date_part (''year'', fecha_vta) = ' || CAST(pAño AS text))
		AS tmpvent (fecha_vta timestamp, Id_Factura int, Id_Cliente text, Id_Producto text, Id_Sucursal int, forma_pago text, monto_vendido real, 
		cantidad_vendida real, nombre_producto varchar(30), categ_prod text, subcat_prod int, precio real, nombre_cliente varchar(30), tipo_cliente int);
END;
$$ LANGUAGE plpgsql;


SELECT CargaTmpVentasSN (2,9,2018);


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------


UPDATE tmpventas
    SET forma_pago = 
	    CASE forma_pago
		WHEN 'contado' THEN CAST(1 AS text)
		WHEN 'debito' THEN CAST(2 AS text)
		WHEN 'credito' THEN CAST(3 AS text)
		WHEN 'transferencia' THEN CAST(4 AS text)
		WHEN '1' THEN CAST(1 AS text)
		WHEN '2' THEN CAST(2 AS text)
		WHEN '3' THEN CAST(3 AS text)
		WHEN '4' THEN CAST(4 AS text)
	    END
-- WHERE forma_pago IN ('contado', 'contado', 'targeta credito', 'transferencia bancaria');


UPDATE tmpventas 
SET forma_pago = 
	CASE forma_pago
		WHEN '1' THEN CAST(111 AS text)
		WHEN '2' THEN CAST(222 AS text)
		WHEN '3' THEN CAST(333 AS text)
		WHEN '4' THEN CAST(444 AS text)
	END





CREATE TABLE "SISTEMA-1".TECliente (
	cdw serial,
	cvs integer DEFAULT NULL,
	cns text DEFAULT NULL,
	CONSTRAINT pk_tecliente PRIMARY KEY (cdw)
);

INSERT INTO "SISTEMA-1".TECliente (cvs)
	SELECT nro_cliente
	FROM (SELECT nro_cliente FROM "SISTEMA-1".Clientes) AS cv

INSERT INTO "SISTEMA-1".TECliente (cns)
	SELECT cod_cliente
	FROM (SELECT cod_cliente FROM "SISTEMA-2".Clientes) AS cn	