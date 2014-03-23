data/participation_history.csv:
	wget http://komodo.regardscitoyens.org/public/presidentielles2012/historique/participation.csv
	echo "code_dep;taux_participation;nom" > header_participation.csv
	cat header_participation.csv participation.csv > data/participation_history.csv
	rm header_participation.csv
	rm participation.csv

data/participation.csv: data/participation_history.csv data/participation_municipales2014.csv
	cat data/participation_history.csv data/participation_municipales2014.csv > data/participation.csv

data/departements-20140306-100m.shp:
	wget http://osm13.openstreetmap.fr/~cquest/openfla/export/departements-20140306-100m-shp.zip
	unzip -u departements-20140306-100m-shp.zip -d data
	rm departements-20140306-100m-shp.zip

data/populated_places.shp:
	wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places.zip
	unzip ne_10m_populated_places.zip
	rm ne_10m_populated_places.zip
	mv ne_10m_populated_places.* data/

data/places.json: data/populated_places.shp
	ogr2ogr -f GeoJSON -where "ISO_A2 = 'FR' AND SCALERANK < 8" data/places.json data/ne_10m_populated_places.shp

data/departments.json: data/departements-20140306-100m.shp
	ogr2ogr -f GeoJSON data/departments.latin1.json data/departements-20140306-100m.shp
	iconv -f latin1 -t utf8 data/departments.latin1.json > data/departments.json
	rm data/departments.latin1.json
data/france.topojson: data/places.json data/departments.json
	topojson --id-property SU_A3 -p name=nom -p code=code_insee -o data/france.topojson data/departments.json

clean:
	rm -f data/departements-20140306-100m*
	rm -f data/ne_10m_populated_places.*
	rm -f data/departments.json
	rm -f data/places.json

all: clean data/france.topojson data/participation_history.csv

