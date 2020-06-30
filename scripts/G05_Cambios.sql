--a)Se debe consistir que la fecha de inicio de la publicación de la edición
--sea anterior a la fecha de fin de la publicación del mismo si esta última no es nula.
--Restricción de tupla
ALTER TABLE gr05_evento_edicion
ADD CONSTRAINT ck_inicio_fin_publicacion
CHECK ( ( fecha_fin_pub IS NOT NULL AND fecha_fin_pub > fecha_inicio_pub )
	OR fecha_fin_pub IS NULL);

--VISTAS
--1) Identificador de los Eventos cuya fecha de realización de su último encuentro
--esté en el primer trimestre de 2020
CREATE VIEW v_eventos_trim_1_2020 AS
	SELECT id_evento
	FROM gr05_evento_edicion
	WHERE fecha_edicion BETWEEN to_date('01/01/2020', 'DD/MM/YYYY') AND to_date('31/03/2020', 'DD/MM/YYYY');

--2) Datos completos de los distritos indicando la cantidad de eventos en cada uno
--En SQL Standard
CREATE VIEW cant_eventos_distrito AS
    SELECT d.*, count(*) AS cant_eventos
    FROM gr05_distrito d
        JOIN gr05_evento e ON (e.id_distrito = d.id_distrito)
    GROUP BY d.id_distrito;

--3)Datos Categorías que poseen eventos en todas sus subcategorías
CREATE VIEW categoria_all_subcategorias_con_eventos AS
SELECT *
FROM gr05_categoria c
WHERE NOT EXISTS(
    SELECT 1
    FROM gr05_subcategoria s
    WHERE (c.id_categoria = s.id_categoria)
        AND NOT EXISTS(
            SELECT id_categoria, id_subcategoria
            FROM gr05_evento e
            WHERE (s.id_categoria = e.id_categoria
                AND s.id_subcategoria = e.id_subcategoria)
        )
    )
WITH LOCAL CHECK OPTION ;