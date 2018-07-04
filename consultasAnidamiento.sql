--4) Implementar consultas para las vistas que los analistas requirieron
--	Venta vista por mes o por año, por sucursal, por región, por cliente y demás combinaciones entre las perspectivas.

SELECT T.mes, T.año, S.descripcion, C.descripcion, CL.nombre, sum(monto_venido), sum(V.cantidad_vendida)
FROM ventas V, tiempo T, sucursal S, ciudad C, clientes CL
WHERE V.id_tiempo = T.id_tiempo and V.id_sucursal = S.id_sucursal
	and S.id_ciudad = C.id_ciudad and V.id_cliente = CL.id_cliente
GROUP BY CUBE(T.mes, T.año,
	(S.id_sucursal, S.descripcion),
	(C.id_ciudad,C.descripcion),
	(CL.id_cliente,CL.nombre)
)
	
--	El mínimo nivel de detalle que se quiere tener disponible para el análisis de las ventas ($ vendidos y unidades vendidas) es el de la facturas.

--	Es necesario conocer también de que manera influye, en las ventas de productos, la zona geográfica en la que están ubicados los locales.

SELECT R.descripcion, P.descripcion, C.descripcion, sum(V.monto_vendido) as monto_total_vendido, sum(V.cantidad_vendida) as cant_total_ventida
FROM ventas V, sucursal S, ciudad C, provincia P, region R
WHERE V.id_sucursal = S.id_sucursal and S.id_ciudad = C.id_ciudad
	and C.id_provincia = P.id_provincia and P.id_region = R.id_region
GROUP BY ROLLUP (
	(R.id_region,R.descripcion),
	(P.id_provincia, P.descripcion),
	(C.id_ciudad, C.descripcion)
)

--	De cada cliente se desea conocer cuales son los que generan mayores ingresos a la cooperativa.

SELECT C.nombre, sum(cantidad_vendida), sum(V.monto_vendido) as total_ingreso, rank() over (order by (sum(V.monto_vendido)) desc) as pos
FROM Clientes C, Ventas V
WHERE C.id_cliente = V.id_cliente
GROUP BY C.id_cliente
ORDER BY pos

--	Se necesitará hacer análisis diarios, mensuales, trimestrales y anuales.

SELECT T.año, T.trimetres, T.mes, V.fecha, sum(cantidad_vendida) as cantidad_total, sum(V.monto_vendido) as total_ingreso
FROM Ventas V, Tiempo T
WHERE V.id_tiempo = T.id_tiempo
GROUP BY ROLLUP(T.año, T.trimetres, T.mes, V.fecha)
	
/*Para las mismas se deben hacer los SELECT y comentarlos con las funciones GROUPING
SETS, ROLLUP y CUBE brindadas por las extensiones del lenguaje SQL:1999 para facilitar la
agrupación de los datos.*/

SELECT * FROM sucursal
INSERT INTO public.sucursal(id_sucursal, descripcion, id_ciudad) VALUES (1, 'Sucursal 1', 1);
INSERT INTO public.sucursal(id_sucursal, descripcion, id_ciudad) VALUES (2, 'Sucursal 2', 2);
INSERT INTO public.sucursal(id_sucursal, descripcion, id_ciudad) VALUES (3, 'Sucursal 3', 3);
SELECT DISTINCT id_sucursal FROM ventas

SELECT * FROM ciudad
INSERT INTO ciudad VALUES (1, 'Trelew', 1)
INSERT INTO ciudad VALUES (2, 'Rawson', 1)
INSERT INTO ciudad VALUES (3, 'La Plata', 2)

SELECT * FROM provincia
INSERT INTO provincia VALUES (1,'Chubut',1)
INSERT INTO provincia VALUES (2,'Buenos Aires',2)

SELECT * FROM region
INSERT INTO region VALUES (1, 'Patagonica')
INSERT INTO region VALUES (2, 'Centro-Este')

ciudad(id_ciudad,descripcion,id_provincia)
provincia(id_provincia, descripcion,id_region)
region(id_region,descripcion)

