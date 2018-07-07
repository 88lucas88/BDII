-------------------------------- Scripts de carga ETL ------------------------------------


-- Script ETL - Carga tabla de equivalencia de clientes
CREATE OR REPLACE FUNCTION CargaTEClientes(porcentajeEquivalentes int, suc_db int) RETURNS VOID AS
$$
DECLARE
	clienteSN text;
	clienteSV integer;
	IDclienteSN integer;
	IDclienteSV integer;
	totalClientes integer;
	cantidadEquivalentes  integer;
	res_conect text;
	cdw_ini integer;
	
BEGIN
	SELECT dblink_connect('conect_suc', 'hostaddr=192.168.43.243 port=5432 dbname=PatSur-Suc-' || CAST(pSuc as text) || ' user=postgres password=postgres') into res_conect;
	cdw_ini := (SELECT max(cdw) FROM TECliente);
	IF cdw_ini IS NULL THEN
		cdw_ini := 0;
	END IF;
	INSERT INTO TECliente (cvs) SELECT * FROM dblink ('conect_suc', 'SELECT nro_cliente FROM "SISTEMA-1".Clientes') AS cn(nro_cliente int) WHERE cn.nro_cliente not in (SELECT cvs FROM TECliente WHERE cvs IS NOT NULL) ;
	INSERT INTO TECliente (cns) SELECT * FROM dblink ('conect_suc', 'SELECT cod_cliente FROM "SISTEMA-2".Clientes') AS cn(cod_cliente text) WHERE cn.cod_cliente not in (SELECT cns FROM TECliente WHERE cns IS NOT NULL);
	totalClientes := (SELECT max(cdw) FROM TECliente) - cdw_ini;
	cantidadEquivalentes := (totalClientes *  porcentajeEquivalentes)/100;
	FOR r IN 1 .. cantidadEquivalentes LOOP
		SELECT cdw FROM tecliente WHERE (cdw>cdw_ini and cns IS NOT NULL and cvs IS NULL) ORDER BY random() LIMIT 1 INTO IDclienteSN;
		SELECT cns FROM tecliente WHERE cdw = IDclienteSN INTO clienteSN;
		DELETE FROM tecliente WHERE cdw = IDclienteSN;
		SELECT cdw FROM tecliente WHERE (cdw>cdw_ini and cns IS NULL and cvs IS NOT NULL) ORDER BY random() LIMIT 1 INTO IDclienteSV;
		UPDATE tecliente SET cns=clienteSN WHERE cdw=IDclienteSV;	
	END LOOP;
	SELECT dblink_disconnect('conect_suc') into res_conect;
END;
$$ LANGUAGE plpgsql;

-- SELECT CargaTEClientes(25, 'PatSur-Suc-1');
-- SELECT CargaTEClientes(20, 'PatSur-Suc-2');
-- SELECT CargaTEClientes(10, 'PatSur-Suc-3');

-- Script ETL - Carga tabla de equivalencia de productos
CREATE OR REPLACE FUNCTION CargaTEProductos(porcentajeEquivalentes int, suc_db int) RETURNS VOID AS
$$
DECLARE
	productoSN text;
	productoSV integer;
	IDproductoSN integer;
	IDproductoSV integer;
	totalProductos integer;
	cantidadEquivalentes  integer;
	res_conect text;
	pdw_ini integer;
	
BEGIN
	SELECT dblink_connect('conect_suc', 'hostaddr=192.168.43.243 port=5432 dbname=PatSur-Suc-' || CAST(pSuc as text) || ' user=postgres password=postgres') into res_conect;
	pdw_ini := (SELECT max(pdw) FROM TEProductos);
	IF pdw_ini IS NULL THEN
		pdw_ini := 0;
	END IF;	
	INSERT INTO teproductos (pvs)
	SELECT * FROM dblink ('conect_suc', 'SELECT nro_producto FROM "SISTEMA-1".producto') AS cn(nro_producto int) WHERE cn.nro_producto not in (SELECT pvs FROM TEProductos WHERE pvs IS NOT NULL);
	INSERT INTO teproductos (pns)
	SELECT * FROM dblink ('conect_suc', 'SELECT cod_producto FROM "SISTEMA-2".producto') AS cn(cod_producto text) WHERE cn.cod_producto not in (SELECT pns FROM TEProductos WHERE pns IS NOT NULL);
	totalProductos := (SELECT max(pdw) FROM TEProductos) - pdw_ini;
	cantidadEquivalentes := (totalProductos *  porcentajeEquivalentes)/100;
	FOR r IN 1 .. cantidadEquivalentes LOOP
		SELECT pdw FROM teproductos WHERE (pdw>pdw_ini and pns IS NOT NULL and pvs IS NULL) ORDER BY random() LIMIT 1 INTO IDproductoSN;
		SELECT pns FROM teproductos WHERE pdw = IDproductoSN INTO productoSN;
		DELETE FROM teproductos WHERE pdw = IDproductoSN;
		SELECT pdw FROM teproductos WHERE (pdw>pdw_ini and pns IS NULL and pvs IS NOT NULL) ORDER BY random() LIMIT 1 INTO IDproductoSV;
		UPDATE teproductos SET pns=productoSN WHERE pdw=IDproductoSV;		
	END LOOP;
	SELECT dblink_disconnect('conect_suc') into res_conect;
END;
$$ LANGUAGE plpgsql;

-- SELECT CargaTEProductos(30, 'PatSur-Suc-1');
-- SELECT CargaTEProductos(30, 'PatSur-Suc-2');
-- SELECT CargaTEProductos(30, 'PatSur-Suc-3');

-- Script ETL - Extraccion de datos de ventas desde el sistema de facturacion viejo
CREATE OR REPLACE FUNCTION CargaTmpVentas(pSuc integer, pMes integer, pAño integer) RETURNS VOID AS
$$
DECLARE
	res_conect text;
BEGIN
	SELECT dblink_connect('conect_suc', 'hostaddr=192.168.43.243 port=5432 dbname=PatSur-Suc-' || CAST(pSuc as text) || ' user=postgres password=postgres') into res_conect;
	INSERT INTO tmpVentas(fecha_vta, Id_Factura, Id_Cliente, Id_Producto, Id_Sucursal, Id_medio_pago, monto_vendido, cantidad_vendida, nombre_producto,
	Id_categoria, nombre_cliente, tipo_cliente)	
	SELECT fecha_vta, Id_Factura, Id_Cliente, Id_Producto, Id_Sucursal, Id_medio_pago, monto_vendido, cantidad_vendida, nombre_producto, 
	Id_categoria, nombre_cliente, tipo_cliente FROM 
	(SELECT fecha_vta, Id_Factura, Id_Cliente, Id_Producto, Id_Sucursal, Id_medio_pago, monto_vendido, 
	cantidad_vendida, nombre_producto, C.id_categoria as Id_categoria, nombre_cliente, tipo_cliente FROM
	(SELECT fecha_vta, Id_Factura, Id_Cliente, Id_Producto, Id_Sucursal, Id_medio_pago, 
	monto_vendido, cantidad_vendida, nombre_producto, descrip_categ, nombre_cliente, TC.id_tipo AS tipo_cliente
	FROM 
	(SELECT * FROM dblink ('conect_suc', 'SELECT fecha_vta, v.nro_factura, CAST (c.nro_cliente as text), CAST (p.nro_producto as text), ' || CAST(pSuc AS text) || 'as Id_Sucursal, 
	CASE v.forma_pago WHEN ''contado'' THEN 1 WHEN ''debito'' THEN 2 WHEN ''credito'' THEN 3 WHEN ''transferencia'' THEN 4 END AS Id_medio_pago, 
	unidad * precio as monto_vendido, unidad as cantidad_vendida, p.nombre, cat.descripcion as descrip_cat, c.nombre, c.tipo
	FROM "SISTEMA-1".venta v, "SISTEMA-1".detalle_venta dv, "SISTEMA-1".clientes c, "SISTEMA-1".producto p, "SISTEMA-1".categoria cat
	WHERE v.nro_Factura = dv.nro_Factura and v.nro_cliente = c.nro_cliente and dv.nro_producto = p.nro_producto and p.nro_categ = cat.nro_categ and date_part (''month'', fecha_vta) =  ' || CAST(pMes AS text) || '
	and date_part (''year'', fecha_vta) = ' || CAST(pAño AS text))
	AS tmpvent (fecha_vta timestamp, Id_Factura int, Id_Cliente text, Id_Producto text, Id_Sucursal int, Id_medio_pago int, monto_vendido real, cantidad_vendida real, nombre_producto varchar(30), 
	descrip_categ text, nombre_cliente varchar(30), tipo_cliente varchar(30)))
	AS I 
	INNER JOIN tipo_cliente AS TC ON (I.tipo_cliente = TC.descripcion))
	AS TCI 
	INNER JOIN (select descripcion, id_categoria from categoria group by descripcion, id_categoria) AS C ON C.descripcion = TCI.descrip_categ) AS TCII;
	UPDATE tmpventas SET Id_Tiempo = InsertarTiempo(pMes, pAño) WHERE Id_Tiempo IS NULL;
	UPDATE tmpventas SET id_subcategoria = (SELECT MAX(cat.id_subcategoria) FROM categoria as cat where cat.id_categoria = tmpventas.id_categoria ) WHERE id_subcategoria IS NULL;
	SELECT dblink_disconnect('conect_suc') into res_conect;
END;
$$ LANGUAGE plpgsql;

-- Script ETL - Extraccion de datos de ventas desde el sistema de facturacion nuevo
CREATE OR REPLACE FUNCTION CargaTmpVentasSN(pSuc integer, pMes integer, pAño integer) RETURNS VOID AS
$$
DECLARE
	res_conect text;
BEGIN	

	SELECT dblink_connect('conect_suc', 'hostaddr=192.168.43.243 port=5432 dbname=PatSur-Suc-' || CAST(pSuc as text) || ' user=postgres password=postgres') into res_conect;
	INSERT INTO tmpventas(fecha_vta, Id_Factura, Id_Cliente, Id_producto, Id_Sucursal, Id_medio_pago, monto_vendido, cantidad_vendida, 
		nombre_producto, Id_categoria, Id_subcategoria, nombre_cliente, tipo_cliente)
	SELECT * FROM dblink ('conect_suc', 'SELECT fecha_vta, v.id_factura, c.cod_cliente, p.cod_producto, ' || CAST(pSuc AS text) || 'as Id_Sucursal, 
		v.cod_medio_pago, unidad * precio as monto_vendido, unidad as cantidad_vendida,p.nombre, p.cod_categoria, p.cod_subcategoria, c.nombre, c.cod_tipo 
		FROM "SISTEMA-2".venta v, "SISTEMA-2".detalle_venta dv, "SISTEMA-2".clientes c, "SISTEMA-2".producto p
		WHERE v.id_factura = dv.id_factura and v.cod_cliente = c.cod_cliente and dv.cod_producto = p.cod_producto and  
		date_part (''month'', fecha_vta) =  ' || CAST(pMes AS text) || 'and date_part (''year'', fecha_vta) = ' || CAST(pAño AS text))
		AS tmpvent (fecha_vta timestamp, Id_Factura int, Id_Cliente text, Id_Producto text, Id_Sucursal int, Id_medio_pago int, monto_vendido real, 
		cantidad_vendida real, nombre_producto varchar(30), Id_categoria text, Id_subcategoria text, nombre_cliente varchar(30), tipo_cliente int);
	UPDATE tmpventas SET Id_Tiempo = InsertarTiempo(pMes, pAño) WHERE Id_Tiempo IS NULL;
	SELECT dblink_disconnect('conect_suc') into res_conect;
END;
$$ LANGUAGE plpgsql;

-- Script ETL - Carga las tablas del DW
CREATE OR REPLACE FUNCTION Carga_CPV() RETURNS VOID AS
$$
DECLARE

BEGIN	
	--ingreso de clientes del viejo sistema desde tmpVentas
	INSERT INTO Clientes
		SELECT DISTINCT cdw, cortarApellidos(nombre_cliente), tipo_cliente
		FROM tmpVentas tmpv, TECliente tec
		WHERE tmpv.id_cliente = CAST (tec.cvs as text) AND tec.cdw not in (SELECT id_cliente from Clientes);
	--ingreso de clientes del nuevo sistema desde tmpVentas
	INSERT INTO Clientes
		SELECT DISTINCT cdw, cortarApellidos(nombre_cliente), tipo_cliente
		FROM tmpVentas tmpv, TECliente tec
		WHERE tmpv.id_cliente = tec.cns AND tec.cdw not in (SELECT id_cliente from Clientes);
	--ingreso de productos del viejo sistema desde tmpVentas
	INSERT INTO Productos
		SELECT DISTINCT pdw, id_categoria, id_subcategoria, nombre_producto 
		FROM tmpVentas tmpv, TEProductos tep
		WHERE tmpv.id_producto = CAST (tep.pvs as text) and tep.pdw not in (SELECT id_producto from Productos);
	--ingreso de productos del nuevo sistema desde tmpVentas
	INSERT INTO Productos
		SELECT DISTINCT pdw, id_categoria, id_subcategoria, nombre_producto
		FROM tmpVentas tmpv, TEProductos tep
		WHERE tmpv.id_producto = tep.pns and tep.pdw not in (SELECT id_producto from Productos);
	--ingreso de ventas del viejo sistema desde tmpVentas
	INSERT INTO Ventas
	SELECT id_tiempo, fecha_vta, id_factura, cdw, pdw, id_sucursal, id_medio_pago, monto_vendido, cantidad_vendida
	FROM tmpVentas tmpv, TECliente tec, TEProductos tep
	WHERE tmpv.id_cliente = CAST (tec.cvs as text) AND tmpv.id_producto = CAST (tep.pvs as text);
	--ingreso de ventas del nuevo sistema desde tmpVentas
	INSERT INTO Ventas
	SELECT id_tiempo, fecha_vta, id_factura, cdw, pdw, id_sucursal, id_medio_pago, monto_vendido, cantidad_vendida
	FROM tmpVentas tmpv, TECliente tec, TEProductos tep
	WHERE tmpv.id_cliente = tec.cns AND tmpv.id_producto = tep.pns;
END;
$$ LANGUAGE plpgsql; 

-- SELECT Carga_CPV();

-- Script ETL - Extraccion de datos de ventas DE UNA  FECHA y de UNA sucursal 
CREATE OR REPLACE FUNCTION Carga_Particular(pSuc integer, pMes integer, pAño integer) RETURNS VOID AS
$$
DECLARE
	a record;
BEGIN	
	SELECT CargaTmpVentas(pSuc, pMes, pAño) into a;
	SELECT CargaTmpVentasSN(pSuc, pMes, pAño) into a;	
	SELECT Carga_CPV() into a;
	DELETE FROM tmpventas;
END;
$$ LANGUAGE plpgsql;

-- Script ETL - Extraccion de datos de ventas ENTRE DOS FECHA de TODAS las sucursales 
CREATE OR REPLACE FUNCTION Carga_General(ainicial integer, afinal integer) RETURNS VOID AS
$$
DECLARE
	i integer; j integer; a record;
BEGIN

	FOR i IN 1 .. 3 LOOP
		SELECT * INTO a FROM (SELECT CargaTEClientes(20,i)) as s;
		SELECT * INTO a FROM (SELECT CargaTEProductos(20,i)) as s;
	END LOOP;

	FOR k IN 1 .. 3 LOOP
		FOR i IN ainicial .. afinal LOOP
			FOR j IN 1 .. 12 LOOP
				SELECT * INTO a FROM (SELECT Carga_Particular(k,j,i)) as s;
			END LOOP;
		END LOOP;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

-- SELECT Carga_General (2010, 2019);