-- Inserciones Sistema-1

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
	"diaMaxV" integer := 1094;
	"diasV" integer;
	"nroClienteV" int;
	"nombreClienteV" varchar(30);
	"nroProductoDV" integer;
	"nombreProductoDV" varchar(30);
	"cantidadDetalleVentas" integer;
	"cantMaxDV" integer := 5;
	"unidadDV" integer;
	"unidadMaxDV" integer := 100;
	"precioDV" integer;
	"precioMaxDV" integer := 1500;
	"precioMinDV" integer := 500;
	"cantidadCategorias" integer;
	minimo integer := 1;
	categorias varchar(30)[];
	fecha_maxima timestamp := '2015-12-31 00:00:00';		

BEGIN		
	-- carga clientes
	SELECT MAX(nro_cliente) FROM "SISTEMA-1".clientes INTO "baseCantidadClientes";
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
	fecha_maxima := fecha_maxima - CAST("diaMaxV"||' days' AS INTERVAL);
	FOR r IN "baseCantidadVentas" .. "limiteCantidadVentas" LOOP
		SELECT d.n FROM (SELECT n FROM unnest(ARRAY['contado','debito','credito','transferencia']) AS n) AS d ORDER BY random() LIMIT 1 INTO "forma_pagoV";
		"diasV" := trunc(random() * "diaMaxV" + minimo);
		SELECT nro_cliente FROM "SISTEMA-1".clientes ORDER BY random() LIMIT minimo INTO "nroClienteV";
		SELECT nombre FROM "SISTEMA-1".clientes WHERE nro_cliente = "nroClienteV" INTO "nombreClienteV";
		INSERT INTO "SISTEMA-1".venta(fecha_vta, nro_factura, nro_cliente, nombre, forma_pago) VALUES (fecha_maxima + CAST("diasV"||' days' AS INTERVAL), r, "nroClienteV", "nombreClienteV", "forma_pagoV");
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

-- SELECT "SISTEMA-1"."llenarSistema-1"(300);