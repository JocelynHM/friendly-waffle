/*REPROYECTAR CAPAS  a la clave SRS 6362*/
--manzanas
ALTER TABLE poblacion.manzanas
ALTER COLUMN geom
TYPE Geometry(MULTIPOLYGON, 6362)
USING ST_Transform(geom, 6362);	
--manzanas_cdmx
ALTER TABLE poblacion.manzanas_cdmx
ALTER COLUMN geom
TYPE Geometry(MULTIPOLYGON, 6362)
USING ST_Transform(geom, 6362);	
--colonias_cdmx
ALTER TABLE poblacion.colonias_cdmx
ALTER COLUMN geom
TYPE Geometry(MULTIPOLYGON, 6362)
USING ST_Transform(geom, 6362);	
--catastro_unidos
ALTER TABLE fisico.catastro_unidos
ALTER COLUMN geom
TYPE Geometry(MULTIPOLYGON, 6362)
USING ST_Transform(geom, 6362);	
--censo_edificios
ALTER TABLE fisico.censo_edificios
ALTER COLUMN geom
TYPE Geometry(POINT, 6362)
USING ST_Transform(geom, 6362);

/* Identifica las colonias donde viven más personas y además hay mayor cantidad de edificios con alto riesgo*/
alter table poblacion.colonias_cdmx add column no_edificios int;
update poblacion.colonias_cdmx a 
set no_edificios = b.no_edificios
--hace un conteo con el número de edificios
from (select count(*) as no_edificios, colonia_cvegeo
--y selecciona aquellos cuyo riesgo sea alto
from (select * from fisico.censo_edificios where riesgo='ALTO') as a
--agrupa por colonias
group by colonia_cvegeo) as b
where a.cve_col = b.colonia_cvegeo ;

select * from poblacion.colonias_cdmx cc
where no_edificios is not null
and no_edificios>34
order by total_personas asc;

/* Identifica las colonias donde viven más personas con discapacidad y además hay mayor cantidad de edificios con alto riesgo*/
select * from poblacion.colonias_cdmx cc
where no_edificios is not null
and no_edificios>30
order by personas_disc asc;

/*¿Cuáles son las 10 colonias con la mayor cantidad de edificios con un alto riesgo de derrumbe? (2 pts) 
¿Cuántas personas viven en esa colonia? (2 pts)*/
select * from poblacion.colonias_cdmx
where no_edificios is not null
order by no_edificios desc
limit 10;

/* Crea una columna en la tabla de edificios dañados donde identifiques con un 1 los edificios dentro de un predio y con 0 los que está fuera */
alter table fisico.catastro_unidos add column edif_predio int;
update fisico.catastro_unidos a
set edif_predio= 1
from fisico.censo_edificios b
where st_intersects(a.geom, b.geom);
update fisico.catastro_unidos set edif_predio=0 where edif_predio is null;

/*Identifica la alcaldía con mayor número de predios, población y edificios dañados*/
alter table fisico.censo_edificios add column alc_cvegeo text;
update fisico.censo_edificios a
set alc_cvegeo = b.cve_alc
from poblacion.colonias_cdmx b
where st_intersects(a.geom, b.geom);


SELECT alcaldia,
SUM(cantidad_predios) AS total_predios,
SUM(poblacion_total) AS poblacion_total
FROM (
-- número de predios en riesgo por alcaldía
SELECT cve_alc AS alcaldia, COUNT(*) AS cantidad_predios, 0 AS poblacion_total
FROM fisico.censo_edificios
WHERE riesgo = 'ALTO'
GROUP BY cve_alc
UNION ALL
-- población total por alcaldía
SELECT cve_alc AS alcaldia, 0 AS cantidad_predios, SUM(total_personas::int) AS poblacion_total
FROM poblacion.colonias_cdmx
GROUP BY cve_alc
) AS a
GROUP BY alcaldia
ORDER BY total_predios DESC, poblacion_total DESC;

/**/
