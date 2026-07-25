create extension postgis;


/*creación de tabla*/
create table poblacion.manzanas as
select mc.geom, dm.manzana_cvegeo, dm.entidad_cvegeo, dm.municipio_cvegeo, dm.disc01, dm.pob01
from poblacion.manzanas_cdmx mc	
join poblacion.datos_manzanas dm	
on mc.manzana_cv = dm.manzana_cvegeo;


/*intersección de geometrías*/
select m.*, cc.nombre, cc.cve_col as colonia_cvegeo
from poblacion.manzanas m
join poblacion.colonias_cdmx cc
on st_intersects(m.geom, cc.geom);


/*modificación de las columnas en tablas*/
--agregar columna colonia_cvegeo
alter table poblacion.manzanas add column colonia_cvegeo text;
update poblacion.manzanas a
	set colonia_cvegeo = colonia.cve_col
		from (select a.*, b.nombre, b.cve_col
			from poblacion.manzanas a
			join poblacion.colonias_cdmx b
			on st_intersects(a.geom, b.geom)) as colonia
	where a.manzana_cvegeo = colonia.manzana_cvegeo;
--agregar columna de nombres
alter table poblacion.manzanas add column nombre_colonia text;
--para la columna del nombre de la colonia
update poblacion.manzanas a
	set nombre_colonia = colonia.nombre
		from (select a.*, b.nombre, b.cve_col
			from poblacion.manzanas a
			join poblacion.colonias_cdmx b
			on st_intersects(a.geom, b.geom)) as colonia
	where a.manzana_cvegeo = colonia.manzana_cvegeo;
select * from poblacion.manzanas limit 10;
ALTER TABLE poblacion.manzanas DROP COLUMN personas_disc;
ALTER TABLE poblacion.manzanas DROP COLUMN conteo_personas;


/*DENTRO DE LA TABLA DE COLONIAS*/
--creación de columna de conteo de personas discapacitadas
alter table poblacion.colonias_cdmx add column personas_disc text;
update poblacion.colonias_cdmx a
	set personas_disc = b.total_personas_disc
	from (
		select a.colonia_cvegeo, SUM(a.disc01::int) total_personas_disc
		from poblacion.manzanas a
		where a.disc01::int > 0
		group by a.colonia_cvegeo
	) b
where a.cve_col = b.colonia_cvegeo;
select * from poblacion.colonias_cdmx where personas_disc is not null;
update poblacion.colonias_cdmx set personas_disc='0' where personas_disc is null;
select * from poblacion.colonias_cdmx cc limit 10;
--conteo de personas en general
alter table poblacion.colonias_cdmx add column total_personas text;
update poblacion.colonias_cdmx a
	set total_personas = b.total_personas
		from (
		select a.colonia_cvegeo, SUM(a.pob01::int) total_personas
		from poblacion.manzanas a
		where a.pob01::int > 0
		group by a.colonia_cvegeo
) b
where a.cve_col = b.colonia_cvegeo;


/*PARA EL RIESGO*/
select * from poblacion.manzanas where riesgo_colonia is not NULL;
select distinct(riesgo_colonia) from poblacion.manzanas; --diferentes valores de la tabla
update poblacion.manzanas set riesgo_colonia='INDEFINIDO' where riesgo_colonia is null;
select * from fisico.censo_edificios limit 10;
select distinct(riesgo) from fisico.censo_edificios limit 10;
--creación de columna
alter table poblacion.manzanas add column riesgo_colonia text;


update poblacion.manzanas a
	set riesgo_colonia = b.riesgo
		from (
			select a.*, b.riesgo
			from poblacion.manzanas a
			join fisico.censo_edificios b
			on st_intersects(a.geom, b.geom)) b
	where st_intersects(a.geom, b.geom);


--reescribiendo la consulta anterior
update poblacion.manzanas a
set riesgo_colonia = b.riesgo
from fisico.censo_edificios b
where st_intersects(a.geom, b.geom);


/*PARA LA ZONIFICACIÓN SÍSMICA*/
--CAMBIO DE PROYECCIÓN
ALTER table fisico.zonificacionsisimica
ALTER COLUMN geom
TYPE Geometry(MULTIPOLYGON, 32614)
USING ST_Transform(geom, 32614);
select * from fisico.catastro_unidos where zona_sismica is not NULL;
select * from fisico.zonificacionsismica;




-- Actualizar la columna
alter table fisico.catastro_unidos add column zona_sismica text;
update fisico.catastro_unidos a
set zona_sismica = b.zona
from fisico.zonificacionsismica b
where st_intersects(a.geom, b.geom);
