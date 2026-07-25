create extension postgis;
--primer paso
-- se busca obtener los datos que necesitamos, en este caso los de población total y discapaitada
create table manzanas_2 as
select dm.manzana_cvegeo, dm.disc01, dm.pob01, mc.geom
from poblacion.manzanas_cdmx mc
join poblacion.datos_manzanas dm
on mc.manzana_cv = dm.manzana_cvegeo;
--segundo paso
--se quieren agrupar por colonias
-- agregar columna de clave de colonias
alter table manzanas_2 add column cve_col text;
update manzanas_2 a
set cve_col= b.cve_col
from poblacion.colonias_cdmx b
--para hacer una intersección y no da resultados, puede ser que no estén en la misma proyección
where st_intersects(a.geom, b.geom);
select * from manzanas_2 m limit 10;
--suma la población y agrupa por colonias
select a.cve_col, sum(a.pob01::int) poblacion_total
from (select * from manzanas_2 m --está en public, no necesita que escribamos el esquema
	where pob01::int>0) a
group by a.cve_col;
--se va a trabajar sobre la tabla de colonias, por lo que se agrega
alter table poblacion.colonias_cdmx add column poblacion_total int;
update poblacion.colonias_cdmx a
set a.poblacion_total = b.poblacion_total
from
	(select a.cve_col, sum(a.pob01::int) poblacion_total
	from ( select * from manzanas_2 m
		where pob01::int >0) a
	group by a.cve_col) as b
where a.cve_col = b.cve_col;
--para los edificios
alter table fisico.censo_edificios add column cve_col varchar;
update fisico.censo_edificios a
set cve_col = b.cve_col
from poblacion.colonias_cdmx b
where st_intersects(a.geom, b.geom);
alter table poblacion.colonias_cdmx add column no_edificos text;
update poblacion.colonias_cdmx a
set no_edificios = b.no_edificos
from
	(select cve_col, count(*) no_edificios
	from ( select * from fisico.censo_edificios
		where riesgo = 'ALTO') a
	group by a.cve_col) as b
where a.cve_col = b.cve_col;
--mio
update poblacion.colonias_cdmx a
set no_edificios = b.no_edificios
--hace un conteo con el número de edificios
from (select count(*) as no_edificios, colonia_cvegeo
--y selecciona aquellos cuyo riesgo sea alto
from (select * from fisico.censo_edificios where riesgo='ALTO') as a
--agrupa por colonias
group by colonia_cvegeo) as b
where a.cve_col = b.colonia_cvegeo ;
	
alter table poblacion.colonias_cdmx add column poblacion_disc varchar;
update poblacion.colonias_cdmx a
set poblacion_disc = b.poblacion_disc
from
	(select a.cve_col, sum(a.disc01::int) poblacion_disc
	from (select * from manzanas_2
	where disc01::int>0) a
	group by a.cve_col) as b
where st_intersects(a.geom, b.geom);
alter table poblacion.colonias_cdmx add column no_edificos text;
select min(poblacion_total), max(poblacion_total), avg(poblacion_total)
from (select * from poblacion.colonias_cdmx
where no_edificios is not null
order by no_edficios desc);
select min(a.total_personas::int), max(a.total_personas::int), avg(a.total_personas::int)
from (select * from poblacion.colonias_cdmx cc
	where no_edificios is not null
	order by no_edificios desc) a;
select distinct(no_edificios) from poblacion.colonias_cdmx cc;
--cuál es la cantidad de edificos para poder hacer rangos
select min(a.no_edificios), max(a.no_edificios), avg(a.no_edificios)
from (select * from poblacion.colonias_cdmx cc
	where no_edificios is not null
	order by no_edificios desc) a;
	
-- pob total
-- edif riesgo
-- otras capas
-- hacer rangos


select * from poblacion.colonias_cdmx cc limit 100;
select distinct(riesgo) from poblacion.colonias_cdmx cc ;
select distinct(zona_sismica) from poblacion.colonias_cdmx cc ;
select distinct(magnitud_hund) from poblacion.colonias_cdmx cc ;
select distinct(subsidencia) from poblacion.colonias_cdmx cc ;
select min(a.no_edificios), max(a.no_edificios), avg(a.no_edificios)
from (select * from poblacion.colonias_cdmx cc
	where no_edificios is not null
	order by no_edificios desc) a;
select min(total_personas), max(total_personas), avg(total_personas::int)
from poblacion.colonias_cdmx cc ;
--min 100, max 9991, avg 4.9
select min(personas_disc), max(personas_disc), avg(personas_disc::int)
from poblacion.colonias_cdmx cc where personas_disc != '0';
--min 10, max 993, avg 205
alter table poblacion.colonias_cdmx add column grado_riesgo text ;
update poblacion.colonias_cdmx a set grado_riesgo =
case
when a.num_edificios < 30
and zona_sismica = 'BAJO' and subsidencia= 'BAJO' then 'BAJO'
when a.num_edificios >= 31 and a.num_edificios < 100
and zona_sismica = 'MEDIO' and riesgo ='MEDIO' then 'MEDIO'
when a.num_edificios >= 100 and a.num_edificios <= 276
and zona_sismica='ALTO' and riesgo='ALTO' then 'ALTO'
when a.num_edificios >= 100 and a.num_edificios <= 276
and zona_sismica='MUY ALTO' and riesgo='ALTO' then 'ALTO'
else 'N/A'
end;
select * from poblacion.colonias_cdmx cc where no_edificios >= 146 and no_edificios <= 276 and zona_sismica='MUY ALTO'
and riesgo='ALTO' AND subsidencia='MUY ALTO' or subsidencia='ALTO' or magnitud_hund ='ALTO' ;
select distinct(riesgo) from fisico.censo_edificios ce;
select * from poblacion.colonias_cdmx cc where no_edificios = 0 and no_edificios < 30 and zona_sismica = 'BAJO'
and subsidencia= 'BAJO' or magnitud_hund = 'BAJO';
select distinct (grado_riesgo) from poblacion.colonias_cdmx cc ;
select * from poblacion.colonias_cdmx cc where grado_riesgo = 'ALTO';
select * from poblacion.colonias_cdmx cc where num_edificios >= 146 and num_edificios <= 276 ;
select * from poblacion.colonias_cdmx cc where num_edificios >= 31 and num_edificios <= 145 order by num_edificios DESC;



