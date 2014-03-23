data/participation_history.csv:
	wget http://komodo.regardscitoyens.org/public/presidentielles2012/historique/participation.csv
	echo "code_dep;taux_participation;nom" > header_participation.csv
	cat header_participation.csv participation.csv > data/participation_history.csv
	rm header_participation.csv
	rm participation.csv

data/departements-20140306-100m-shp.shp:
	wget http://osm13.openstreetmap.fr/~cquest/openfla/export/departements-20140306-100m-shp.zip data/departements-20140306-100m-shp.zip
	cd data
	unzip departements-20140306-100m-shp.zip

data/populated_places.shp:
	wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places.zip
	unzip ne_10m_populated_places.zip
	mv ne_10m_populated_places.* data/
	rm data/ne_10m_populated_places.zip

data/places.json: data/populated_places.shp
	ogr2ogr -f GeoJSON -where "ISO_A2 = 'FR' AND SCALERANK < 8" data/places.json data/ne_10m_populated_places.shp

data/departments.json: data/departements-20140306-100m-shp/departements-20140306-100m.shp
	ogr2ogr -f GeoJSON data/departments.json data/departements-20140306-100m-shp/departements-20140306-100m.shp

data/france.topojson: data/places.json data/departments.json
	topojson --id-property SU_A3 -p name=nom -p code=code_insee -o data/france.topojson data/departments.json
# data/places.json

all: data/france.topojson data/participation_history.csv


clean:
	rm data/departements-20140306-100m-shp.*
	rm data/populated_places.*
	rm data/departments.json
	rm data/places.json
