create extension postgis;
alter table fisico.catastro_unidos add column riesgo text;


/*INTERSECCIÓN A TRAVES DE UN JOIN*/
--actualiza la columan de catastro, define la columna como
update fisico.catastro_unidos set riesgo
from (
-- queremos riesgo de censo
-- de catastro queremos solo la geometría
	select a.*, b.riesgo
	from fisico.catastro_unidos a
	join fisico.censo_edificios b
	on st_intersects(a.geom, b.geom)
) as
--verificación del join (ver qué devuelve)
select a.*, b.riesgo
from fisico.catastro_unidos a		--primero
join fisico.censo_edificios b		--segundo
on st_intersects(a.geom, b.geom);


/*EQUIVALENTE SIN JOIN*/
--actualiza en catastro unidos, la columna de riesgo
select fisico.catastro_unidos b
set riesgo = '1'
from fisico.censo_edificios a
where st_intersects(a.geom, b.geom);
-- ver qué valores existen sin interesección en la columna riesgo
select * from fisico.catastro_unidos where riesgo !='1';
select * from fisico.catastro_unidos cu limit 10;


/*PARA IDENTIFICACIÓN DE PATRONES*/
-- se actualiza la columna para que podamos castear a entero los datos de la columna anio_construcción
update fisico.catastro_unidos set anio_construccion = '0' where anio_construccion = 'NA';
ALTER TABLE fisico.catastro_unidos
ALTER COLUMN anio_construccion			--columna a modificar
TYPE numeric 						-- tipo a utilizar (numeric)
USING anio_construccion::int;		||
--castea la columna (cambia de un tipo de dato a otro)
