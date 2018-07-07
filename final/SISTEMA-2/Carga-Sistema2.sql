-- Inserciones Sistema-2
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
	"diaMaxV" integer := 900;
	"diasV" integer;
	"nroClienteV" text;
	"nombreClienteV" varchar(30);
	"nroProductoDV" text;
	"nombreProductoDV" varchar(30);
	"cantidadDetalleVentas" integer;
	"cantMaxDV" integer := 5;
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
	fecha_minima timestamp;
		
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
		--"baseCantidadClientes" := 10000;
		--"baseCantidadClientes" := 100000;
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
	fecha_minima := current_date - CAST("diaMaxV"||' days' AS INTERVAL);
	FOR r IN "baseCantidadVentas" .. "limiteCantidadVentas" LOOP
		SELECT cod_medio_pago FROM "SISTEMA-2".medio_pago ORDER BY random() LIMIT minimo INTO "codMedioPagoV";
		"diasV" := trunc(random() * "diaMaxV" + minimo);
		SELECT cod_cliente FROM "SISTEMA-2".clientes ORDER BY random() LIMIT minimo INTO "nroClienteV";
		SELECT nombre FROM "SISTEMA-2".clientes WHERE cod_cliente = "nroClienteV" INTO "nombreClienteV";
		INSERT INTO "SISTEMA-2".venta(fecha_vta, id_factura, cod_cliente, nombre, cod_medio_pago) VALUES (fecha_minima + CAST("diasV"||' days' AS INTERVAL), r, "nroClienteV", "nombreClienteV", "codMedioPagoV");
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

-- SELECT "SISTEMA-2"."llenarSistema-2"(300);


------------------------------------------------- Otros -------------------------------------------------


-- Funcion hex_to_int - Pasa numeros hexadecimales a decimales - La usa el scrip de carga del sistema 2 (Sistema nuevo)
CREATE OR REPLACE FUNCTION hex_to_int(hexval varchar) RETURNS integer AS $$
DECLARE
	result  int;
BEGIN
	EXECUTE 'SELECT x''' || hexval || '''::int' INTO result;
	RETURN result;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT; 