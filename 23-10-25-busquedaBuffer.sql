CREATE extension postgis;
CREATE TABLE gps_tracks AS
SELECT
ST_MakeLine(geom) AS geom, track_id
FROM ( SELECT * FROM waypoints ORDER BY id) AS ordered_points
GROUP BY track_id;
--transforma a texto
SELECT ST_asText(geom) from gps_tracks;
select * from gps_tracks gt ;
--se quedaron el mismo renglón (multilinestring)
UPDATE gps_tracks SET geom = ST_UnaryUnion(geom);
--identifica número de geometría y las separa
--dame el número de geometrías y preséntalos como elementos seriados
--N sepata
--num pone en lista
SELECT ST_asText(ST_GeometryN(geom,generate_series(1,ST_NumGeometries(geom)))) AS lines
FROM gps_tracks;
--se empaquetan en st as text
--separa geometrias
select st_geometryn(geom, generate_series(1,st_numgeometries(geom))) from gps_tracks -- colection
select st_numgeometries(geom) from gps_tracks;
--dame todos los puntos de esa línea
--para poder eliminar todos los que no me interesan
CREATE TABLE waypoints_nuevos AS
SELECT
ST_PointN(
	 lines,
	 generate_series(1, ST_NPoints(lines))
) as geom
FROM (
	SELECT
		ST_GeometryN(geom,
	generate_series(1,ST_NumGeometries(geom))) AS lines
	FROM gps_tracks
) AS foo;
--serial es una función con todas las características necesarias para que cumpla con un ID
alter table waypoints_nuevos add column id serial;
--descompone la línea y da puntos en orden
--con el punto de intersección, se construye el polígono
CREATE TABLE gps_lakes AS
SELECT
ST_BuildArea(geom) AS lake,
track_id
--es la que se decompuso en diferentes líneas
--a esta tabla solo se le puso un punto
FROM gps_tracks;
WITH data(geom) AS (VALUES
('LINESTRING (180 40, 30 20, 20 90)'::geometry)
,('LINESTRING (180 40, 160 160)'::geometry)
,('LINESTRING (160 160, 80 190, 80 120, 20 90)'::geometry)
,('LINESTRING (80 60, 120 130, 150 80)'::geometry)
,('LINESTRING (80 60, 150 80)'::geometry)
)
SELECT ST_AsText( ST_BuildArea( ST_Collect( geom )))
FROM data;
SELECT ST_BuildArea(ST_Collect(inring,outring))
FROM (SELECT
ST_Buffer('POINT(100 90)', 25) As inring,
ST_Buffer('POINT(100 90)', 50) As outring) As t;
WITH data(geom) AS (VALUES
('LINESTRING (180 40, 30 20, 20 90)'::geometry)
,('LINESTRING (180 40, 160 160)'::geometry)
,('LINESTRING (160 160, 80 190, 80 120, 20 90)'::geometry)
,('LINESTRING (80 60, 120 130, 150 80)'::geometry)
,('LINESTRING (80 60, 150 80)'::geometry)
)
SELECT ST_AsText( ST_BuildArea( ST_Collect( geom )))
FROM data;
	
	
--toma dos puntos de origen y construye dos buffers
SELECT ST_BuildArea(ST_Collect(inring,outring))
FROM (SELECT
ST_Buffer('POINT(100 90)', 25) As inring, --anillo interior
ST_Buffer('POINT(100 90)', 50) As outring) As t; --anillo exterior
	--construye un poligono
SELECT st_astext(ST_Buffer('POINT(100 90)', 25)) As inring;
--multipoligono
SELECT ST_AsText(ST_Collect(inring,outring))
FROM (SELECT
ST_Buffer('POINT(100 90)', 25) As inring, --anillo interior
ST_Buffer('POINT(100 90)', 50) As outring) As t; --anillo exterior
	--constrye con dos polígonos para delimitar área del centro
	--colección de líneas
	SELECT ST_BuildArea(ST_Collect(inring,outring))
FROM (SELECT
ST_Buffer('POINT(100 90)', 25) As inring, --anillo interior
ST_Buffer('POINT(100 90)', 50) As outring) As t;
--queremos calcular buffer de esto edificios
--¿como sacar las áreas de influencia de los edificios ?
select * from censo_edificios ce where id in ( '795', '19336', '166', '14349', '1325')
--como subconsulta
select st_buffer (edificios.geom, 50) as geom, edificios.id, edificios.fecha, edificios.caracteris
from
(select * from censo_edificios ce where id in ( '795', '19336', '166', '14349', '1325')) as edificios;
ALTER TABLE censo_edificios
ALTER COLUMN geom
TYPE Geometry(POINT, 6362)
USING ST_Transform(geom, 6362);	
alter table censo_edificios drop column geom;
--consulta genérica
-- puntos en espacio 2
SELECT AddGeometryColumn ('esquema','nombre_tabla','columna_geometría',SRID,'TIPODEGEOMETRIA', 2);
alter table censo_edificios drop column geom;
--4326 porque está en grados
SELECT AddGeometryColumn (public,censo_edificios,'geom',4326,'POINT',2);
--
--consuta genérica
UPDATE esquema.tabla SET columna_geom = ST_SetSRID(ST_MakePoint(columna_longitud, columna_latitud), NUM_SRID);
--crea geometría de puntos a partir de las coordenadas
UPDATE censo_edificos SET geom = ST_SetSRID(ST_MakePoint(longitud, latitud), 4326);
