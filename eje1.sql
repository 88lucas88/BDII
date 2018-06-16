CREATE EXTENSION dblink;
------------------------------------------------ Punto 1 -----------------------------------------------

------------------------------------------ Creación Sistema I ------------------------------------------

CREATE SCHEMA 

-- Clientes (nro_Cliente, Nombre, tipo, dirección)
CREATE TABLE CLIENTES(

nro_cliente int NOT NULL, 
nombre varchar(30) NULL,
tipo varchar(30) NULL, 
dirección varchar(30) NULL,
CONSTRAINT PK_NRO_CLIENTE PRIMARY KEY (nro_cliente)
);

-- Producto (nro_Producto, Nombre, nro_categ, precio_actual)
CREATE TABLE PRODUCTO(

nro_producto int NOT NULL, 
nombre varchar(30) NULL,
nro_categ int NOT NULL,
precio_actual real NULL, 
CONSTRAINT PK_NRO_PRODUCTO PRIMARY KEY (nro_producto)
);

-- Categoria (nro_categ, descripción)
CREATE TABLE CATEGORIA(

nro_categ int NOT NULL, 
descripcion varchar(30) NULL, 
CONSTRAINT PK_NRO_CATEGORIA PRIMARY KEY (nro_categ)
);

-- Venta (Fecha_Vta, nro_Factura, nro_Cliente, Nombre, forma_pago)
CREATE TABLE VENTA(

fecha_vta timestamp DEFAULT current_timestamp, 
nro_factura int NOT NULL,
nro_cliente int NOT NULL,
nombre varchar(30) NULL, 
forma_pago varchar(30) NULL,
CONSTRAINT PK_NRO_FACTURA PRIMARY KEY (nro_factura)
);

-- Detalle_Venta(nro_factura, nro_producto, descripción, unidad, precio)
CREATE TABLE DETALLE_VENTA(

nro_factura int NOT NULL,
nro_producto int NOT NULL,
descripción varchar(30) NULL, 
unidad real NULL,
precio real NULL
);

ALTER TABLE PRODUCTO
ADD CONSTRAINT FK_PRODUCTO_CATEGORIA_NRO_CATEG FOREIGN KEY(nro_categ)
REFERENCES CATEGORIA (nro_categ)
on delete restrict on update restrict;

ALTER TABLE VENTA
ADD CONSTRAINT FK_VENTA_CLIENTE_NRO_CLIENTE FOREIGN KEY(nro_cliente)
REFERENCES CLIENTES (nro_cliente)
on delete restrict on update restrict;

ALTER TABLE DETALLE_VENTA
ADD CONSTRAINT FK_DETALLE_VENTA_NRO_FACTURA FOREIGN KEY(nro_factura)
REFERENCES VENTA (nro_factura)
on delete restrict on update restrict;

ALTER TABLE DETALLE_VENTA
ADD CONSTRAINT FK_DETALLE_PRODUCTO_NRO_PRODUCTO FOREIGN KEY(nro_producto)
REFERENCES PRODUCTO (nro_producto)
on delete restrict on update restrict;


------------------------------------------ Creación Sistema II ------------------------------------------


CREATE SCHEMA "SISTEMA-2";


-- Clientes (cod_Cliente, Nombre, cod_tipo, dirección)
CREATE TABLE CLIENTES(
cod_cliente text NOT NULL, 
nombre varchar(30) NULL,
cod_tipo int NOT NULL,
dirección varchar(30) NULL,
CONSTRAINT PK_COD_CLIENTE PRIMARY KEY (cod_cliente)
);

-- Tipo_Cliente (cod_tipo, descripción)
CREATE TABLE TIPO_CLIENTE(
cod_tipo int NOT NULL, 
descripcion varchar(30) NULL,
CONSTRAINT PK_COD_TIPO PRIMARY KEY (cod_tipo)
);

-- Producto (cod_Producto, Nombre, cod_categoria, cod_subcategoria, precio_actual)
CREATE TABLE PRODUCTO(
cod_producto text NOT NULL, 
nombre varchar(30) NULL,
cod_categoria text NOT NULL,
cod_subcategoria int NOT NULL,
precio_actual float NULL, 
CONSTRAINT PK_COD_PRODUCTO PRIMARY KEY (cod_producto)
);
							
-- Categoria (cod_categoria,  cod_subcategoría, descripción)
CREATE TABLE CATEGORIA(
cod_categoria text NOT NULL, 
cod_subcategoria int NOT NULL,
descripcion varchar(30) NULL, 
CONSTRAINT PK_COD_CATEGORIA PRIMARY KEY (cod_categoria, cod_subcategoria)
);

-- Venta (Fecha_Vta, Id_Factura, cod_Cliente, Nombre, cod_medio_pago)
CREATE TABLE VENTA(
fecha_vta timestamp DEFAULT current_timestamp, 
id_factura int NOT NULL,
cod_cliente text NOT NULL, 
nombre varchar(30) NULL, 
cod_medio_pago int NOT NULL,
CONSTRAINT PK_ID_FACTURA PRIMARY KEY (id_factura)
);

-- Detalle_Venta(Id_factura, cod_producto, descripción, unidad, precio)
CREATE TABLE DETALLE_VENTA(
id_factura int NOT NULL,
cod_producto text NOT NULL,
descripción varchar(30) NULL, 
unidad int NULL,
precio int NULL
);

-- Medio_Pago( cod_Medio_Pago, descripción, valor, unidad, tipo_operación)
CREATE TABLE MEDIO_PAGO(
cod_medio_pago int NOT NULL, 
descripción varchar(30) NULL,
valor int NOT NULL,  
unidad int NULL,
tipo_operacion int NULL,
CONSTRAINT PK_COD_MEDIO_PAGO PRIMARY KEY (cod_medio_pago)
);

ALTER TABLE CLIENTES
ADD CONSTRAINT FK_CLIENTES_TIPO_COD_TIPO FOREIGN KEY(cod_tipo)
REFERENCES TIPO_CLIENTE (cod_tipo)
on delete restrict on update restrict;

ALTER TABLE PRODUCTO
ADD CONSTRAINT FK_PRODUCTO_SUBCATEGORIA_COD_CATEGORIA_SUBCATEGORIA FOREIGN KEY(cod_categoria, cod_subcategoria)
REFERENCES CATEGORIA (cod_categoria, cod_subcategoria)
on delete restrict on update restrict;

ALTER TABLE VENTA
ADD CONSTRAINT FK_VENTA_CLIENTE_NRO_CLIENTE FOREIGN KEY(cod_cliente)
REFERENCES CLIENTES (cod_cliente)
on delete restrict on update restrict;

ALTER TABLE VENTA
ADD CONSTRAINT FK_VENTA_MEDIO_COD_MEDIO_PAGO FOREIGN KEY(cod_medio_pago)
REFERENCES MEDIO_PAGO (cod_medio_pago)
on delete restrict on update restrict;

ALTER TABLE DETALLE_VENTA
ADD CONSTRAINT FK_DETALLE_VENTA_ID_FACTURA FOREIGN KEY(id_factura)
REFERENCES VENTA (id_factura)
on delete restrict on update restrict;

ALTER TABLE DETALLE_VENTA
ADD CONSTRAINT FK_DETALLE_PRODUCTO_COD_PRODUCTO FOREIGN KEY(cod_producto)
REFERENCES PRODUCTO (cod_producto)
on delete restrict on update restrict;


------------------------------------------------ Punto 2 ------------------------------------------------

----------------------------------------- Inserciones Sistema I -----------------------------------------

CREATE OR REPLACE FUNCTION "llenarSistemaI"() RETURNS VOID AS $$
DECLARE
	"cantidadClientes" integer := 1000;
	"baseCantidadClientes" integer;
	"limiteCantidadClientes" integer;
	"nombreC" varchar(30);
	"apellidoC" varchar(30);
	"tipoC" varchar(30);
	"calleC" varchar(30);
	"numMaxC" integer := 10000;
	"numMinC" integer := 1;
	"numeroC" integer;
	"cantidadProductos" integer := 1000;
	"baseCantidadProductos" integer;
	"limiteCantidadProductos" integer;
	"nroCategoriaP" integer;
	"cantidadVentas" integer := 1000;
	"baseCantidadVentas" integer;
	"limiteCantidadVentas" integer;
	"forma_pagoV" varchar(30);
	"diaMaxV" integer := 365;
	"diaMinV" integer := 1;
	"diasV" integer;
	"nroClienteV" int;
	"nombreClienteV" varchar(30);
	"nroProductoDV" integer;
	"nombreProductoDV" varchar(30);
	"cantidadDetalleVentas" integer;
	"cantMaxDV" integer := 15;
	"cantMinDV" integer := 1;
	"unidadDV" integer;
	"unidadMaxDV" integer := 100;
	"unidadMinDV" integer := 1;
	"precioDV" integer;
	"precioMaxDV" integer := 1500;
	"precioMinDV" integer := 500;
	"cantidadCategorias" INTEGER;
	categorias varchar(30)[];		

BEGIN		
	-- carga clientes
	SELECT MAX(nro_cliente) FROM clientes INTO "baseCantidadClientes";

	IF "baseCantidadClientes" IS NULL THEN
		"baseCantidadClientes" := 0;
	END IF;
	"baseCantidadClientes" := "baseCantidadClientes" + 1;
	"limiteCantidadClientes":= "baseCantidadClientes" + "cantidadClientes" - 1;
	FOR r IN "baseCantidadClientes" .. "limiteCantidadClientes" LOOP
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['Alicia','Marcela','Lidia','Estela','Nora','Norma','Ines','Noemi','Iris','Susana', 'Silvia', 'Carolina', 'Fatima']) AS n) AS d ORDER BY random() LIMIT 1 INTO "nombreC";
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['Gonzalez','Rodriguez','Gomez','Fernandez','Lopez','Diaz','Martinez','Perez','Romero','Sanchez', 'Garcia', 'Sosa', 'Torres']) AS n) AS d ORDER BY random() LIMIT 1 INTO "apellidoC";
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['publico objetivo','cliente potencial','cliente eventual','interno','externo']) AS n) AS d ORDER BY random() LIMIT 1 INTO "tipoC";
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['San Martin','Av. Colon','9 de Julio','Cacique Venancio','Castelar', 'Saavedra', 'Alsina', 'Vieytes', 'Brown', 'Sarmiento', 'Chiclana', 'Dorrego','Guemes', 'Berutti','Caronti', 'Casanova', 'Patricios', 'Donado', 'Fitz Roy', 'Av. Alem']) AS n) AS d ORDER BY random() LIMIT 1 INTO "calleC";
		"numeroC" := trunc(random() * "numMaxC" + "numMinC");
		INSERT INTO clientes(nro_cliente, nombre, tipo, "dirección") VALUES (r, "apellidoC" || ', ' || "nombreC", "tipoC", "calleC" || ' ' || "numeroC");
	
	END LOOP;
	-- carga categorias
	categorias := ARRAY['almacen','panaderia','lacteos','carne vacuna','menudencias', 'carne porcina', 'granja', 'pescado', 'frutas', 'hortalizas', 'frutas secas']; 
	SELECT count(nro_categ) FROM categoria INTO "cantidadCategorias";

	IF "cantidadCategorias" <> 11 THEN
		FOR r IN 1 .. 11 LOOP
			INSERT INTO categoria(nro_categ, descripcion) VALUES (r, categorias[r]);
		
		END LOOP;		
	END IF;
	-- carga productos
	SELECT MAX(nro_producto) FROM producto INTO "baseCantidadProductos";

	IF "baseCantidadProductos" IS NULL THEN
		"baseCantidadProductos" := 0;
	END IF;
	"baseCantidadProductos" := "baseCantidadProductos" + 1;
	"limiteCantidadProductos" := "baseCantidadProductos" + "cantidadProductos" - 1;
	FOR r IN "baseCantidadProductos" .. "limiteCantidadProductos" LOOP
		"precioDV" := trunc(random() * "precioMaxDV" + "precioMinDV");
		SELECT nro_categ FROM categoria ORDER BY random() LIMIT 1 INTO "nroCategoriaP";
	
		INSERT INTO producto(nro_producto, nombre, nro_categ, precio_actual) VALUES (r, 'Producto ' || r, "nroCategoriaP", "precioDV");
	
	END LOOP;
	-- carga ventas
	SELECT MAX(nro_factura) FROM venta INTO "baseCantidadVentas";

	IF "baseCantidadVentas" IS NULL THEN
		"baseCantidadVentas" := 0;
	END IF;
	"baseCantidadVentas" := "baseCantidadVentas" + 1;
	"limiteCantidadVentas" := "baseCantidadVentas" + "cantidadVentas" - 1;
	FOR r IN "baseCantidadVentas" .. "limiteCantidadVentas" LOOP
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['contado','tarjeta debito','tarjeta credito','transferencia bancaria']) AS n) AS d ORDER BY random() LIMIT 1 INTO "forma_pagoV";
		"diasV" := trunc(random() * "diaMaxV" + "diaMinV");
		SELECT nro_cliente FROM clientes ORDER BY random() LIMIT 1 INTO "nroClienteV";
	
		SELECT nombre FROM clientes WHERE nro_cliente = "nroClienteV" INTO "nombreClienteV";
	
		INSERT INTO venta(fecha_vta, nro_factura, nro_cliente, nombre, forma_pago) VALUES (current_date + CAST("diasV"||' days' AS INTERVAL), r, "nroClienteV", "nombreClienteV", "forma_pagoV");
	
		-- carga detalles venta
		"cantidadDetalleVentas" := trunc(random() * "cantMaxDV" + "cantMinDV");
		FOR t IN 1 .. "cantidadDetalleVentas" LOOP
			SELECT nro_producto FROM producto ORDER BY random() LIMIT 1 INTO "nroProductoDV";
		
			SELECT nombre FROM producto  WHERE nro_producto = "nroProductoDV" INTO "nombreProductoDV";
		
			"unidadDV" := trunc(random() * "unidadMaxDV" + "unidadMinDV");
			SELECT precio_actual FROM producto  WHERE nro_producto = "nroProductoDV" INTO "precioDV";
		
			INSERT INTO detalle_venta(nro_factura, nro_producto, "descripción", unidad, precio) VALUES (r, "nroProductoDV",'Descripcion ' || "nombreProductoDV", "unidadDV", "precioDV");
		
		END LOOP;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT "llenarSistemaI"();


------------------------------------------- funcion hex_to_int -------------------------------------------


CREATE OR REPLACE FUNCTION hex_to_int(hexval varchar) RETURNS integer AS $$
DECLARE
	result  int;
BEGIN
	EXECUTE 'SELECT x''' || hexval || '''::int' INTO result;
	RETURN result;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT; 


----------------------------------------- Inserciones Sistema II -----------------------------------------


CREATE OR REPLACE FUNCTION "llenarSistemaII"() RETURNS VOID AS $$
DECLARE
	"cantidadClientes" integer := 1000;
	"baseCantidadClientes" integer;
	"limiteCantidadClientes" integer;
	"nombreC" varchar(30);
	"apellidoC" varchar(30);
	"tipoClienteTC" varchar(30);
	"calleC" varchar(30);
	"numMaxC" integer := 10000;
	"numMinC" integer := 1;
	"numeroC" integer;
	"descripcionCat" varchar(30);
	"cantidadProductos" integer := 1000;
	"baseCantidadProductos" integer;
	"limiteCantidadProductos" integer;
	"nroCategoriaP" text;
	"cantidadVentas" integer := 1000;
	"baseCantidadVentas" integer;
	"limiteCantidadVentas" integer;
	"forma_pagoMP" varchar(30);
	"diaMaxV" integer := 15;
	"diaMinV" integer := 1;
	"diasV" integer;
	"nroClienteV" text;
	"nombreClienteV" varchar(30);
	"nroProductoDV" text;
	"nombreProductoDV" varchar(30);
	"cantidadDetalleVentas" integer;
	"cantMaxDV" integer := 15;
	"cantMinDV" integer := 1;
	"unidadDV" integer;
	"unidadMaxDV" integer := 100;
	"unidadMinDV" integer := 1;
	"precioDV" integer;
	"precioMaxDV" integer := 1500;
	"precioMinDV" integer := 100;
	"cantidadCategorias" integer;
	"codMedioPagoV" integer;
	"codTipoC" integer;
	"cantidadTipoClientes" integer;
	"cantidadMediosPago" integer;
	"cantSubcategoria" integer;
	"subCategoriaMax" integer := 15;
	"subCategoriaMin"integer := 1;
	"nroSubCategoriaP" integer;
	tipoclientes varchar(30)[];
	categorias varchar(30)[];
	mediospago varchar(30)[];
		
BEGIN
	-- carga tipo clientes
	tipoclientes := ARRAY['publico objetivo','cliente potencial','cliente eventual','interno','externo'];
	SELECT count(cod_tipo) FROM tipo_cliente INTO "cantidadTipoClientes";
	IF "cantidadTipoClientes" <> 5 THEN
		FOR r IN 1 .. 5 LOOP
			INSERT INTO tipo_cliente(cod_tipo, descripcion)VALUES (r, tipoclientes[r]);
		END LOOP;
	END IF;
	-- carga clientes	
	SELECT MAX(hex_to_int(cod_cliente)) FROM clientes INTO "baseCantidadClientes";
	IF "baseCantidadClientes" IS NULL THEN
		"baseCantidadClientes" := 0;
	END IF;
	"baseCantidadClientes" := "baseCantidadClientes" + 1;
	"limiteCantidadClientes":= "baseCantidadClientes" + "cantidadClientes" - 1;
	FOR r IN "baseCantidadClientes" .. "limiteCantidadClientes" LOOP
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['Alicia','Marcela','Lidia','Estela','Nora','Norma','Ines','Noemi','Iris','Susana', 'Silvia', 'Carolina', 'Fatima']) AS n) AS d ORDER BY random() LIMIT 1 INTO "nombreC";	
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['Gonzalez','Rodriguez','Gomez','Fernandez','Lopez','Diaz','Martinez','Perez','Romero','Sanchez', 'Garcia', 'Sosa', 'Torres']) AS n) AS d ORDER BY random() LIMIT 1 INTO "apellidoC";
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['San Martin','Av. Colon','9 de Julio','Cacique Venancio','Castelar', 'Saavedra', 'Alsina', 'Vieytes', 'Brown', 'Sarmiento', 'Chiclana', 'Dorrego','Guemes', 'Berutti','Caronti', 'Casanova', 'Patricios', 'Donado', 'Fitz Roy', 'Av. Alem']) AS n) AS d ORDER BY random() LIMIT 1 INTO "calleC";
		SELECT cod_tipo FROM tipo_cliente ORDER BY random() LIMIT 1 INTO "codTipoC";
		"numeroC" := trunc(random() * "numMaxC" + "numMinC");
		INSERT INTO clientes(cod_cliente, nombre, cod_tipo, "dirección") VALUES (to_hex(r + hex_to_int('aaa')), "apellidoC" || ', ' || "nombreC", "codTipoC", "calleC" || ' ' || "numeroC");
	END LOOP;
	-- carga categorias
	categorias := ARRAY['almacen','panaderia','lacteos','carne vacuna','menudencias', 'carne porcina', 'granja', 'pescado', 'frutas', 'hortalizas', 'frutas secas']; 
	SELECT count(cod_categoria) FROM categoria INTO "cantidadCategorias";
	IF "cantidadCategorias" < 11 THEN
		FOR r IN 1 .. 11 LOOP
			"cantSubcategoria" := trunc(random() * "subCategoriaMax" + "subCategoriaMin");
			FOR t IN 1 .. "cantSubcategoria" LOOP
				INSERT INTO categoria(cod_categoria, cod_subcategoria, descripcion) VALUES (to_hex(r + hex_to_int('aaa')), t ,categorias[r] || ' ' || to_hex(r + hex_to_int('aaa')) || '-' || t);
			END LOOP;
		END LOOP;
	END IF;
	-- carga productos
	SELECT MAX(hex_to_int(cod_producto)) FROM producto INTO "baseCantidadProductos";
	IF "baseCantidadProductos" IS NULL THEN
		"baseCantidadProductos" := 0;
	END IF;
	"baseCantidadProductos" := "baseCantidadProductos" + 1;
	"limiteCantidadProductos" := "baseCantidadProductos" + "cantidadProductos" - 1;
	FOR r IN "baseCantidadProductos" .. "limiteCantidadProductos" LOOP
		"precioDV" := trunc(random() * "precioMaxDV" + "precioMinDV");
		SELECT cod_categoria FROM categoria ORDER BY random() LIMIT 1 INTO "nroCategoriaP";
		SELECT cod_subcategoria FROM categoria WHERE cod_categoria = "nroCategoriaP" ORDER BY random() LIMIT 1 INTO "nroSubCategoriaP";
		INSERT INTO producto(cod_producto, nombre, cod_categoria, cod_subcategoria, precio_actual) VALUES (to_hex(r + hex_to_int('aaa')), 'Producto ' || r, "nroCategoriaP", "nroSubCategoriaP", "precioDV");
	END LOOP;
	-- carga medios de pago
	mediospago := ARRAY['contado','tarjeta debito','tarjeta credito','transferencia bancaria'];
	SELECT count(cod_medio_pago) FROM medio_pago INTO "cantidadMediosPago";
	IF "cantidadMediosPago" <> 4 THEN
		FOR r IN 1.. 4 LOOP
-- que va en valor unidad tipoOperacion ??
			INSERT INTO medio_pago(cod_medio_pago, "descripción", valor, unidad, tipo_operacion) VALUES (r, mediospago[r], 1, 1, r);
		END LOOP;
	END IF;
	-- carga ventas
	SELECT MAX(id_factura) FROM venta INTO "baseCantidadVentas";
	IF "baseCantidadVentas" IS NULL THEN
		"baseCantidadVentas" := 0;
	END IF;
	"baseCantidadVentas" := "baseCantidadVentas" + 1;
	"limiteCantidadVentas" := "baseCantidadVentas" + "cantidadVentas" - 1;
	FOR r IN "baseCantidadVentas" .. "limiteCantidadVentas" LOOP
		SELECT cod_medio_pago FROM medio_pago ORDER BY random() LIMIT 1 INTO "codMedioPagoV";
		"diasV" := trunc(random() * "diaMaxV" + "diaMinV");
		SELECT cod_cliente FROM clientes ORDER BY random() LIMIT 1 INTO "nroClienteV";
		SELECT nombre FROM clientes WHERE cod_cliente = "nroClienteV" INTO "nombreClienteV";
		INSERT INTO venta(fecha_vta, id_factura, cod_cliente, nombre, cod_medio_pago) VALUES (current_date + CAST("diasV"||' days' AS INTERVAL), r, "nroClienteV", "nombreClienteV", "codMedioPagoV");
		-- carga detalles venta
		"cantidadDetalleVentas" := trunc(random() * "cantMaxDV" + "cantMinDV");
		FOR t IN 1 .. "cantidadDetalleVentas" LOOP
			SELECT cod_producto FROM producto ORDER BY random() LIMIT 1 INTO "nroProductoDV";
			SELECT nombre FROM producto WHERE cod_producto = "nroProductoDV" INTO "nombreProductoDV";
			"unidadDV" := trunc(random() * "unidadMaxDV" + "unidadMinDV");
			SELECT precio_actual FROM producto  WHERE cod_producto = "nroProductoDV" INTO "precioDV";
			INSERT INTO detalle_venta(id_factura, cod_producto, "descripción", unidad, precio) VALUES (r, "nroProductoDV", 'Descripcion ' || "nombreProductoDV", "unidadDV", "precioDV");
		END LOOP;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT "llenarSistemaII"();
