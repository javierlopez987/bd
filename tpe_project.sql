SET search_path = unc_249695;

--testing
--Cargar tablas
--Tabla PAIS
INSERT INTO gr05_pais VALUES ('Argentina');

--Tabla PROVINCIA
INSERT INTO gr05_provincia VALUES ('Argentina', 'Buenos Aires');
INSERT INTO gr05_provincia VALUES ('Argentina', 'San Juan');

--Tabla DISTRITO
INSERT INTO gr05_distrito VALUES (1, 'Argentina', 'Buenos Aires', 'Tandil');
INSERT INTO gr05_distrito VALUES (2, 'Argentina', 'San Juan', 'San Juan');

--Tabla USUARIO
INSERT INTO gr05_usuario VALUES (1, 'Javier', 'Lopez Ferreira', 'jlopezferreira@alumnos.exa.unicen.edu.ar', '1234');

--Tabla CATEGORIA
INSERT INTO gr05_categoria VALUES (1, 'Deportivo');

--Tabla SUBCATEGORIA
INSERT INTO gr05_subcategoria VALUES (1, 1, 'Trekking');

--Tabla EVENTO
INSERT INTO gr05_evento VALUES (1, 'Aventura Las Ánimas', 'Trekking de aventura por el Cerro Las Ánimas y alrededores', 1, 1, 1, 1, 21,9,true);

--Tabla EVENTO_EDICION
INSERT INTO gr05_evento_edicion VALUES (1, 1, to_date('21/06/2020','DD/MM/YYYY'), NULL, 60000.00, NULL);

--Tabla PATROCINANTE
INSERT INTO gr05_patrocinante VALUES (1, 'Ansilta', 'Juan', 'Pérez', 'Necochea 2085', 2);
INSERT INTO gr05_patrocinante VALUES (2, 'Centro de Montaña Tandil', 'Juliana', 'Gómez', 'Pje El Centinela S/N', 1);

--Tabla PATROCINIOS
INSERT INTO gr05_patrocinios VALUES (1,1,1,58000.00);
INSERT INTO gr05_patrocinios VALUES (2,1,1,2000.00);