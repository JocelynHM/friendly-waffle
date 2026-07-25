/*PARA EL RIESGO*/
alter table fisico.catastro_unidos add column riesgo text;
update fisico.catastro_unidos a
set riesgo = b.riesgo
from fisico.censo_edificios b
where st_intersects(a.geom, b.geom);
select * from fisico.catastro_unidos limit 10;
--muestra los valores que no están vacíos
select * from fisico.catastro_unidos where riesgo is not NULL;
--muestra los diferentes valores de la columna riesgo_colonia en la tabla
select distinct(riesgo_colonia) from poblacion.manzanas;
--llena espacios vacíos
update fisico.catastro_unidos set riesgo='INDEFINIDO' where riesgo is null;


/*ZONIFICACIÓN EN CENSO EDIFICIOS*/
select * from fisico.censo_edificios limit 10;
alter table fisico.censo_edificios add column zona_sismica text;
-- Actualizar la columna
update fisico.censo_edificios a
set zona_sismica = b.zona
from fisico.zonificacionsismica b
where st_intersects(a.geom, b.geom);
--para ver todo lo que no esté vacío
select * from fisico.censo_edificios where zona_sismica is not NULL;
--cambia valores a 1
update fisico.censo_edificios set zona_sismica='1' where zona_sismica is not null;
--cambia valores a 0
update fisico.censo_edificios set zona_sismica='0' where zona_sismica is null;
select * from fisico.censo_edificios where zona_sismica='0';


/*PARA EL PROMEDIO DE EDAD POR COLONIA*/
/*en catastro*/
select * from fisico.catastro_unidos limit 10;
select distinct(anio_construccion) from fisico.catastro_unidos;
alter table fisico.catastro_unidos add column edad_construccion text;
update fisico.catastro_unidos set anio_construccion = '0' where anio_construccion = 'NA';
update fisico.catastro_unidos a
set edad_construccion = 2023- a.anio_construccion::int;
--agregar columna de claves de colonia para proseguir con interseccion con tabla de colonias
alter table fisico.catastro_unidos add column colonia_cvegeo text;
update fisico.catastro_unidos a
set colonia_cvegeo = b.cve_col
from poblacion.colonias_cdmx b
where st_intersects(a.geom, b.geom);
select * from fisico.catastro_unidos limit 10;
/*en colonias_cdmx*/
alter table poblacion.colonias_cdmx add column edad_construcciones text;
update poblacion.colonias_cdmx a
	set edad_construcciones = b.edad_promedio
		from (
		select a.colonia_cvegeo, AVG(a.edad_construccion::int) edad_promedio
		from fisico.catastro_unidos a
		group by a.colonia_cvegeo ) b
where a.cve_col = b.colonia_cvegeo;
select * from poblacion.colonias_cdmx cc limit 10;
