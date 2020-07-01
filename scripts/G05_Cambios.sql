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

CREATE OR REPLACE FUNCTION FN_GR05_PATROCINIOS_APORTE_EXCEDE_PRESUPUESTO() RETURNS Trigger AS $$
DECLARE
    suma        integer;
BEGIN
   SELECT sum(aporte) INTO suma
   FROM gr05_patrocinios p
   WHERE ((p.id_evento = NEW.id_evento) and (p.nro_edicion = NEW.nro_edicion));
   IF ((SELECT presupuesto
		FROM gr05_evento_edicion e
		WHERE((e.id_evento = p.id_evento) and (e.nro_edicion = p.nro_edicion))) < (suma + NEW.aporte)) THEN
      RAISE EXCEPTION 'El nuevo aporte supero el presupuesto';
   END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR05_PATROCINIOS_APORTE_EXCEDE_PRESUPUESTO
BEFORE INSERT OR UPDATE OF aporte
ON gr05_patrocinios
FOR EACH ROW EXECUTE PROCEDURE FN_GR05_PATROCINIOS_APORTE_EXCEDE_PRESUPUESTO();

---- en EVENTO_EDICION

CREATE OR REPLACE FUNCTION FN_GR05_EVENTO_EDICION_PRESUPUESTO_INFERIOR_AL_APORTE() RETURNS Trigger AS $$
DECLARE
	total integer;
BEGIN
   SELECT new.presupuesto into total
   FROM gr05_evento_edicion e
   WHERE e.id_evento = NEW.id_evento;
   IF ((SELECT sum(aporte)
		FROM gr05_patrocinios p
		WHERE p.id_evento = e.id_evento) > total) THEN
      RAISE EXCEPTION 'El nuevo presupueto esta por debajo del aporte';
   END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR05_EVENTO_EDICION_PRESUPUESTO_INFERIOR_AL_APORTE
BEFORE UPDATE OF presupuesto
ON gr05_evento_edicion
FOR EACH ROW EXECUTE PROCEDURE FN_GR05_EVENTO_EDICION_PRESUPUESTO_INFERIOR_AL_APORTE();

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

CREATE OR REPLACE FUNCTION FN_GR05_EDICION_EVENTO_NUEVA_EDICION() RETURNS TRIGGER AS $$
DECLARE
	mes integer;
	nro_anterior gr05_evento_edicion.nro_edicion%type;
	fecha_anterior gr05_evento_edicion.fecha_edicion%type;
	presup_anterior gr05_evento_edicion.presupuesto%type;
BEGIN
	SELECT mes_evento AS mes
	FROM gr05_evento e
	WHERE e.id_evento = NEW.id_evento;
	IF (EXISTS mes) THEN
		SELECT nro_edicion AS nro_anterior,
			extract(year from fecha_edicion) AS fecha_anterior,
			presupuesto AS presup_anterior
		FROM gr05_evento_edicion ed
		WHERE ed.id_evento = NEW.id_evento
		ORDER BY fecha_edicion DESC;
		LIMIT 1;
		IF (EXISTS nro_anterior) THEN
			INSERT INTO gr05_evento_edicion(
				id_evento,
				nro_edicion,
				fecha_inicio_pub,
				fecha_fin_pub,
				presupuesto,
				fecha_edicion)
				VALUES (
					NEW.id_evento,
					NEW.nro_edicion,
					to_date('01/'||mes||'/'||extract(year from current_timestamp), 'DD/MM/YYYY'),
					NEW.fecha_fin_pub,
					presup_anterior * (1 + 0.1),
					NEW.fecha_edicion)
		ELSE
			INSERT INTO gr05_evento_edicion(
				id_evento,
				nro_edicion,
				fecha_inicio_pub,
				fecha_fin_pub,
				presupuesto,
				fecha_edicion)
				VALUES (
					NEW.id_evento,
					NEW.nro_edicion,
					to_date('01/'||mes||'/'||extract(year from current_timestamp), 'DD/MM/YYYY'),
					NEW.fecha_fin_pub,
					100000,
					NEW.fecha_edicion);
	END IF;
RETURN NEW;
END $$ LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR05_EDICION_EVENTO_NUEVA_EDICION
INSTEAD OF INSERT
ON gr05_evento_edicion
FOR EACH ROW EXECUTE PROCEDURE FN_GR05_EDICION_EVENTO_NUEVA_EDICION();

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