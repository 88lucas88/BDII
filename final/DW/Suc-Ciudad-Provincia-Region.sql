-- TABLA SUCURSAL
CREATE TABLE SUCURSAL (
	Id_Sucursal int NOT NULL,
	descripcion varchar(30) NULL,
	Id_Ciudad int NOT NULL,
	CONSTRAINT PK_SUCURSAL PRIMARY KEY (Id_Sucursal)
);

-- TABLA CIUDAD
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

-- TABLA PROVINCIA
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

-- TABLA REGION
CREATE TABLE REGION (
	Id_Region int NOT NULL,
	descripcion varchar(30) NULL,
	CONSTRAINT PK_REGION PRIMARY KEY (Id_Region)	
);

ALTER TABLE PROVINCIA
ADD CONSTRAINT FK_REGION FOREIGN KEY(Id_Region)
REFERENCES REGION (Id_Region)
on delete restrict on update restrict;

-- Carga de valores en tablas que suponemos que ya estan cargados en el DW (esto es una simplificación) 
INSERT INTO region VALUES (1, 'Patagonica');
INSERT INTO region VALUES (2, 'Centro-Este');
INSERT INTO provincia VALUES (1,'Chubut',1);
INSERT INTO provincia VALUES (2,'Buenos Aires',2);
INSERT INTO ciudad VALUES (1, 'Trelew', 1);
INSERT INTO ciudad VALUES (2, 'Rawson', 1);
INSERT INTO ciudad VALUES (3, 'La Plata', 2);
INSERT INTO public.sucursal(id_sucursal, descripcion, id_ciudad) VALUES (1, 'Sucursal 1', 1);
INSERT INTO public.sucursal(id_sucursal, descripcion, id_ciudad) VALUES (2, 'Sucursal 2', 2);
INSERT INTO public.sucursal(id_sucursal, descripcion, id_ciudad) VALUES (3, 'Sucursal 3', 3);