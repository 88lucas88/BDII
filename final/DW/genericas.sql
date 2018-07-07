---------------------------------------- Otras -------------------------------------------


-- Inserta mes y año en tabla en tabla Tiempo - La usan los Scrip ETL 
CREATE OR REPLACE FUNCTION InsertarTiempo(mesI integer, añoI integer) RETURNS integer AS
$$
DECLARE
	id integer;
BEGIN
	SELECT id_tiempo FROM public.tiempo WHERE mes=mesI and "año"= añoI into id;
	IF id IS NULL THEN
		CASE 
			WHEN (mesI >= 1 AND mesI <= 3) THEN
				INSERT INTO TIEMPO (mes,año,trimetres) VALUES (mesI,añoI,1);
			WHEN (mesI >= 4 AND mesI <= 6) THEN
				INSERT INTO TIEMPO (mes,año,trimetres) VALUES (mesI,añoI,2);
				
			WHEN (mesI >= 7 AND mesI <= 9) THEN
				INSERT INTO TIEMPO (mes,año,trimetres) VALUES (mesI,añoI,3);
			ELSE
				INSERT INTO TIEMPO (mes,año,trimetres) VALUES (mesI,añoI,4);
		END CASE;
		SELECT id_tiempo FROM public.tiempo WHERE mes=mesI and "año"= añoI into id;
	END IF;
	RETURN id;
END;
$$ LANGUAGE plpgsql;

-- Elimina apellidos de  nombre_cliente (con formato apellidos, nombres) - La usan los Scrip ETL 
CREATE OR REPLACE FUNCTION cortarApellidos(nombre text) RETURNS text AS $$
DECLARE
	result text;
BEGIN
	SELECT REGEXP_REPLACE(nombre, '^((\w+\s)*\w+,\s)', '') INTO result;
	RETURN result;
END;
$$ LANGUAGE plpgsql; 