SET search_path = unc_249695;

--a)Se debe consistir que la fecha de inicio de la publicación de la edición
--sea anterior a la fecha de fin de la publicación del mismo si esta última no es nula.
--Restricción de tupla
ALTER TABLE gr05_evento_edicion
ADD CONSTRAINT ck_inicio_fin_publicacion
CHECK ( ( fecha_fin_pub IS NOT NULL AND fecha_fin_pub > fecha_inicio_pub )
	OR fecha_fin_pub IS NULL);
	
	
CREATE OR REPLACE FUNCTION FN_GR05_SUBCATEGORIA_MAXIMO_CANTIDAD_SUBCATEGORIAS() RETURNS Trigger AS $$
DECLARE
    cant        integer;
BEGIN
   SELECT count(*) INTO cant
   FROM gr05_subcategoria
   WHERE id_categoria = NEW.id_categoria;
   IF (cant > 50 ) THEN
      RAISE EXCEPTION 'Superó la cantidad de % subacategorias %', cant, NEW.id_categoria;
   END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR05_SUBCATEGORIA_MAXIMO_CANTIDAD_SUBCATEGORIAS
BEFORE INSERT OR UPDATE OF id_categoria
ON gr05_subcategoria
    FOR EACH ROW EXECUTE PROCEDURE FN_GR05_SUBCATEGORIA_MAXIMO_CANTIDAD_SUBCATEGORIAS();

--------------------------------- B--------------------------------
CREATE OR REPLACE FUNCTION FN_GR05_SUBCATEGORIA_MAXIMA_CANTIDAD() RETURNS Trigger AS $$
DECLARE
    cant        integer;
BEGIN
   SELECT count(*) INTO cant
   FROM gr05_subcategoria
   WHERE id_categoria = NEW.id_categoria;
   IF (cant > 50 ) THEN
      RAISE EXCEPTION 'Superó la cantidad de % subacategorias %', cant, NEW.id_categoria;
   END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR05_SUBCATEGORIA_MAXIMA_CANTIDAD
BEFORE INSERT OR UPDATE OF id_categoria
ON gr05_subcategoria
    FOR EACH ROW EXECUTE PROCEDURE FN_GR05_SUBCATEGORIA_MAXIMA_CANTIDAD();
	

------------------------------  C   ------------------------------------

--ASSERTION
--c) La suma de los aportes que recibe una edición de un evento de sus patrocinantes
--no puede superar el presupuesto establecido para la misma.

/*
CREATE ASSERTION ASS_APORTES_EXCEDEN_PRESUPUESTO
CHECK NOT EXISTS (
	SELECT 1
	FROM gr05_patrocinios p
	JOIN gr05_evento_edicion e
		ON (p.id_evento = e.id_evento AND p.nro_edicion = e.nro_edicion)
	GROUP BY p.id_evento, p.nro_edicion, e.presupuesto
	HAVING sum(p.aporte) > e.presupuesto
	);
*/

--TABLA patrocinios
--INSERT si
--UPDATE aporte
--DELETE no

--TABLA evento_edicion
--INSERT no
--UPDATE presupuesto
--DELETE no

CREATE OR REPLACE FUNCTION FN_CONTROL_APORTES_EXCEDEN_PRESUPUESTO_UPDATE()
RETURNS Trigger AS $$
DECLARE
	presupuesto integer;
    total_aportes integer;
BEGIN
	SELECT e.presupuesto INTO presupuesto
	FROM gr05_evento_edicion e
	WHERE e.id_evento = NEW.id_evento
		AND e.nro_edicion = NEW.nro_edicion;

	SELECT SUM(aporte) INTO total_aportes
    FROM gr05_patrocinios p
    WHERE p.id_evento = NEW.id_evento
        AND p.nro_edicion = NEW.nro_edicion
    GROUP BY p.id_evento, p.nro_edicion;

	total_aportes = total_aportes + NEW.aporte - OLD.aporte;

	IF	((total_aportes) > presupuesto) THEN
	RAISE EXCEPTION 'Superó el máximo permitido de % pesos. Aportes pretendidos % pesos.', presupuesto, total_aportes;
	END IF;
	RETURN NEW;
END $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION FN_CONTROL_APORTES_EXCEDEN_PRESUPUESTO_INSERT()
RETURNS Trigger AS $$
DECLARE
	presupuesto integer;
    total_aportes integer;
BEGIN
	SELECT e.presupuesto INTO presupuesto
	FROM gr05_evento_edicion e
	WHERE e.id_evento = NEW.id_evento
		AND e.nro_edicion = NEW.nro_edicion;

	SELECT SUM(aporte) INTO total_aportes
    FROM gr05_patrocinios p
    WHERE p.id_evento = NEW.id_evento
        AND p.nro_edicion = NEW.nro_edicion
    GROUP BY p.id_evento, p.nro_edicion;

	total_aportes = total_aportes + NEW.aporte;

	IF	((total_aportes) > presupuesto) THEN
	RAISE EXCEPTION 'Superó el máximo permitido de % pesos. Aportes pretendidos % pesos. Puede aportar % pesos.', presupuesto, total_aportes, NEW.aporte-(total_aportes-presupuesto);
	END IF;
	RETURN NEW;
END $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION FN_CONTROL_PRESUPUESTO_UPDATE()
RETURNS Trigger AS $$
DECLARE
	presupuesto integer;
    total_aportes integer;
BEGIN
	SELECT SUM(aporte) INTO total_aportes
    FROM gr05_patrocinios p
    WHERE p.id_evento = NEW.id_evento
        AND p.nro_edicion = NEW.nro_edicion
    GROUP BY p.id_evento, p.nro_edicion;

	presupuesto = NEW.presupuesto;

	IF	((total_aportes) > presupuesto) THEN
	RAISE EXCEPTION 'Los aportes ya recibidos de % pesos superan el monto de % pesos que intenta ingresar.', total_aportes, presupuesto;
	END IF;
	RETURN NEW;
END $$
LANGUAGE 'plpgsql';

CREATE TRIGGER TR_CONTROL_APORTES_PATROCINANTES_UPDATE
	BEFORE UPDATE OF aporte
	ON gr05_patrocinios
	FOR EACH ROW
	WHEN (NEW.aporte > OLD.aporte)
	EXECUTE PROCEDURE FN_CONTROL_APORTES_EXCEDEN_PRESUPUESTO_UPDATE();

CREATE TRIGGER TR_CONTROL_APORTES_PATROCINANTES_INSERT
	BEFORE INSERT
	ON gr05_patrocinios
	FOR EACH ROW
	EXECUTE PROCEDURE FN_CONTROL_APORTES_EXCEDEN_PRESUPUESTO_INSERT();

CREATE TRIGGER TR_CONTROL_PRESUPUESTO_EDICION
	BEFORE UPDATE OF presupuesto
	ON gr05_evento_edicion
	FOR EACH ROW
	WHEN (NEW.presupuesto < OLD.presupuesto)
	EXECUTE PROCEDURE FN_CONTROL_PRESUPUESTO_UPDATE();

------------------------   D   -----------------------------------------------
-- Función utilizada por Trigger tr_gr05_patrocinios_distrito
CREATE OR REPLACE FUNCTION fn_gr05_patrocinios_distrito() RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS (
			SELECT 1
			FROM gr05_patrocinante pte
			JOIN gr05_patrocinios pnio
				ON (pte.id_patrocinate = pnio.id_patrocinate)
			JOIN gr05_evento e
				ON (pnio.id_evento = e.id_evento)
			WHERE pte.id_distrito <> e.id_distrito
				AND (pnio.id_patrocinate = NEW.id_patrocinate AND pnio.id_evento = NEW.id_evento AND pnio.nro_edicion = NEW.nro_edicion)
		) THEN
	RAISE EXCEPTION 'Error';
	END IF;
RETURN NEW;
END $$ LANGUAGE 'plpgsql';

--Función utilizada por Trigger tr_gr05_patrocinante_distrito
CREATE OR REPLACE FUNCTION fn_gr05_patrocinante_distrito() RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS (
			SELECT 1
			FROM gr05_patrocinante pte
			JOIN gr05_patrocinios pnio
				ON (pte.id_patrocinate = pnio.id_patrocinate)
			JOIN gr05_evento e
				ON (pnio.id_evento = e.id_evento)
			WHERE pte.id_distrito <> e.id_distrito
	            AND (pte.id_distrito = NEW.id_distrito)
		) THEN
	RAISE EXCEPTION 'Error';
	END IF;
RETURN NEW;
END $$ LANGUAGE 'plpgsql';

--Función utilizada por Trigger tr_gr05_evento_distrito
CREATE OR REPLACE FUNCTION fn_gr05_evento_distrito() RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS (
			SELECT 1
			FROM gr05_patrocinante pte
			JOIN gr05_patrocinios pnio
				ON (pte.id_patrocinate = pnio.id_patrocinate)
			JOIN gr05_evento e
				ON (pnio.id_evento = e.id_evento)
			WHERE pte.id_distrito <> e.id_distrito
	            AND (e.id_distrito = NEW.id_distrito)
		) THEN
	RAISE EXCEPTION 'Error';
	END IF;
RETURN NEW;
END $$ LANGUAGE 'plpgsql';

--Trigger en Tabla Patrocinante
CREATE TRIGGER tr_gr05_patrocinante_distrito
BEFORE UPDATE OF id_distrito
ON gr05_patrocinante
FOR EACH ROW
EXECUTE PROCEDURE fn_gr05_patrocinante_distrito();

--Trigger en Tabla Patrocinios
CREATE TRIGGER tr_gr05_patrocinios_distrito
BEFORE INSERT OR UPDATE OF id_patrocinate, id_evento
ON gr05_patrocinios
FOR EACH ROW
EXECUTE PROCEDURE fn_gr05_patrocinios_distrito();

--Trigger en Tabla Evento
CREATE TRIGGER tr_gr05_evento_distrito
BEFORE UPDATE OF id_distrito
ON gr05_evento
FOR EACH ROW
EXECUTE PROCEDURE fn_gr05_evento_distrito();

---------------------------------- SERVICIO DE CREACION DE EVENTO_EDICION   -----------------------------

CREATE OR REPLACE FUNCTION fn_gr05_edicion_evento_nueva_edicion() RETURNS TRIGGER AS $$
DECLARE
	mes integer;
    dia integer;
	presup_anterior gr05_evento_edicion.presupuesto%type;
BEGIN
    SELECT mes_evento INTO mes
    FROM gr05_evento e
    WHERE e.id_evento = NEW.id_evento;

    SELECT dia_evento INTO dia
    FROM gr05_evento e
    WHERE e.id_evento = NEW.id_evento;

    SELECT presupuesto INTO presup_anterior
    FROM gr05_evento_edicion ed
    WHERE ed.id_evento = NEW.id_evento
        AND (ed.fecha_edicion < NEW.fecha_edicion)
    ORDER BY fecha_edicion DESC
    LIMIT 1;

	IF EXISTS (
	    SELECT 1
	    FROM gr05_evento e
	    WHERE e.id_evento = NEW.id_evento)
	THEN
		IF (
		    (SELECT count(*)
            FROM gr05_evento_edicion ed
            WHERE ed.id_evento = NEW.id_evento) > 1)
        THEN
			UPDATE gr05_evento_edicion ed
			SET
				fecha_inicio_pub = to_date('01/'||mes||'/'||extract(year from current_timestamp), 'DD/MM/YYYY'),
				presupuesto = presup_anterior * (1 + 0.1),
			    fecha_edicion = to_date(dia||'/'||mes||'/'||extract(year from current_timestamp), 'DD/MM/YYYY')
		    WHERE (ed.id_evento = NEW.id_evento AND ed.nro_edicion = NEW.nro_edicion);
		ELSE
		    UPDATE gr05_evento_edicion ed
			SET
				fecha_inicio_pub = to_date('01/'||mes||'/'||extract(year from current_timestamp), 'DD/MM/YYYY'),
				presupuesto = 100000,
			    fecha_edicion = to_date(dia||'/'||mes||'/'||extract(year from current_timestamp), 'DD/MM/YYYY')
		    WHERE (ed.id_evento = NEW.id_evento AND ed.nro_edicion = NEW.nro_edicion);
        END IF;
	END IF;
RETURN NEW;
END $$ LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR05_EDICION_EVENTO_NUEVA_EDICION
AFTER INSERT
ON gr05_evento_edicion
FOR EACH ROW EXECUTE PROCEDURE fn_gr05_edicion_evento_nueva_edicion();

-------------------------------  VISTAS  -------------------------------

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