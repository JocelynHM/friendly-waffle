/* De la página https://www.atlas.cdmx.gob.mx/datosabiertos.html descarga datos que consideres complementan el proyecto y plantea 5 preguntas que se puedan resolver con ellos*/

/*¿Cuáles son las colonias con subsidencia muy alta?*/
select * from fisico.spc_subsidencia ss limit 10;
select * from fisico.subsidencia s limit 10;
select distinct (intensidad) from fisico.spc_subsidencia ss;
select distinct (intensidad) from fisico.subsidencia s ; --usar esta capa pues tiene valores más completos
alter table poblacion.colonias_cdmx add column subsidencia text;
update poblacion.colonias_cdmx a
set subsidencia = b.intensidad
from fisico.subsidencia b
where st_intersects(a.geom, b.geom);
update poblacion.colonias_cdmx set subsidencia='0' where subsidencia is null;
select distinct (subsidencia) from poblacion.colonias_cdmx cc ;

select * from poblacion.colonias_cdmx cc where subsidencia='MUY ALTO' order by total_personas::INT DESC;

/*¿Cómo es la litología en colonias de sismología alta?*/
select * from fisico.censo_edificios ce limit 10;
select * from poblacion.colonias_cdmx cc limit 10;
select * from fisico.litologia l limit 10;
ALTER TABLE fisico.zonificacionsismica
ALTER COLUMN geom
TYPE Geometry(MULTIPOLYGON, 6362)
USING ST_Transform(geom, 6362);	
alter table poblacion.colonias_cdmx add column zona_sismica text;
update poblacion.colonias_cdmx a
set zona_sismica = b.zona
from fisico.zonificacionsismica b
where st_intersects(a.geom, b.geom);
update poblacion.colonias_cdmx set zona_sismica='0' where zona_sismica is null;
select * from fisico.zonificacionsismica z ;
select * from poblacion.colonias_cdmx cc where zona_sismica='Zona IIId';
select distinct (zona_sismica) from poblacion.colonias_cdmx cc ;
alter table poblacion.colonias_cdmx add column litologia text;
update poblacion.colonias_cdmx a
set litologia = b.descripcio
from fisico.litologia b
where st_intersects(a.geom, b.geom);
select * from fisico.zonificacionsismica z ;
select nombre, alcaldia, total_personas, litologia from poblacion.colonias_cdmx cc where zona_sismica='Zona IIId' order by total_personas::int desc;
select distinct (zona_sismica) from poblacion.colonias_cdmx cc ;

select nombre, alcaldia, total_personas, litologia from poblacion.colonias_cdmx cc where zona_sismica='Zona IIId' order by total_personas::int desc;

/*¿Cuáles son las colonias con mayor magnitud de hundimiento (21-30 cm/año)? 
¿Cuántas personas viven en dichas colonias?*/
alter table poblacion.colonias_cdmx add column manitud_hund text;
update poblacion.colonias_cdmx a
set magnitud_hund = h.magni_num
from fisico.hundimientos h
where st_intersects(a.geom, h.geom);
select * from poblacion.colonias_cdmx cc where magnitud_hund is not null;
update poblacion.colonias_cdmx set magnitud_hund = '0' where magnitud_hund is null;
select * from poblacion.colonias_cdmx cc where magnitud_hund = '21-30' order by total_personas::int desc ;

/*¿Cómo es el riesgo de derrumbe en colonias cuya zonificación sísmica es muy alta?*/
select * from fisico.censo_edificios ce limit 10;
select distinct(riesgo) from poblacion.colonias_cdmx cc limit 10;
--creación de columna
alter table poblacion.colonias_cdmx add column riesgo text;
update poblacion.colonias_cdmx a
set riesgo = b.riesgo
from fisico.censo_edificios b
where st_intersects(a.geom, b.geom);
update poblacion.colonias_cdmx set riesgo='INDEFINIDO' where riesgo is null;

select nombre, alcaldia, total_personas, no_edificios , litologia, riesgo from poblacion.colonias_cdmx cc where zona_sismica = 'MUY ALTO' order by total_personas::int desc;

/*¿Existen zonas donde intersecta un alto riesgo de derrumbe, alta zonificación sísmica, subsidencia y hundimiento?*/
select * from poblacion.colonias_cdmx cc limit 10;
select distinct (magnitud_hund) from poblacion.colonias_cdmx cc;
update poblacion.colonias_cdmx set magnitud_hund ='ALTO' where magnitud_hund='21-30';
update poblacion.colonias_cdmx set magnitud_hund ='MEDIO' where magnitud_hund='11-20';
update poblacion.colonias_cdmx set magnitud_hund ='BAJO' where magnitud_hund='02-10';
update poblacion.colonias_cdmx set magnitud_hund ='INDEFINIDO' where magnitud_hund='0';
select distinct (subsidencia) from poblacion.colonias_cdmx cc ;
select * from poblacion.colonias_cdmx cc where riesgo='ALTO' and zona_sismica = 'MUY ALTO' and subsidencia = 'MUY ALTO' ;
--and magnitud_hund = 'ALTO';


