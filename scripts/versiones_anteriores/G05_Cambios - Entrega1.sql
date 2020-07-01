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

CREATE OR REPLACE FUNCTION FN_GR05_PATROCINANTE_MISMO_DISTRITO_EVENTO() RETURNS Trigger AS $$
DECLARE
    distrito_evento gr05_patrocinante.id_distrito%type;
    patrocinante gr05_patrocinante.id_patrocinate%type;
BEGIN
    SELECT id_patrocinate,id_distrito INTO patrocinante, distrito_evento
    FROM gr05_patrocinante
    WHERE (id_patrocinate = NEW.id_patrocinate and id_distrito = NEW.id_distrito);
    IF (SELECT patrocinante
        FROM gr05_patrocinante p JOIN gr05_patrocinios pa
        ON p.id_patrocinate = pa.id_patrocinate JOIN gr05_evento_edicion e
        ON pa.id_evento = e.id_evento JOIN gr05_evento ev
        ON e.id_evento = ev.id_evento
        WHERE NEW.id_distrito != ev.id_distrito ) THEN
         RAISE EXCEPTION 'ESTE PATROCINANTE POSEE PATROCINIOS EN EL DISTRITO, NO PUEDE MUDARSE';
    END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';


CREATE TRIGGER TR_GR05_PATROCINANTE_MISMO_DISTRITO_EVENTO
BEFORE UPDATE of id_distrito
ON gr05_patrocinante
FOR EACH ROW
EXECUTE PROCEDURE FN_GR05_PATROCINANTE_MISMO_DISTRITO_EVENTO();	



CREATE OR REPLACE FUNCTION FN_GR05_PATROCINIOS_MISMO_DISTRITO() RETURNS Trigger AS $$
DECLARE
    distrito_evento gr05_patrocinante.id_distrito%type;
    patrocinante gr05_patrocinante.id_patrocinate%type;
BEGIN
    SELECT id_patrocinate,id_distrito INTO patrocinante, distrito_evento
    FROM gr05_patrocinante
    WHERE (id_patrocinate = NEW.id_patrocinate and id_distrito = NEW.id_distrito);
    IF (SELECT patrocinante
        FROM gr05_patrocinante p JOIN gr05_patrocinios pa
        ON p.id_patrocinate = pa.id_patrocinate JOIN gr05_evento_edicion e
        ON pa.id_evento = e.id_evento JOIN gr05_evento ev
        ON e.id_evento = ev.id_evento
        WHERE NEW.id_distrito != ev.id_distrito ) THEN
         RAISE EXCEPTION 'ESTE PATROCINANTE POSEE PATROCINIOS EN EL DISTRITO, NO PUEDE MUDARSE';
    END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';




CREATE TRIGGER TR_GR05_PATROCINIOS_MISMO_DISTRITO
BEFORE INSERT OR UPDATE OF id_patrocinate,id_evento,nro_edicion
ON gr05_patrocinios
FOR EACH ROW
EXECUTE PROCEDURE FN_GR05_PATROCINIOS_MISMO_DISTRITO();

---------------------------------- SERVICIO DE CREACION DE EVENTO_EDICION   -----------------------------

CREATE OR REPLACE FUNCTION FN_GR05_EDICION_EVENTO_NUEVA_EDICION() RETURNS TRIGGER AS $$
DECLARE
    id gr05_evento.id_evento%type;
    mes integer;
    anio integer;
    n_edicion gr05_evento_edicion.nro_edicion%type;
    presup_anterior gr05_evento_edicion.presupuesto%type;
    ultimo gr05_evento_edicion.fecha_edicion%type;
BEGIN
    SELECT e.id_evento, ed.nro_edicion,ed.fecha_edicion,ed.presupuesto,extract(month from current_date), extract(year from current_date)
            INTO id,n_edicion,ultimo,presup_anterior,mes,anio
    FROM gr05_evento e JOIN gr05_evento_edicion ed
        ON e.id_evento = ed.id_evento
    WHERE (e.id_evento = NEW.id_evento);
    IF (extract(year FROM ultimo) - extract(year FROM current_timestamp) = 0) THEN
        new.nro_edicion = n_edicion + 1;
        new.fecha_inicio_pub = 'anio/mes/01';
        new.presupuesto = presup_anterior * 1.1;
    ELSE
        IF (n_edicion IS NULL) THEN
            n_edicion = 0;
        END IF;
        new.nro_edicion = n_edicion + 1;
        new.fecha_inicio_pub = 'anio/mes/01';
        new.presupuesto = 100000;
    END IF;
    RETURN NEW;
END $$
LANGUAGE 'plpgsql';



CREATE TRIGGER TR_GR05_EDICION_EVENTO_NUEVA_EDICION
BEFORE INSERT
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