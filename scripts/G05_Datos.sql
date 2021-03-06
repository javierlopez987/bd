--Cargar tablas
--Tabla PAIS
INSERT INTO gr05_pais VALUES ('Argentina');

--Tabla PROVINCIA
INSERT INTO gr05_provincia VALUES ('Argentina', 'Buenos Aires');
INSERT INTO gr05_provincia VALUES ('Argentina', 'San Juan');
INSERT INTO gr05_provincia VALUES ('Argentina', 'Río Negro');
INSERT INTO gr05_provincia VALUES ('Argentina', 'Ciudad Autónoma de Buenos Aires');

--Tabla DISTRITO
INSERT INTO gr05_distrito VALUES (1, 'Argentina', 'Buenos Aires', 'Tandil');
INSERT INTO gr05_distrito VALUES (2, 'Argentina', 'San Juan', 'San Juan');
INSERT INTO gr05_distrito VALUES (3, 'Argentina', 'Río Negro', 'Bariloche');
INSERT INTO gr05_distrito VALUES (4, 'Argentina', 'Ciudad Autónoma de Buenos Aires', 'Ciudad Autónoma de Buenos Aires');

--Tabla USUARIO
INSERT INTO gr05_usuario VALUES (1, 'Javier', 'Lopez Ferreira', 'jlopezferreira@alumnos.exa.unicen.edu.ar', '1234');

--Tabla CATEGORIA
INSERT INTO gr05_categoria VALUES (1, 'Deporte Verano');
INSERT INTO gr05_categoria VALUES (2, 'Deporte Invierno');

--Tabla SUBCATEGORIA
INSERT INTO gr05_subcategoria VALUES (1, 1, 'Trekking');
INSERT INTO gr05_subcategoria VALUES (1, 2, 'Escalada');
INSERT INTO gr05_subcategoria VALUES (1, 3, 'Running');
INSERT INTO gr05_subcategoria VALUES (1, 4, 'Triatlón');
INSERT INTO gr05_subcategoria VALUES (2, 5, 'Ski');

--Tabla EVENTO
INSERT INTO gr05_evento VALUES (1, 'Aventura Las Ánimas', 'Trekking de aventura por el Cerro Las Ánimas y alrededores', 1, 1, 1, 1, 21,1,true);
INSERT INTO gr05_evento VALUES (2, 'Hombre de Hierro', 'Carrera de triatlón en el Lago del Fuerte y alrededores', 1, 4, 1, 1, 20,11,true);
INSERT INTO gr05_evento VALUES (3, 'Ski Syncro', 'Competencia de ski sincronizado en el Cerro Catedral', 2, 5, 1, 3, 10,8,true);
UPDATE gr05_evento SET mes_evento = 3 WHERE id_evento = 1;
--Tabla PATROCINANTE
INSERT INTO gr05_patrocinante VALUES (2, 'Centro de Montaña Tandil', 'Juliana', 'Gómez', 'Pje El Centinela S/N', 1);
INSERT INTO gr05_patrocinante VALUES (1, 'Ansilta', 'Juan', 'Pérez', 'Necochea 2085', 2);
INSERT INTO gr05_patrocinante VALUES (3, 'Northface', 'Pedro', 'González', 'Av. Santa Fe 3253', 4);
INSERT INTO gr05_patrocinante VALUES (4, 'Naka Outdoors', 'Ramiro', 'Nakarato', 'Ramallo 2307', 4);
INSERT INTO gr05_patrocinante VALUES (5, 'Head Argentina', 'Esteban', 'Headache', NULL, 4);

--Tabla EVENTO_EDICION
INSERT INTO gr05_evento_edicion VALUES (1, 1, to_date('21/01/2020','DD/MM/YYYY'), NULL, 60000.00, NULL);
INSERT INTO gr05_evento_edicion VALUES (3, 1, to_date('18/08/2020','DD/MM/YYYY'), NULL, 200000.00, NULL);

--Tabla PATROCINIOS
INSERT INTO gr05_patrocinios VALUES (2,1,1,2000.00);
INSERT INTO gr05_patrocinios VALUES (3,3,1,80000.00);
INSERT INTO gr05_patrocinios VALUES (4,3,1,20000.00);
INSERT INTO gr05_patrocinios VALUES (1,1,1,58000.00);

