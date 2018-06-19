------------------------------------------------ Punto 1 -----------------------------------------------

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

-- Medio_Pago( cod_Medio_Pago, descripción, valor, unidad, tipo_operación)
CREATE TABLE "SISTEMA-2".MEDIO_PAGO(
cod_medio_pago int NOT NULL, 
descripción varchar(30) NULL,
valor int NOT NULL,  
unidad int NULL,
tipo_operacion int NULL,
CONSTRAINT PK_COD_MEDIO_PAGO PRIMARY KEY (cod_medio_pago)
);

ALTER TABLE "SISTEMA-2".CLIENTES
ADD CONSTRAINT FK_CLIENTES_TIPO_COD_TIPO FOREIGN KEY(cod_tipo)
REFERENCES "SISTEMA-2".TIPO_CLIENTE (cod_tipo)
on delete restrict on update restrict;

ALTER TABLE "SISTEMA-2".PRODUCTO
ADD CONSTRAINT FK_PRODUCTO_SUBCATEGORIA_COD_CATEGORIA_SUBCATEGORIA FOREIGN KEY(cod_categoria, cod_subcategoria)
REFERENCES "SISTEMA-2".CATEGORIA (cod_categoria, cod_subcategoria)
on delete restrict on update restrict;

ALTER TABLE "SISTEMA-2".VENTA
ADD CONSTRAINT FK_VENTA_CLIENTE_NRO_CLIENTE FOREIGN KEY(cod_cliente)
REFERENCES "SISTEMA-2".CLIENTES (cod_cliente)
on delete restrict on update restrict;

ALTER TABLE "SISTEMA-2".VENTA
ADD CONSTRAINT FK_VENTA_MEDIO_COD_MEDIO_PAGO FOREIGN KEY(cod_medio_pago)
REFERENCES "SISTEMA-2".MEDIO_PAGO (cod_medio_pago)
on delete restrict on update restrict;

ALTER TABLE "SISTEMA-2".DETALLE_VENTA
ADD CONSTRAINT FK_DETALLE_VENTA_ID_FACTURA FOREIGN KEY(id_factura)
REFERENCES "SISTEMA-2".VENTA (id_factura)
on delete restrict on update restrict;

ALTER TABLE "SISTEMA-2".DETALLE_VENTA
ADD CONSTRAINT FK_DETALLE_PRODUCTO_COD_PRODUCTO FOREIGN KEY(cod_producto)
REFERENCES "SISTEMA-2".PRODUCTO (cod_producto)
on delete restrict on update restrict;


------------------------------------------------ Punto 2 ------------------------------------------------

----------------------------------------- Inserciones Sistema-1 -----------------------------------------

CREATE OR REPLACE FUNCTION "SISTEMA-1"."llenarSistema-1"(cantidad int) RETURNS VOID AS $$
DECLARE
	"baseCantidadClientes" integer;
	"limiteCantidadClientes" integer;
	"nombreC" varchar(30);
	"apellidoC" varchar(30);
	"tipoC" varchar(30);
	"calleC" varchar(30);
	"numMaxC" integer := 10000;
	"numeroC" integer;
	"baseCantidadProductos" integer;
	"limiteCantidadProductos" integer;
	"nroCategoriaP" integer;
	"baseCantidadVentas" integer;
	"limiteCantidadVentas" integer;
	"forma_pagoV" varchar(30);
	"diaMaxV" integer := 365;
	"diasV" integer;
	"nroClienteV" int;
	"nombreClienteV" varchar(30);
	"nroProductoDV" integer;
	"nombreProductoDV" varchar(30);
	"cantidadDetalleVentas" integer;
	"cantMaxDV" integer := 15;
	"unidadDV" integer;
	"unidadMaxDV" integer := 100;
	"precioDV" integer;
	"precioMaxDV" integer := 1500;
	"precioMinDV" integer := 500;
	"cantidadCategorias" integer;
	minimo integer := 1;
	categorias varchar(30)[];		

BEGIN		
	-- carga clientes
	SELECT MAX(nro_cliente) FROM "SISTEMA-1".clientes INTO "baseCantidadClientes";
	IF "baseCantidadClientes" IS NULL THEN
		"baseCantidadClientes" := 0;
	END IF;
	"baseCantidadClientes" := "baseCantidadClientes" + minimo;
	"limiteCantidadClientes":= "baseCantidadClientes" + cantidad - minimo;
	FOR r IN "baseCantidadClientes" .. "limiteCantidadClientes" LOOP
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['Alicia','Marcela','Lidia','Estela','Nora','Norma','Ines','Noemi','Iris','Susana', 'Silvia', 'Carolina', 'Fatima']) AS n) AS d ORDER BY random() LIMIT 1 INTO "nombreC";
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['Gonzalez','Rodriguez','Gomez','Fernandez','Lopez','Diaz','Martinez','Perez','Romero','Sanchez', 'Garcia', 'Sosa', 'Torres']) AS n) AS d ORDER BY random() LIMIT 1 INTO "apellidoC";
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['publico objetivo','cliente potencial','cliente eventual','interno','externo']) AS n) AS d ORDER BY random() LIMIT 1 INTO "tipoC";
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['San Martin','Av. Colon','9 de Julio','Cacique Venancio','Castelar', 'Saavedra', 'Alsina', 'Vieytes', 'Brown', 'Sarmiento', 'Chiclana', 'Dorrego','Guemes', 'Berutti','Caronti', 'Casanova', 'Patricios', 'Donado', 'Fitz Roy', 'Av. Alem']) AS n) AS d ORDER BY random() LIMIT 1 INTO "calleC";
		"numeroC" := trunc(random() * "numMaxC" + minimo);
		INSERT INTO "SISTEMA-1".clientes(nro_cliente, nombre, tipo, "dirección") VALUES (r, "apellidoC" || ', ' || "nombreC", "tipoC", "calleC" || ' ' || "numeroC");
	END LOOP;
	-- carga categorias
	categorias := ARRAY['almacen','panaderia','lacteos','carne vacuna','menudencias', 'carne porcina', 'granja', 'pescado', 'frutas', 'hortalizas', 'frutas secas']; 
	SELECT count(nro_categ) FROM "SISTEMA-1".categoria INTO "cantidadCategorias";
	IF "cantidadCategorias" <> 11 THEN
		FOR r IN minimo .. 11 LOOP
			INSERT INTO "SISTEMA-1".categoria(nro_categ, descripcion) VALUES (r, categorias[r]);
		END LOOP;		
	END IF;
	-- carga productos
	SELECT MAX(nro_producto) FROM "SISTEMA-1".producto INTO "baseCantidadProductos";
	IF "baseCantidadProductos" IS NULL THEN
		"baseCantidadProductos" := 0;
	END IF;
	"baseCantidadProductos" := "baseCantidadProductos" + minimo;
	"limiteCantidadProductos" := "baseCantidadProductos" + cantidad - minimo;
	FOR r IN "baseCantidadProductos" .. "limiteCantidadProductos" LOOP
		"precioDV" := trunc(random() * "precioMaxDV" + "precioMinDV");
		SELECT nro_categ FROM "SISTEMA-1".categoria ORDER BY random() LIMIT minimo INTO "nroCategoriaP";
		INSERT INTO "SISTEMA-1".producto(nro_producto, nombre, nro_categ, precio_actual) VALUES (r, 'Producto ' || r, "nroCategoriaP", "precioDV");
	END LOOP;
	-- carga ventas
	SELECT MAX(nro_factura) FROM "SISTEMA-1".venta INTO "baseCantidadVentas";
	IF "baseCantidadVentas" IS NULL THEN
		"baseCantidadVentas" := 0;
	END IF;
	"baseCantidadVentas" := "baseCantidadVentas" + minimo;
	"limiteCantidadVentas" := "baseCantidadVentas" + cantidad - minimo;
	FOR r IN "baseCantidadVentas" .. "limiteCantidadVentas" LOOP
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['contado','debito','credito','transferencia']) AS n) AS d ORDER BY random() LIMIT 1 INTO "forma_pagoV";
		"diasV" := trunc(random() * "diaMaxV" + minimo);
		SELECT nro_cliente FROM "SISTEMA-1".clientes ORDER BY random() LIMIT minimo INTO "nroClienteV";
		SELECT nombre FROM "SISTEMA-1".clientes WHERE nro_cliente = "nroClienteV" INTO "nombreClienteV";
		INSERT INTO "SISTEMA-1".venta(fecha_vta, nro_factura, nro_cliente, nombre, forma_pago) VALUES (current_date + CAST("diasV"||' days' AS INTERVAL), r, "nroClienteV", "nombreClienteV", "forma_pagoV");
		-- carga detalles venta
		"cantidadDetalleVentas" := trunc(random() * "cantMaxDV" + minimo);
		FOR t IN minimo .. "cantidadDetalleVentas" LOOP
			SELECT nro_producto FROM "SISTEMA-1".producto ORDER BY random() LIMIT minimo INTO "nroProductoDV";
			SELECT nombre FROM "SISTEMA-1".producto  WHERE nro_producto = "nroProductoDV" INTO "nombreProductoDV";
			"unidadDV" := trunc(random() * "unidadMaxDV" + minimo);
			SELECT precio_actual FROM "SISTEMA-1".producto  WHERE nro_producto = "nroProductoDV" INTO "precioDV";
			INSERT INTO "SISTEMA-1".detalle_venta(nro_factura, nro_producto, "descripción", unidad, precio) VALUES (r, "nroProductoDV",'Descripcion ' || "nombreProductoDV", "unidadDV", "precioDV");
		END LOOP;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT "SISTEMA-1"."llenarSistema-1"(1000);


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


----------------------------------------- Inserciones Sistema-2 -----------------------------------------


CREATE OR REPLACE FUNCTION "SISTEMA-2"."llenarSistema-2"(cantidad int) RETURNS VOID AS $$
DECLARE
	"baseCantidadClientes" integer;
	"limiteCantidadClientes" integer;
	"nombreC" varchar(30);
	"apellidoC" varchar(30);
	"tipoClienteTC" varchar(30);
	"calleC" varchar(30);
	"numMaxC" integer := 10000;
	"numeroC" integer;
	"descripcionCat" varchar(30);
	"baseCantidadProductos" integer;
	"limiteCantidadProductos" integer;
	"nroCategoriaP" text;
	"baseCantidadVentas" integer;
	"limiteCantidadVentas" integer;
	"forma_pagoMP" varchar(30);
	"diaMaxV" integer := 365;
	"diasV" integer;
	"nroClienteV" text;
	"nombreClienteV" varchar(30);
	"nroProductoDV" text;
	"nombreProductoDV" varchar(30);
	"cantidadDetalleVentas" integer;
	"cantMaxDV" integer := 15;
	"unidadDV" integer;
	"unidadMaxDV" integer := 100;
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
	"nroSubCategoriaP" text;
	minimo integer := 1;
	tipoclientes varchar(30)[];
	categorias varchar(30)[];
	mediospago varchar(30)[];
		
BEGIN
	-- carga tipo clientes
	tipoclientes := ARRAY['publico objetivo','cliente potencial','cliente eventual','interno','externo'];
	SELECT count(cod_tipo) FROM "SISTEMA-2".tipo_cliente INTO "cantidadTipoClientes";
	IF "cantidadTipoClientes" <> 5 THEN
		FOR r IN minimo .. 5 LOOP
			INSERT INTO "SISTEMA-2".tipo_cliente(cod_tipo, descripcion)VALUES (r, tipoclientes[r]);
		END LOOP;
	END IF;
	-- carga clientes	
	SELECT MAX(hex_to_int(cod_cliente)) FROM "SISTEMA-2".clientes INTO "baseCantidadClientes";
	IF "baseCantidadClientes" IS NULL THEN
		"baseCantidadClientes" := 0;
	END IF;
	"baseCantidadClientes" := "baseCantidadClientes" + minimo;
	"limiteCantidadClientes":= "baseCantidadClientes" + cantidad - minimo;
	FOR r IN "baseCantidadClientes" .. "limiteCantidadClientes" LOOP
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['Alicia','Marcela','Lidia','Estela','Nora','Norma','Ines','Noemi','Iris','Susana', 'Silvia', 'Carolina', 'Fatima']) AS n) AS d ORDER BY random() LIMIT 1 INTO "nombreC";	
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['Gonzalez','Rodriguez','Gomez','Fernandez','Lopez','Diaz','Martinez','Perez','Romero','Sanchez', 'Garcia', 'Sosa', 'Torres']) AS n) AS d ORDER BY random() LIMIT 1 INTO "apellidoC";
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['San Martin','Av. Colon','9 de Julio','Cacique Venancio','Castelar', 'Saavedra', 'Alsina', 'Vieytes', 'Brown', 'Sarmiento', 'Chiclana', 'Dorrego','Guemes', 'Berutti','Caronti', 'Casanova', 'Patricios', 'Donado', 'Fitz Roy', 'Av. Alem']) AS n) AS d ORDER BY random() LIMIT 1 INTO "calleC";
		SELECT cod_tipo FROM "SISTEMA-2".tipo_cliente ORDER BY random() LIMIT minimo INTO "codTipoC";
		"numeroC" := trunc(random() * "numMaxC" + minimo);
		INSERT INTO "SISTEMA-2".clientes(cod_cliente, nombre, cod_tipo, "dirección") VALUES (to_hex(r + hex_to_int('aaa')), "apellidoC" || ', ' || "nombreC", "codTipoC", "calleC" || ' ' || "numeroC");
	END LOOP;
	-- carga categorias
	categorias := ARRAY['almacen','panaderia','lacteos','carne vacuna','menudencias', 'carne porcina', 'granja', 'pescado', 'frutas', 'hortalizas', 'frutas secas']; 
	SELECT count(cod_categoria) FROM "SISTEMA-2".categoria INTO "cantidadCategorias";
	IF "cantidadCategorias" < 11 THEN
		FOR r IN minimo .. 11 LOOP
			"cantSubcategoria" := trunc(random() * "subCategoriaMax" + minimo);
			FOR t IN minimo .. "cantSubcategoria" LOOP
				INSERT INTO "SISTEMA-2".categoria(cod_categoria, cod_subcategoria, descripcion) VALUES (to_hex(r + hex_to_int('aaa')), to_hex(t + hex_to_int('aaa')) ,categorias[r]);
			END LOOP;
		END LOOP;
	END IF;
	-- carga productos
	SELECT MAX(hex_to_int(cod_producto)) FROM "SISTEMA-2".producto INTO "baseCantidadProductos";
	IF "baseCantidadProductos" IS NULL THEN
		"baseCantidadProductos" := 0;
	END IF;
	"baseCantidadProductos" := "baseCantidadProductos" + minimo;
	"limiteCantidadProductos" := "baseCantidadProductos" + cantidad - minimo;
	FOR r IN "baseCantidadProductos" .. "limiteCantidadProductos" LOOP
		"precioDV" := trunc(random() * "precioMaxDV" + "precioMinDV");
		SELECT cod_categoria FROM "SISTEMA-2".categoria ORDER BY random() LIMIT minimo INTO "nroCategoriaP";
		SELECT cod_subcategoria FROM "SISTEMA-2".categoria WHERE cod_categoria = "nroCategoriaP" ORDER BY random() LIMIT minimo INTO "nroSubCategoriaP";
		INSERT INTO "SISTEMA-2".producto(cod_producto, nombre, cod_categoria, cod_subcategoria, precio_actual) VALUES (to_hex(r + hex_to_int('aaa')), 'Producto ' || r, "nroCategoriaP", "nroSubCategoriaP", "precioDV");
	END LOOP;
	-- carga medios de pago
	mediospago := ARRAY['contado','debito','credito','transferencia'];
	SELECT count(cod_medio_pago) FROM "SISTEMA-2".medio_pago INTO "cantidadMediosPago";
	IF "cantidadMediosPago" <> 4 THEN
		FOR r IN minimo .. 4 LOOP
-- que va en valor unidad tipoOperacion ??
			INSERT INTO "SISTEMA-2".medio_pago(cod_medio_pago, "descripción", valor, unidad, tipo_operacion) VALUES (r, mediospago[r], 1, 1, r);
		END LOOP;
	END IF;
	-- carga ventas
	SELECT MAX(id_factura) FROM "SISTEMA-2".venta INTO "baseCantidadVentas";
	IF "baseCantidadVentas" IS NULL THEN
		"baseCantidadVentas" := 0;
	END IF;
	"baseCantidadVentas" := "baseCantidadVentas" + minimo;
	"limiteCantidadVentas" := "baseCantidadVentas" + cantidad - minimo;
	FOR r IN "baseCantidadVentas" .. "limiteCantidadVentas" LOOP
		SELECT cod_medio_pago FROM "SISTEMA-2".medio_pago ORDER BY random() LIMIT minimo INTO "codMedioPagoV";
		"diasV" := trunc(random() * "diaMaxV" + minimo);
		SELECT cod_cliente FROM "SISTEMA-2".clientes ORDER BY random() LIMIT minimo INTO "nroClienteV";
		SELECT nombre FROM "SISTEMA-2".clientes WHERE cod_cliente = "nroClienteV" INTO "nombreClienteV";
		INSERT INTO "SISTEMA-2".venta(fecha_vta, id_factura, cod_cliente, nombre, cod_medio_pago) VALUES (current_date + CAST("diasV"||' days' AS INTERVAL), r, "nroClienteV", "nombreClienteV", "codMedioPagoV");
		-- carga detalles venta
		"cantidadDetalleVentas" := trunc(random() * "cantMaxDV" + minimo);
		FOR t IN minimo .. "cantidadDetalleVentas" LOOP
			SELECT cod_producto FROM "SISTEMA-2".producto ORDER BY random() LIMIT minimo INTO "nroProductoDV";
			SELECT nombre FROM "SISTEMA-2".producto WHERE cod_producto = "nroProductoDV" INTO "nombreProductoDV";
			"unidadDV" := trunc(random() * "unidadMaxDV" + minimo);
			SELECT precio_actual FROM "SISTEMA-2".producto  WHERE cod_producto = "nroProductoDV" INTO "precioDV";
			INSERT INTO "SISTEMA-2".detalle_venta(id_factura, cod_producto, "descripción", unidad, precio) VALUES (r, "nroProductoDV", 'Descripcion ' || "nombreProductoDV", "unidadDV", "precioDV");
		END LOOP;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT "SISTEMA-2"."llenarSistema-2"(1000);
